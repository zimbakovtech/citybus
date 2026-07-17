"""WebSocket connection manager: tracks clients and broadcasts JSON messages."""

import logging

from fastapi import WebSocket

logger = logging.getLogger(__name__)


class ConnectionManager:
    def __init__(self) -> None:
        self._clients: set[WebSocket] = set()

    async def connect(self, websocket: WebSocket) -> None:
        await websocket.accept()
        self._clients.add(websocket)
        logger.info("websocket client connected (%d total)", len(self._clients))

    def disconnect(self, websocket: WebSocket) -> None:
        self._clients.discard(websocket)
        logger.info("websocket client disconnected (%d total)", len(self._clients))

    async def broadcast(self, message: dict) -> None:
        """Send a JSON message to every client; drop clients that fail."""
        dead: list[WebSocket] = []
        for client in self._clients:
            try:
                await client.send_json(message)
            except Exception:  # noqa: BLE001 — any send failure means a gone client
                dead.append(client)
        for client in dead:
            self.disconnect(client)

    @property
    def client_count(self) -> int:
        return len(self._clients)


# single app-wide manager instance
manager = ConnectionManager()
