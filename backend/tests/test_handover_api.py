"""Security and lifecycle API tests for Verifiable Handover and QR flow."""

import json

import pytest
from httpx import AsyncClient

from app.core.config import settings
from app.services.handover_service import HandoverService


@pytest.fixture
async def seeded_matched_lot(async_client: AsyncClient, test_collector, test_admin):
    _, col_token = test_collector
    _, admin_token = test_admin
    col_headers = {"Authorization": f"Bearer {col_token}"}
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # 1. Create a lot
    lot_payload = {
        "client_lot_id": "LOT-HANDOVER-SEED-01",
        "category": "PCB",
        "weight_kg": 20.0,
        "quoted_price": 5000.0,
        "collection_lat": 19.0760,
        "collection_lng": 72.8777,
        "photo_hashes": ["hash_seed_photo_1", "hash_seed_photo_2"],
    }
    resp = await async_client.post("/api/v1/lots", headers=col_headers, json=lot_payload)
    assert resp.status_code == 201
    created = resp.json()
    lot_id = created["lot_id"]

    # 2. Update status to 'matched'
    await async_client.patch(
        f"/api/v1/lots/{lot_id}/status",
        headers=admin_headers,
        json={"transaction_status": "matched", "recycler_id": "REC-TEST-AUTH-01"},
    )

    return lot_id, col_headers, admin_headers


@pytest.mark.asyncio
async def test_handover_initiate_and_confirm_happy_path(
    async_client: AsyncClient, seeded_matched_lot
):
    lot_id, col_headers, admin_headers = seeded_matched_lot

    # 1. Collector initiates handover
    init_payload = {
        "lot_id": lot_id,
        "weight_kg": 20.0,
        "photo_hashes": ["fresh_photo_hash_abc", "fresh_photo_hash_def"],
        "gps_lat": 19.0765,
        "gps_lng": 72.8779,
    }
    init_resp = await async_client.post(
        "/api/v1/handover/initiate", headers=col_headers, json=init_payload
    )
    assert init_resp.status_code == 201
    init_data = init_resp.json()

    ref_no = init_data["handover_ref_no"]
    qr_payload_str = init_data["qr_payload"]
    sig = init_data["signature"]

    assert len(ref_no) == 6
    assert ref_no.isalnum() and ref_no.isupper()
    assert sig is not None

    # Verify signature mathematically
    payload_obj = json.loads(qr_payload_str)
    assert HandoverService.verify_payload_signature(payload_obj, sig) is True

    # 2. Recycler confirms handover within 10% weight tolerance (20.5 kg vs 20.0 kg = +2.5%)
    confirm_payload = {
        "handover_ref_no": ref_no,
        "qr_payload": qr_payload_str,
        "measured_weight_kg": 20.5,
        "final_price": 5100.0,
        "recycler_id": "REC-TEST-AUTH-01",
    }
    conf_resp = await async_client.post(
        "/api/v1/handover/confirm", headers=admin_headers, json=confirm_payload
    )
    assert conf_resp.status_code == 200
    conf_data = conf_resp.json()

    assert conf_data["transaction_status"] == "handed_over"
    assert conf_data["is_disputed"] is False
    assert conf_data["record_hash"] is not None
    assert conf_data["final_price"] == 5100.0

    # 3. Recycler updates downstream progress: received -> dismantled -> processed -> certificate_issued
    for step in ["dismantled", "processed", "certificate_issued"]:
        down_resp = await async_client.post(
            f"/api/v1/handover/{lot_id}/downstream",
            headers=admin_headers,
            json={"status": step},
        )
        assert down_resp.status_code == 200
        assert down_resp.json()["downstream_status"] == step

    # 4. Public verification endpoint (no auth required)
    pub_resp = await async_client.get(f"/verify/{ref_no}")
    assert pub_resp.status_code == 200
    pub_data = pub_resp.json()
    assert pub_data["handover_ref_no"] == ref_no
    assert pub_data["is_valid"] is True
    assert pub_data["recycler_confirmed"] is True
    assert pub_data["downstream_status"] == "certificate_issued"
    assert pub_data["integrity_status"] == "tamper_free"


