"""WebSocket connection manager and recycler notification endpoint.

Architecture note: ConnectionManager is a single in-memory dict. This works
correctly with a **single uvicorn worker** (development / single-process prod).
If you scale to multiple workers (e.g., gunicorn -w 4), move to Redis Pub/Sub
or PostgreSQL LISTEN/NOTIFY so events are shared across workers.
"""

import logging
from typing import Any

from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect

logger = logging.getLogger("kabadiwala.ws")

router = APIRouter(tags=["WebSocket"])


class ConnectionManager:
    """Thread-safe (asyncio) WebSocket connection manager.

    Connections are stored per recycler_id so broadcasts can be scoped to
    only the recyclers whose service area / materials match a new lot.
    """

    def __init__(self) -> None:
        # recycler_id → list[WebSocket]
        self._connections: dict[str, list[WebSocket]] = {}
        # collector_id → list[WebSocket]
        self._collector_connections: dict[str, list[WebSocket]] = {}

    async def connect(self, recycler_id: str, websocket: WebSocket) -> None:
        await websocket.accept()
        self._connections.setdefault(recycler_id, []).append(websocket)
        logger.info(
            "[WS] connect recycler=%s total_recyclers=%d",
            recycler_id,
            len(self._connections),
        )

    def disconnect(self, recycler_id: str, websocket: WebSocket) -> None:
        conns = self._connections.get(recycler_id, [])
        if websocket in conns:
            conns.remove(websocket)
        if not conns:
            self._connections.pop(recycler_id, None)
        logger.info("[WS] disconnect recycler=%s", recycler_id)

    async def connect_collector(self, collector_id: str, websocket: WebSocket) -> None:
        await websocket.accept()
        self._collector_connections.setdefault(collector_id, []).append(websocket)
        logger.info(
            "[WS] connect collector=%s total_collectors=%d",
            collector_id,
            len(self._collector_connections),
        )

    def disconnect_collector(self, collector_id: str, websocket: WebSocket) -> None:
        conns = self._collector_connections.get(collector_id, [])
        if websocket in conns:
            conns.remove(websocket)
        if not conns:
            self._collector_connections.pop(collector_id, None)
        logger.info("[WS] disconnect collector=%s", collector_id)

    async def broadcast_to_collector(self, collector_id: str, message: dict[str, Any]) -> int:
        sent = 0
        dead: list[WebSocket] = []
        for ws in list(self._collector_connections.get(collector_id, [])):
            try:
                await ws.send_json(message)
                sent += 1
            except Exception as exc:  # noqa: BLE001
                logger.warning("[WS] send failed collector=%s err=%s", collector_id, exc)
                dead.append(ws)
        for ws in dead:
            self.disconnect_collector(collector_id, ws)
        logger.info(
            "[WS] broadcast to collector=%s type=%s sent=%d",
            collector_id,
            message.get("type"),
            sent,
        )
        return sent

    async def broadcast_to_recyclers(
        self,
        recycler_ids: list[str],
        message: dict[str, Any],
    ) -> int:
        """Send message to all connected sockets for each recycler_id in the list.

        Returns the number of individual socket sends that succeeded.
        """
        sent = 0
        for rid in recycler_ids:
            dead: list[WebSocket] = []
            for ws in list(self._connections.get(rid, [])):
                try:
                    await ws.send_json(message)
                    sent += 1
                except Exception as exc:  # noqa: BLE001
                    logger.warning("[WS] send failed recycler=%s err=%s", rid, exc)
                    dead.append(ws)
            for ws in dead:
                self.disconnect(rid, ws)
        logger.info(
            "[WS] broadcast type=%s recyclers=%d sockets_sent=%d",
            message.get("type"),
            len(recycler_ids),
            sent,
        )
        return sent

    @property
    def connected_recycler_ids(self) -> list[str]:
        return list(self._connections.keys())


# Module-level singleton (safe for single-worker deployments)
manager = ConnectionManager()


@router.websocket("/ws/recycler")
async def recycler_websocket(
    websocket: WebSocket,
    recycler_id: str = Query(..., description="Authenticated recycler ID"),
) -> None:
    """WebSocket endpoint for recycler portal real-time lot notifications."""
    await manager.connect(recycler_id, websocket)
    try:
        await websocket.send_json({"type": "connected", "recycler_id": recycler_id})
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_json({"type": "pong"})
    except WebSocketDisconnect:
        pass
    finally:
        manager.disconnect(recycler_id, websocket)


@router.websocket("/ws/collector")
async def collector_websocket(
    websocket: WebSocket,
    collector_id: str = Query(..., description="Authenticated collector ID"),
) -> None:
    """WebSocket endpoint for collector mobile app real-time earnings notifications."""
    await manager.connect_collector(collector_id, websocket)
    try:
        await websocket.send_json({"type": "connected", "collector_id": collector_id})
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_json({"type": "pong"})
    except WebSocketDisconnect:
        pass
    finally:
        manager.disconnect_collector(collector_id, websocket)
