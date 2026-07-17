"""WebSocket endpoint: /ws/realtime.

On connect the client receives a snapshot of all recently-seen vehicles, then
'vehicle_position' updates as the simulation broadcasts them."""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.core.database import SessionFactory
from app.services.realtime_service import RealtimeService
from app.websocket.manager import manager

ws_router = APIRouter()


@ws_router.websocket("/ws/realtime")
async def realtime_websocket(websocket: WebSocket) -> None:
    await manager.connect(websocket)
    try:
        async with SessionFactory() as session:
            snapshot = await RealtimeService(session).snapshot()
        await websocket.send_json(snapshot)
        # broadcasts are pushed by the simulation loop; just hold the socket
        # open (clients don't send anything meaningful)
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        pass
    finally:
        manager.disconnect(websocket)
