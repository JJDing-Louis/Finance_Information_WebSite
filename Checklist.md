# 系統建置待辦事項清單（組合 3：Raw + Curated）

## 整體里程碑視角（先讓你知道終點）

完成後你會有：

- 一個 **Django API Server**（提供給 Streamlit）
- 一套 **類 Hangfire 的排程系統**（Celery + Beat）
- **Raw 資料可追溯**（MongoDB Atlas）
- **Curated 分析資料**（Neon PostgreSQL）
- **Streamlit UI** 只做分析與視覺化

---

## Phase 0：帳號與基礎資源準備（一次性）

### 0.1 GitHub
- [x] 建立主 repo（建議 monorepo）
- [x] 設定 `.gitignore`（Python / Django / Streamlit）
- [x] 規劃基本目錄結構

```text
repo/
  backend/        # Django + Celery
  streamlit_app/  # UI
```

### 0.2 Neon（Curated DB）
- [x] 註冊 Neon
- [x] Create Project
- [x] 複製 `DATABASE_URL`
- [x] 記下 DB 名稱 / user / region

### 0.3 MongoDB Atlas（Raw DB）
- [x] 建立 Atlas Project
- [x] 建立 M0 Cluster（Free）
- [x] 建立 DB User
- [x] 設定 Network Access（開發期可先 `0.0.0.0/0`）
- [x] 複製 `MONGODB_URI`
**Note:需驗證資料查詢功能**

### 0.4 Render（或其他託管平台）
- [x] 註冊 Render
- [X] 連結 GitHub
- [x] 規劃服務
  - [x] Django API（Web）
  - [ ] Celery Worker（Background）
  - [ ] Celery Beat（Background / Cron）
  - [ ] Streamlit UI（Web）

---

## Phase 1：Curated DB（Neon / PostgreSQL）

### 1.1 Schema 設計
- [ ] symbol（商品主檔）
- [ ] ohlcv_1m（分鐘線）
- [ ] latest_price（最新價）
- [ ] ingestion_job_run（任務紀錄）

原則：
- [ ] 明確 PK / UNIQUE
- [ ] (symbol, time) 複合索引
- [ ] idempotent 寫入

### 1.2 Django Migration
- [ ] 建立 models
- [ ] makemigrations
- [ ] migrate
- [ ] 驗證 insert / upsert / 查最新一筆

---

## Phase 2：Raw DB（MongoDB）

### 2.1 Collections
- [ ] raw_market_payload
- [ ] raw_ingestion_log

### 2.2 Index & Retention
- [ ] (source, symbol, timestamp) index
- [ ] TTL（7–30 天）

---

## Phase 3：Django API

### 3.1 基礎
- [ ] Django 專案初始化
- [ ] Django REST Framework
- [ ] 設定 DATABASE_URL / MONGODB_URI
- [ ] /health endpoint

### 3.2 API Endpoints
- [ ] GET /symbols
- [ ] GET /latest?symbol=
- [ ] GET /ohlcv?symbol=&from=&to=&tf=1m
- [ ] （選）GET /indicators

---

## Phase 4：排程系統（Celery）

### 4.1 Celery
- [ ] 安裝 Celery
- [ ] Redis（broker / cache / lock）
- [ ] Worker 可執行

### 4.2 排程
- [ ] django-celery-beat
- [ ] 每 1 分鐘排程

### 4.3 任務設計
- [ ] 抓 API
- [ ] 寫 Mongo Raw
- [ ] 清洗 / 對齊
- [ ] Upsert Neon
- [ ] 更新 latest_price
- [ ] transaction.atomic()
- [ ] Redis lock

### 4.4 監控
- [ ] Flower dashboard
- [ ] Error log

---

## Phase 5：Streamlit UI

### 5.1 設定
- [ ] API_BASE_URL
- [ ] health check
- [ ] st.cache_data

### 5.2 視覺化
- [ ] 最新價
- [ ] K 線
- [ ] 時間區間
- [ ] MA / EMA

---

## Phase 6：部署

### Backend
- [ ] Django API（gunicorn）
- [ ] Celery Worker
- [ ] Celery Beat / Cron

### Streamlit
- [ ] Streamlit Web Service
- [ ] 環境變數設定

---

## Phase 7：營運與穩定性
- [ ] Raw retention policy
- [ ] Curated aggregation（1m → 5m / 1h）
- [ ] Backfill 機制
- [ ] API rate limit
- [ ] Neon DB 監控

---

> **先把 Django + Celery + Neon + Mongo 跑穩，  
> Streamlit 只是結果的消費者，不是系統核心。**
