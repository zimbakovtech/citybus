# Convenience targets for local development.
# Backend commands assume a virtualenv at backend/.venv (see README).

PYTHON := backend/.venv/bin/python

.PHONY: up down migrate import seed api test lint format

up:
	docker compose up -d db

down:
	docker compose down

migrate:
	cd backend && .venv/bin/alembic upgrade head

import:
	cd backend && .venv/bin/python scripts/import_gtfs.py

seed: migrate import

api:
	cd backend && .venv/bin/uvicorn app.main:app --reload

test:
	cd backend && .venv/bin/python -m pytest

lint:
	cd backend && .venv/bin/ruff check app scripts && .venv/bin/black --check app scripts

format:
	cd backend && .venv/bin/black app scripts && .venv/bin/ruff check --fix app scripts
