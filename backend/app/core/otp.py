"""Pluggable OTP provider interface with Live SMS (Twilio / Fast2SMS) and secure in-memory caching."""

import abc
import logging
import re
import secrets
from datetime import UTC, datetime, timedelta

import httpx

from app.core.config import settings

logger = logging.getLogger("kabadiwala.otp")


def sanitize_indian_phone(phone: str) -> str:
    """Format phone number into international E.164 format (+91XXXXXXXXXX)."""
    digits = re.sub(r"\D", "", phone)
    if digits.startswith("91") and len(digits) == 12:
        return f"+{digits}"
    if len(digits) == 10:
        return f"+91{digits}"
    return f"+{digits}" if not phone.startswith("+") else phone


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


class LiveSMSOTPProvider(BaseOTPProvider):
    """Production SMS provider integrating Twilio and Fast2SMS REST APIs."""

    def __init__(self, ttl_seconds: int = 300):
        self.ttl_seconds = ttl_seconds
        # In-memory storage: phone -> (otp, expires_at)
        self._store: dict[str, tuple[str, datetime]] = {}

    def _generate_secure_otp(self) -> str:
        """Generate a cryptographically secure 6-digit numeric OTP."""
        return f"{secrets.randbelow(900000) + 100000}"

    def _format_message(self, otp: str, language: str) -> str:
        if language == "mr":
            return f"कबाडीवाला कनेक्ट: आपला सुरक्षित लॉगिन OTP आहे: {otp}. हा कोड कोणाशीही शेअर करू नका. (वैधता ५ मिनिटे)"
        elif language == "hi":
            return f"कबाड़ीवाला कनेक्ट: आपका सुरक्षित लॉगिन OTP है: {otp}. यह कोड किसी के साथ साझा न करें. (वैधता ५ मिनट)"
        return f"Kabadiwala Connect: Your secure login OTP is {otp}. Do not share this code with anyone. (Valid for 5 mins)"

    async def send_otp(self, phone: str, language: str = "mr") -> tuple[str | None, int]:
        formatted_phone = sanitize_indian_phone(phone)
        otp = self._generate_secure_otp()
        now = datetime.now(UTC)
        expires_at = now + timedelta(seconds=self.ttl_seconds)
        self._store[formatted_phone] = (otp, expires_at)
        self._store[phone] = (otp, expires_at)

        message_body = self._format_message(otp, language)

        # 1. Dispatch via Twilio REST API if credentials are provided
        if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN and settings.TWILIO_PHONE_NUMBER:
            twilio_url = (
                f"https://api.twilio.com/2010-04-01/Accounts/{settings.TWILIO_ACCOUNT_SID}/Messages.json"
            )
            auth = (settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
            data = {
                "From": settings.TWILIO_PHONE_NUMBER,
                "To": formatted_phone,
                "Body": message_body,
            }
            try:
                async with httpx.AsyncClient(timeout=10.0) as client:
                    resp = await client.post(twilio_url, data=data, auth=auth)
                    if resp.status_code in (200, 201):
                        logger.info("Successfully dispatched live SMS via Twilio to %s", formatted_phone)
                        return None, self.ttl_seconds
                    else:
                        logger.error("Twilio SMS dispatch failed: status=%s, body=%s", resp.status_code, resp.text)
            except Exception as e:
                logger.error("Twilio SMS transmission exception for %s: %s", formatted_phone, e)

        # 2. Dispatch via Fast2SMS Indian Route if configured
        elif settings.FAST2SMS_API_KEY:
            clean_digits = re.sub(r"\D", "", phone)[-10:]
            fast2sms_url = "https://www.fast2sms.com/dev/bulkV2"
            headers = {"authorization": settings.FAST2SMS_API_KEY}
            payload = {
                "route": "q",
                "message": message_body,
                "numbers": clean_digits,
            }
            try:
                async with httpx.AsyncClient(timeout=10.0) as client:
                    resp = await client.post(fast2sms_url, json=payload, headers=headers)
                    if resp.status_code == 200:
                        logger.info("Successfully dispatched live SMS via Fast2SMS to %s", clean_digits)
                        return None, self.ttl_seconds
                    else:
                        logger.error("Fast2SMS dispatch failed: status=%s, body=%s", resp.status_code, resp.text)
            except Exception as e:
                logger.error("Fast2SMS transmission exception for %s: %s", clean_digits, e)

        # In development without live SMS credentials configured, log and return OTP for testing
        logger.warning(
            "Live SMS provider active without credentials. Generated OTP for %s: %s",
            formatted_phone,
            otp,
        )
        return otp if settings.DEBUG or settings.ENVIRONMENT == "development" else None, self.ttl_seconds

    async def verify_otp(self, phone: str, otp: str) -> bool:
        formatted_phone = sanitize_indian_phone(phone)
        record = self._store.get(formatted_phone) or self._store.get(phone)
        if not record:
            return False

        stored_otp, expires_at = record
        if datetime.now(UTC) > expires_at:
            self._store.pop(formatted_phone, None)
            self._store.pop(phone, None)
            return False

        if stored_otp == otp:
            self._store.pop(formatted_phone, None)
            self._store.pop(phone, None)
            return True

        return False


class MockOTPProvider(BaseOTPProvider):
    """In-memory mock OTP provider for unit tests and local simulation."""

    def __init__(self, default_otp: str = "123456", ttl_seconds: int = 300):
        self.default_otp = default_otp
        self.ttl_seconds = ttl_seconds
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
            return otp == self.default_otp

        stored_otp, expires_at = record
        if datetime.now(UTC) > expires_at:
            self._store.pop(phone, None)
            return False

        if stored_otp == otp:
            self._store.pop(phone, None)
            return True

        return False


def get_otp_provider() -> BaseOTPProvider:
    """Factory selecting Live SMS Provider in production and Mock in testing."""
    if settings.ENVIRONMENT == "production" or settings.TWILIO_ACCOUNT_SID or settings.FAST2SMS_API_KEY:
        return LiveSMSOTPProvider()
    return MockOTPProvider()


# Global active provider instance
otp_provider: BaseOTPProvider = get_otp_provider()
