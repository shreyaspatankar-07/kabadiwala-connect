"""Unit tests for demo seed dataset and generator."""

from app.data_pipeline.demo_seed import (
    DEMO_COLLECTORS,
    DEMO_RECYCLERS,
    export_demo_fixtures,
)


def test_demo_recyclers_coverage():
    """Verify 8 authorized recyclers cover all 6 target districts with valid rates."""
    assert len(DEMO_RECYCLERS) == 8
    districts = {r["district"] for r in DEMO_RECYCLERS}
    assert {"Mumbai", "Thane", "Palghar", "Pune", "Nashik", "Nagpur"}.issubset(districts)

    for rec in DEMO_RECYCLERS:
        assert rec["id"].startswith("REC-SYNTH-")
        assert "Synthetic" in rec["name"]
        assert len(rec["rates"]) >= 7
        assert rec["rating"] >= 4.0


def test_demo_collectors_coverage():
    """Verify 3 sample collectors with proper IDs and locations."""
    assert len(DEMO_COLLECTORS) == 3
    col_ids = {c["id"] for c in DEMO_COLLECTORS}
    assert col_ids == {"KC-C-7821", "KC-C-4512", "KC-C-9034"}


def test_export_demo_fixtures_structure(tmp_path):
    """Verify JSON export contains recyclers, collectors, and 3 anomalies."""
    test_file = str(tmp_path / "test_demo_export.json")
    payload = export_demo_fixtures(output_path=test_file)

    assert "recyclers" in payload
    assert len(payload["recyclers"]) == 8
    assert "collectors" in payload
    assert len(payload["collectors"]) == 3
    assert "anomalies" in payload
    assert len(payload["anomalies"]) == 3

    anomaly_reasons = [a["reason"] for a in payload["anomalies"]]
    assert any("price_outlier" in r for r in anomaly_reasons)
    assert any("weight_implausible" in r for r in anomaly_reasons)
    assert any("rapid_burst" in r for r in anomaly_reasons)
