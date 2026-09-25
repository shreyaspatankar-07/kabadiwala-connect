"""FastAPI main application entrypoint for Kabadiwala Connect."""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.collectors import router as collectors_router
from app.api.v1.handover import router as handover_router
from app.api.v1.ledger import router as ledger_router
from app.api.v1.matching import router as matching_router
from app.api.v1.ml import router as ml_router
from app.api.v1.recyclers import router as recyclers_router
from app.api.v1.router import api_v1_router
from app.api.v1.safety import router as safety_router
from app.api.v1.verify import router as verify_router
from app.core.config import settings
from app.core.errors import AppError, app_error_handler, generic_http_error_handler
from app.core.logging import StructuredLoggingMiddleware

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=(
        "Vernacular, low-literacy offline-tolerant platform connecting informal "
        "e-waste collectors with authorized recyclers."
    ),
)

# Structured JSON logging middleware
app.add_middleware(StructuredLoggingMiddleware)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Custom exception handlers for consistent error envelope
app.add_exception_handler(AppError, app_error_handler)
app.add_exception_handler(HTTPException, generic_http_error_handler)

# Include v1 master router
app.include_router(api_v1_router)

# Mount direct root aliases matching user prompt
app.include_router(matching_router)
app.include_router(recyclers_router)
app.include_router(handover_router)
app.include_router(verify_router)
app.include_router(ledger_router)
app.include_router(ml_router)
app.include_router(safety_router)
app.include_router(collectors_router)


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    """Health check endpoint for container probes and load balancers."""
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
    }


@app.get("/api/v1/ping", tags=["Health"])
async def ping() -> dict[str, str]:
    """Basic ping endpoint for network latency and connectivity checks."""
    return {"message": "pong"}
