# Architecture Diagram (Combo 3)

```mermaid
flowchart LR
  U[Users] -->|HTTPS| ST[Streamlit UI]

  ST -->|REST/JSON| API[Django API (DRF)]
  API -->|SQL read| PG[(Neon PostgreSQL\nCurated Zone)]
  API -->|Cache / Locks| RD[(Redis)]

  subgraph Jobs["Scheduler / Workers (Hangfire-like)"]
    BEAT[Celery Beat] -->|enqueue| Q[(Redis Broker)]
    Q --> W[Celery Workers]
    W -->|write raw| MG[(MongoDB Atlas\nRaw Zone)]
    W -->|upsert curated| PG
    W -->|update cache| RD
  end

  EXT[External Data Providers\nFX/Crypto/Stocks/Rates] --> W
```
