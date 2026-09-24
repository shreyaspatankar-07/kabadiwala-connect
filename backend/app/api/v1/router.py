"""API v1 master router aggregating all sub-routers."""

from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.ledger import router as ledger_router
from app.api.v1.lots import router as lots_router
from app.api.v1.materials import router as materials_router
from app.api.v1.prices import router as prices_router
from app.api.v1.recyclers import router as recyclers_router
from app.api.v1.sync import router as sync_router

api_v1_router = APIRouter(prefix="/api/v1")

api_v1_router.include_router(auth_router)
api_v1_router.include_router(materials_router)
api_v1_router.include_router(recyclers_router)
api_v1_router.include_router(prices_router)
api_v1_router.include_router(lots_router)
api_v1_router.include_router(ledger_router)
api_v1_router.include_router(sync_router)
