from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "Kabadiwala Connect API"
    VERSION: str = "0.1.0"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # Database: strictly loaded from .env or container environment
    DATABASE_URL: str = Field(
        ...,
        description="Async PostgreSQL connection string (e.g. Supabase or PostGIS container)",
    )

    # Security: strictly loaded from .env or container environment
    SECRET_KEY: str = Field(
        ...,
        description="Cryptographic secret key for signing JWTs and HMAC tokens (min 32 chars in production)",
    )
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24
    HANDOVER_WEIGHT_TOLERANCE_PERCENT: float = 10.0

    # Live SMS Gateway (Twilio / Fast2SMS) for real mobile phone OTP delivery
    TWILIO_ACCOUNT_SID: str | None = Field(default=None, description="Twilio Account SID")
    TWILIO_AUTH_TOKEN: str | None = Field(default=None, description="Twilio Auth Token")
    TWILIO_PHONE_NUMBER: str | None = Field(default=None, description="Twilio Sender Phone Number")
    FAST2SMS_API_KEY: str | None = Field(default=None, description="Fast2SMS API Key for India SMS route")

    model_config = SettingsConfigDict(
        env_file=(".env", "backend/.env", "../.env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
