# Repository Guidelines

## 語言與輸出規則
- 所有說明請使用繁體中文
- 所有程式碼註解請使用繁體中文
- Commit 訊息以中文為主（沿用既有規範）

## Multi-agent 開發規則（重要）
- explorer / reviewer：只讀，不得修改任何檔案
- backend_worker / data_worker / streamlit_worker：可修改檔案，但每次交付必須附上：
  1) 變更檔案清單（含路徑）
  2) 如何執行/如何驗證（指令 + 預期結果）
  3) 風險點與回滾方式（如果有）
- 任務切分原則：DB（RDBMS）→ ETL（data）→ API/排程（backend）→ UI（streamlit）

## 資料與 ETL 規範（避免重複資料）
- 所有匯入流程必須可重跑（idempotent），禁止重跑造成資料倍增
- 建議所有落地資料至少包含：source、import_at、data_date（若適用）
- Mongo/Postgres 的 upsert/unique key 策略需在 PR 描述中寫明

## 專案結構與模組組織
- `backend/`：Django API 與 Celery 工作者/排程（設定在 `backend/config/`，指令入口為 `backend/manage.py`）。
- `streamlit_app/`：Streamlit 前端介面（目前入口檔為 `Main.py`）。
- `infra/`：Dockerfile、`docker-compose.yml` 與 `render.yaml` 部署設定。
- `RDBMS/`：SQL 資料庫結構腳本。
- `docs/`：架構說明與圖片。

## 建置、測試與開發指令
常見的本機開發流程（在 `infra/` 目錄下使用 Docker Compose）：
```bash
cp infra/.env.example infra/.env
docker compose --env-file infra/.env -f infra/docker-compose.yml up --build
docker compose --env-file infra/.env -f infra/docker-compose.yml exec api python manage.py migrate
```
啟動後可用的服務端點：
- API 健康檢查：`http://localhost:8000/health`
- Streamlit 介面：`http://localhost:8501`
- Flower 監控：`http://localhost:5555`

## 程式碼風格與命名規範
- Python：遵循 PEP 8、4 空格縮排、函式/變數使用 `snake_case`、類別使用 `PascalCase`。
- Django 設定位於 `backend/config/`，環境變數讀取請集中在此處。
- 目前未配置格式化或檢查工具；若新增，請在此補充說明。

## 測試指引
- 目前沒有自動化測試套件。
- 若新增測試，請使用 Django 測試框架，放在 `backend/tests/` 或各 app 的 `tests.py`。
- 測試檔名使用 `test_*.py`，並可透過以下指令執行：
```bash
docker compose --env-file infra/.env -f infra/docker-compose.yml exec api python manage.py test
```

## Commit 與 Pull Request 規範
- Commit 訊息請使用中文且簡潔，避免使用 WIP。
- PR 需包含：變更摘要、如何驗證、介面變更需附截圖。
- 若有資料庫結構或環境變數異動，請明確註記（例如 `RDBMS/` 新增 SQL 或新增環境變數）。

## 安全與設定注意事項
- 不要提交機密資訊。本機使用 `infra/.env`，部署時請在 Render 設定環境變數。
- 必要服務：Postgres（`DATABASE_URL`）、MongoDB（`MONGODB_URI`）、Redis（`REDIS_URL`）。
