"""Authentication and user management services."""

import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError, AuthenticationError
from app.core.otp import otp_provider
from app.core.security import (
    create_access_token,
    hash_password,
    hash_pin,
    verify_password,
    verify_pin,
)
from app.models.schema import Collector, PreferredLanguage, User, UserRole
from app.schemas.auth import (
    EmailLoginRequest,
    OTPRequest,
    OTPRequestResponse,
    OTPVerifyRequest,
    PINLoginRequest,
    PINSetupRequest,
    TokenResponse,
    UserRegisterRequest,
)


class AuthService:
    """Handles collector phone+OTP/PIN and recycler/admin email+password flows."""

    @staticmethod
    async def request_otp(data: OTPRequest) -> OTPRequestResponse:
        mock_code, ttl = await otp_provider.send_otp(data.phone, data.language)
        return OTPRequestResponse(
            status="otp_sent",
            retry_after_seconds=ttl,
            mock_otp=mock_code,
        )

    @staticmethod
    async def verify_otp(data: OTPVerifyRequest, db: AsyncSession) -> TokenResponse:
        valid = await otp_provider.verify_otp(data.phone, data.otp)
        if not valid:
            raise AuthenticationError("Invalid or expired OTP.")

        # Check if user exists with this phone
        result = await db.execute(select(User).where(User.phone == data.phone))
        user = result.scalar_one_or_none()

        if not user:
            # Create collector record
            collector_id = f"KC-C-{uuid.uuid4().hex[:6].upper()}"
            collector = Collector(
                collector_id=collector_id,
                phone=data.phone,
                preferred_language=PreferredLanguage.MR,
                operating_area=data.operating_area,
            )
            db.add(collector)
            await db.flush()

            user = User(
                phone=data.phone,
                role=UserRole.COLLECTOR,
                collector_id=collector_id,
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)

        # Check if collector has set a PIN
        has_pin = bool(user.pin_hash)

        token = create_access_token(
            subject=str(user.id),
            role=user.role.value,
            extra_claims={"collector_id": user.collector_id},
        )
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            role=user.role.value,
            collector_id=user.collector_id,
            has_pin=has_pin,
        )

    @staticmethod
    async def setup_pin(current_user: User, data: PINSetupRequest, db: AsyncSession) -> None:
        if current_user.role != UserRole.COLLECTOR:
            raise AppError("FORBIDDEN", "PIN setup is only allowed for collectors.")

        hashed = hash_pin(data.pin)
        current_user.pin_hash = hashed

        if current_user.collector_id:
            res = await db.execute(
                select(Collector).where(Collector.collector_id == current_user.collector_id)
            )
            collector = res.scalar_one_or_none()
            if collector:
                collector.pin_hash = hashed

        await db.commit()

    @staticmethod
    async def login_with_pin(data: PINLoginRequest, db: AsyncSession) -> TokenResponse:
        result = await db.execute(select(User).where(User.phone == data.phone))
        user = result.scalar_one_or_none()

        if not user or not user.pin_hash:
            raise AuthenticationError("Collector not found or PIN not set.")

        if not verify_pin(data.pin, user.pin_hash):
            raise AuthenticationError("Invalid PIN.")

        token = create_access_token(
            subject=str(user.id),
            role=user.role.value,
            extra_claims={"collector_id": user.collector_id},
        )
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            role=user.role.value,
            collector_id=user.collector_id,
            has_pin=True,
        )

    HARDCODED_ACCOUNTS = {
        "recycler@ecorecycle.in": {
            "password": "recycler123",
            "role": UserRole.RECYCLER,
            "name": "Maharashtra Eco-Recyclers",
            "recycler_id": "REC-SYNTH-001",
        },
        "admin@jnarddc.gov.in": {
            "password": "admin123",
            "role": UserRole.ADMIN,
            "name": "JNARDDC Government Admin Compliance",
            "recycler_id": None,
        },
        "citizen@mumbai.gov.in": {
            "password": "citizen123",
            "role": UserRole.PUBLIC,
            "name": "Sunita Sharma (Citizen)",
            "recycler_id": None,
        },
    }

    @staticmethod
    async def register_user(data: UserRegisterRequest, db: AsyncSession) -> TokenResponse:
        # Check if email exists
        res = await db.execute(select(User).where(User.email == data.email))
        if res.scalar_one_or_none():
            raise AppError("EMAIL_EXISTS", "A user with this email address already exists.")

        user = User(
            email=data.email,
            phone=data.phone,
            name=data.name,
            address=data.address,
            hashed_password=hash_password(data.password),
            role=UserRole(data.role),
            recycler_id=data.recycler_id,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

        token = create_access_token(
            subject=str(user.id),
            role=user.role.value,
            extra_claims={"recycler_id": user.recycler_id, "name": user.name},
        )
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            role=user.role.value,
            name=user.name,
            email=user.email,
            collector_id=None,
            has_pin=False,
        )

    @staticmethod
    async def login_email(data: EmailLoginRequest, db: AsyncSession) -> TokenResponse:
        clean_email = data.email.strip().lower()

        # Check for hardcoded demo accounts first
        if clean_email in AuthService.HARDCODED_ACCOUNTS:
            demo_cfg = AuthService.HARDCODED_ACCOUNTS[clean_email]
            if data.password == demo_cfg["password"]:
                # Ensure user exists in database
                res = await db.execute(select(User).where(User.email == clean_email))
                user = res.scalar_one_or_none()
                if not user:
                    user = User(
                        email=clean_email,
                        name=demo_cfg["name"],
                        hashed_password=hash_password(demo_cfg["password"]),
                        role=demo_cfg["role"],
                        recycler_id=demo_cfg["recycler_id"],
                    )
                    db.add(user)
                    await db.commit()
                    await db.refresh(user)

                token = create_access_token(
                    subject=str(user.id),
                    role=user.role.value,
                    extra_claims={"recycler_id": user.recycler_id, "name": user.name},
                )
                return TokenResponse(
                    access_token=token,
                    token_type="bearer",
                    role=user.role.value,
                    name=user.name or demo_cfg["name"],
                    email=user.email,
                    collector_id=user.collector_id,
                    has_pin=False,
                )

        res = await db.execute(select(User).where(User.email == data.email))
        user = res.scalar_one_or_none()

        if not user or not user.hashed_password:
            raise AuthenticationError("Invalid email or password.")

        if not verify_password(data.password, user.hashed_password):
            raise AuthenticationError("Invalid email or password.")

        token = create_access_token(
            subject=str(user.id),
            role=user.role.value,
            extra_claims={"recycler_id": user.recycler_id, "name": user.name},
        )
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            role=user.role.value,
            name=user.name,
            email=user.email,
            collector_id=user.collector_id,
            has_pin=False,
        )
