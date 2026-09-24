"""In-memory sliding window rate limiting for endpoints."""

import time
from collections import defaultdict

from fastapi import Request

from app.core.errors import RateLimitExceededError


class InMemoryRateLimiter:
    """Sliding-window rate limiter per client IP or key."""

    def __init__(self, max_requests: int = 60, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        # key -> list of timestamp floats
        self._history: dict[str, list[float]] = defaultdict(list)

    async def __call__(self, request: Request):
        # Identify by IP or client header
        client_ip = request.client.host if request.client else "unknown"
        key = f"{client_ip}:{request.url.path}"
        now = time.time()
        window_start = now - self.window_seconds

        # Prune older timestamps
        self._history[key] = [ts for ts in self._history[key] if ts > window_start]

        if len(self._history[key]) >= self.max_requests:
            oldest = self._history[key][0]
            retry_after = int(self.window_seconds - (now - oldest)) + 1
            raise RateLimitExceededError(retry_after=max(retry_after, 1))

        self._history[key].append(now)


# Standard limiters
standard_rate_limiter = InMemoryRateLimiter(max_requests=100, window_seconds=60)
auth_rate_limiter = InMemoryRateLimiter(max_requests=10, window_seconds=60)
