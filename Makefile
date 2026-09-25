# Kabadiwala Connect Project Makefile
# Note: AGENTS.md rule strictly enforces 'py -3.11' for all Python executions.

PYTHON = py -3.11

.PHONY: help setup lint format test test-backend test-ml docker-up docker-down clean data-seed data-validate data-export

help:
	@echo "Available targets:"
	@echo "  setup         - Initialize virtual environments using py -3.11 and install dependencies"
	@echo "  lint          - Run lint checks across backend, ml, and portal"
	@echo "  format        - Auto-format code using ruff"
	@echo "  test          - Run test suites for backend and ml"
	@echo "  data-seed     - Generate synthetic price stream and raw observations"
	@echo "  data-validate - Validate, clean, quarantine outliers, update rolling board & dataset card"
	@echo "  data-export   - Generate privacy-preserved, anonymized ML-ready datasets"
	@echo "  docker-up     - Start Postgres+PostGIS, backend, and portal via docker-compose"
	@echo "  docker-down   - Stop and tear down docker containers"
	@echo "  clean         - Remove caches and build artifacts"

data-seed:
	cd backend && $(PYTHON) -m app.data_pipeline.cli seed

data-validate:
	cd backend && $(PYTHON) -m app.data_pipeline.cli validate

data-export:
	cd backend && $(PYTHON) -m app.data_pipeline.cli export

setup-backend:
	$(PYTHON) -m venv backend/.venv
	backend/.venv/Scripts/python -m pip install --upgrade pip
	backend/.venv/Scripts/pip install -r backend/requirements.txt

setup-ml:
	$(PYTHON) -m venv ml/.venv
	ml/.venv/Scripts/python -m pip install --upgrade pip
	ml/.venv/Scripts/pip install -r ml/requirements.txt

setup-portal:
	cd portal && npm install

setup: setup-backend setup-ml setup-portal

lint-backend:
	$(PYTHON) -m ruff check backend

lint-ml:
	$(PYTHON) -m ruff check ml

lint: lint-backend lint-ml

format:
	$(PYTHON) -m ruff format backend ml

test-backend:
	cd backend && $(PYTHON) -m pytest

test-ml:
	cd ml && $(PYTHON) -m pytest

test: test-backend test-ml

docker-up:
	docker compose up -d

docker-down:
	docker compose down

clean:
	rm -rf backend/__pycache__ backend/.pytest_cache
	rm -rf ml/__pycache__ ml/.pytest_cache
	rm -rf portal/.next portal/out
