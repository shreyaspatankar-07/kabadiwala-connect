"""Structured JSON logging middleware and loggers for FastAPI."""

import json
import logging
import sys
import time
import uuid
from collections.abc import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger("kabadiwala.api")
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter("%(message)s"))
if not logger.handlers:
    logger.addHandler(handler)


class StructuredLoggingMiddleware(BaseHTTPMiddleware):
    """Logs incoming HTTP requests and responses as structured JSON records."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        start_time = time.time()

        response = await call_next(request)
        duration_ms = round((time.time() - start_time) * 1000, 2)

        log_record = {
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "duration_ms": duration_ms,
            "client_ip": request.client.host if request.client else "unknown",
        }

        # Log at appropriate level
        if response.status_code >= 500:
            logger.error(json.dumps(log_record))
        elif response.status_code >= 400:
            logger.warning(json.dumps(log_record))
        else:
            logger.info(json.dumps(log_record))

        response.headers["X-Request-ID"] = request_id
        return response
