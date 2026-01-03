# Combo-3 Starter: Streamlit UI + Django API + Celery Scheduler + Neon (Postgres) + MongoDB Raw

This starter repo matches the architecture you selected:
- **UI**: Streamlit (consumes Django API only)
- **API**: Django + DRF
- **Jobs (Hangfire-like)**: Celery Worker + Celery Beat + Flower
- **Curated DB**: Neon PostgreSQL (via `DATABASE_URL`)
- **Raw DB**: MongoDB Atlas (via `MONGODB_URI`)
- **Queue/Cache/Locks**: Redis (via `REDIS_URL`)

## Quick start (local with Docker Compose)

1) Copy env template and fill values:
```bash
cp infra/.env.example infra/.env
```

2) Start stack:
```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml up --build
```

3) Run migrations:
```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml exec api python manage.py migrate
```

4) Open:
- Django API: http://localhost:8000/health
- Flower:    http://localhost:5555
- Streamlit: http://localhost:8501

## Deployment (Render)
- Use `infra/render.yaml` as a Render Blueprint (creates API, worker, beat, flower, streamlit).
- Set environment variables in Render from `infra/.env.example` (do NOT commit secrets).

## Data model (minimal)
- `symbol` (master)
- `ohlcv_1m` (curated bars)
- `latest_price` (cache table)
- Mongo collections: `raw_market_payload`, `raw_ingestion_log`

## Notes
- Streamlit never connects to DB directly; it calls Django API.
- Tasks are idempotent: use unique keys + upsert; lock per (source,symbol,tf) with Redis.
