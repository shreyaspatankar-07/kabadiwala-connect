"""Pluggable OTP provider interface and mock implementation."""

import abc
from datetime import UTC, datetime, timedelta


class BaseOTPProvider(abc.ABC):
    """Abstract base class for SMS/WhatsApp OTP delivery providers."""

    @abc.abstractmethod
    async def send_otp(self, phone: str, language: str = "mr") -> tuple[str | None, int]:
        """Send an OTP to the given phone number.

        Returns (mock_otp_if_applicable, expiry_seconds).
        """
        pass

    @abc.abstractmethod
    async def verify_otp(self, phone: str, otp: str) -> bool:
        """Verify the OTP submitted for the given phone number."""
        pass


class MockOTPProvider(BaseOTPProvider):
    """In-memory mock OTP provider for testing, simulation, and local development."""

    def __init__(self, default_otp: str = "123456", ttl_seconds: int = 300):
        self.default_otp = default_otp
        self.ttl_seconds = ttl_seconds
        # In-memory storage: phone -> (otp, expires_at)
        self._store: dict[str, tuple[str, datetime]] = {}

    async def send_otp(self, phone: str, language: str = "mr") -> tuple[str | None, int]:
        now = datetime.now(UTC)
        expires_at = now + timedelta(seconds=self.ttl_seconds)
        otp = self.default_otp
        self._store[phone] = (otp, expires_at)
        return otp, self.ttl_seconds

    async def verify_otp(self, phone: str, otp: str) -> bool:
        record = self._store.get(phone)
        if not record:
            # Allow default OTP in dev if not in store
            return otp == self.default_otp

        stored_otp, expires_at = record
        if datetime.now(UTC) > expires_at:
            self._store.pop(phone, None)
            return False

        if stored_otp == otp:
            self._store.pop(phone, None)
            return True

        return False


# Global provider instance (can be swapped for SMS/Twilio provider via dependency injection)
otp_provider: BaseOTPProvider = MockOTPProvider()