@pytest.mark.asyncio
async def test_security_tampered_qr_signature_rejected(
    async_client: AsyncClient, seeded_matched_lot
):
    lot_id, col_headers, admin_headers = seeded_matched_lot

    # Initiate handover
    init_resp = await async_client.post(
        "/api/v1/handover/initiate",
        headers=col_headers,
        json={
            "lot_id": lot_id,
            "weight_kg": 20.0,
            "gps_lat": 19.0760,
            "gps_lng": 72.8777,
        },
    )
    init_data = init_resp.json()
    ref_no = init_data["handover_ref_no"]
    payload_obj = json.loads(init_data["qr_payload"])

    # Tamper with weight in payload without resigning
    payload_obj["weight_kg"] = 99.0
    tampered_payload_str = json.dumps(payload_obj)

    confirm_resp = await async_client.post(
        "/api/v1/handover/confirm",
        headers=admin_headers,
        json={
            "handover_ref_no": ref_no,
            "qr_payload": tampered_payload_str,
            "measured_weight_kg": 20.0,
            "final_price": 5000.0,
        },
    )
    assert confirm_resp.status_code == 400
    err = confirm_resp.json()["error"]
    assert err["code"] == "TAMPERED_QR_SIGNATURE"


@pytest.mark.asyncio
async def test_security_forged_hmac_signature_rejected(
    async_client: AsyncClient, seeded_matched_lot
):
    lot_id, col_headers, admin_headers = seeded_matched_lot

    init_resp = await async_client.post(
        "/api/v1/handover/initiate",
        headers=col_headers,
        json={
            "lot_id": lot_id,
            "weight_kg": 15.0,
            "gps_lat": 19.0760,
            "gps_lng": 72.8777,
        },
    )
    ref_no = init_resp.json()["handover_ref_no"]
    payload_obj = json.loads(init_resp.json()["qr_payload"])

    # Replace with completely forged signature
    payload_obj["signature"] = "deadbeef" * 8
    forged_payload_str = json.dumps(payload_obj)

    confirm_resp = await async_client.post(
        "/api/v1/handover/confirm",
        headers=admin_headers,
        json={
            "handover_ref_no": ref_no,
            "qr_payload": forged_payload_str,
            "measured_weight_kg": 15.0,
            "final_price": 4000.0,
        },
    )
    assert confirm_resp.status_code == 400
    assert confirm_resp.json()["error"]["code"] == "TAMPERED_QR_SIGNATURE"


@pytest.mark.asyncio
async def test_security_replay_attack_rejected(async_client: AsyncClient, seeded_matched_lot):
    lot_id, col_headers, admin_headers = seeded_matched_lot

    # 1. Initiate and confirm
    init_resp = await async_client.post(
        "/api/v1/handover/initiate",
        headers=col_headers,
        json={
            "lot_id": lot_id,
            "weight_kg": 10.0,
            "gps_lat": 19.0760,
            "gps_lng": 72.8777,
        },
    )
    ref_no = init_resp.json()["handover_ref_no"]
    qr_payload = init_resp.json()["qr_payload"]

    confirm_payload = {
        "handover_ref_no": ref_no,
        "qr_payload": qr_payload,
        "measured_weight_kg": 10.0,
        "final_price": 2500.0,
    }
    resp1 = await async_client.post(
        "/api/v1/handover/confirm", headers=admin_headers, json=confirm_payload
    )
    assert resp1.status_code == 200

    # 2. Replay attack: submitting same confirm request again must be rejected with 409
    resp2 = await async_client.post(
        "/api/v1/handover/confirm", headers=admin_headers, json=confirm_payload
    )
    assert resp2.status_code == 409
    assert resp2.json()["error"]["code"] == "HANDOVER_ALREADY_CONFIRMED"


@pytest.mark.asyncio
async def test_security_weight_mismatch_dispute_triggered(
    async_client: AsyncClient, seeded_matched_lot
):
    lot_id, col_headers, admin_headers = seeded_matched_lot

    # Collector claims 20.0 kg
    init_resp = await async_client.post(
        "/api/v1/handover/initiate",
        headers=col_headers,
        json={
            "lot_id": lot_id,
            "weight_kg": 20.0,
            "gps_lat": 19.0760,
            "gps_lng": 72.8777,
        },
    )
    ref_no = init_resp.json()["handover_ref_no"]

    # Recycler measures 15.0 kg (-25% delta, which exceeds 10% tolerance)
    confirm_resp = await async_client.post(
        "/api/v1/handover/confirm",
        headers=admin_headers,
        json={
            "handover_ref_no": ref_no,
            "measured_weight_kg": 15.0,
            "final_price": 3000.0,
        },
    )
    assert confirm_resp.status_code == 200
    conf_data = confirm_resp.json()

    assert conf_data["is_disputed"] is True
    assert conf_data["transaction_status"] == "disputed"
    assert "Weight mismatch" in conf_data["dispute_reason"]
    assert "25.0%" in conf_data["dispute_reason"]
