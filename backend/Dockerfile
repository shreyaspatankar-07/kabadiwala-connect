FROM python:3.11-slim

WORKDIR /workspace

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH="/workspace:/workspace/backend"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt /tmp/backend_reqs.txt
COPY ml/requirements.txt /tmp/ml_reqs.txt
RUN pip install --no-cache-dir -r /tmp/backend_reqs.txt -r /tmp/ml_reqs.txt

COPY backend /workspace/backend
COPY ml /workspace/ml

WORKDIR /workspace/backend

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload", "--reload-dir", "/workspace/backend", "--reload-dir", "/workspace/ml"]