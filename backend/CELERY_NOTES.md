# Celery 筆記（Django 專案）

## 1. 目前專案架構結論
- Broker 使用 `Redis`
- Result Backend 使用 `django-db`（實際存到 Django 預設資料庫，現況是 PostgreSQL）
- 任務模組使用 `Login/tasks.py`（符合 Celery `autodiscover_tasks()` 慣例）

---

## 2. 重要設定

### `config/celery.py`
- 使用 Django settings 初始化 Celery：
  - `os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")`
  - `app = Celery("config")`
  - `app.config_from_object("django.conf:settings", namespace="CELERY")`
  - `app.autodiscover_tasks()`

### `config/settings.py`
- Broker 由 `.env` 讀取：
  - `CELERY_BROKER_URL`（未設定時 fallback `redis://localhost:6379/0`）
- Result Backend：
  - `CELERY_RESULT_BACKEND = "django-db"`

### `.env` 建議至少包含
```env
CELERY_BROKER_URL=redis://localhost:6379/0
```

---

## 3. Windows 啟動重點（非常重要）
- 在 Windows 上，`prefork` 常出現 `PermissionError: [WinError 5] 存取被拒`
- 建議使用：
```powershell
celery -A config worker -l info -P solo
```

### 為什麼？
- `prefork` 是多進程模型，Windows 上穩定性較差
- `solo` 在開發機最穩定，先確保流程正確

---

## 4. 你這次成功驗證流程（已通過）

### 步驟 1：啟動 worker（保持視窗開啟）
```powershell
celery -A config worker -l info -P solo
```

### 步驟 2：送出測試任務
```powershell
python manage.py shell -c "from Login.tasks import add; r=add.delay(10,20); print(r.id)"
```

### 步驟 3：查任務結果
```powershell
python manage.py shell -c "from celery.result import AsyncResult; from config.celery import app; tid='你的 task id'; r=AsyncResult(tid, app=app); print(r.state, r.result)"
```

### 成功判斷
- `state = SUCCESS`
- `result = 30`

---

## 5. 常見誤區
- 沒開 worker 就送任務：結果會長時間 `PENDING`
- 任務放 `task.py` 而不是 `tasks.py`：可能不會被 autodiscover
- 查結果時沒貼真實 task id：永遠查不到正確狀態
- 只啟 Django Debug（runserver）不會自動啟 Celery worker/beat

---

## 6. 與 Hangfire 概念對照
- Hangfire：內建 Dashboard + Job 儲存 + 排程管理
- Celery：需要組合工具
  - 任務執行：Celery worker
  - 排程：Celery beat
  - 結果儲存：`django-celery-results`
  - 監控頁面：Flower（可選）
  - 排程管理頁：`django-celery-beat` + Django Admin（可選）

---

## 7. 部署觀念（IIS 類比）
- 對外通常 1 個 Web 入口（Django）
- 但至少還要背景服務程序：
  - Celery worker
  - Celery beat（若有排程）
  - Redis（broker）
  - PostgreSQL（結果儲存）
- 不一定要兩個 Web Server，但一定是多個服務角色

---

## 8. 常用指令速查

### 啟 worker（Windows 建議）
```powershell
celery -A config worker -l info -P solo
```

### 查 Celery result backend
```powershell
python manage.py shell -c "from config.celery import app; print(app.conf.result_backend)"
```

### 套用 celery results migration
```powershell
python manage.py migrate django_celery_results
```

### 測試任務送出
```powershell
python manage.py shell -c "from Login.tasks import add; r=add.delay(3,5); print(r.id)"
```

### 查任務狀態
```powershell
python manage.py shell -c "from celery.result import AsyncResult; from config.celery import app; tid='task-id'; r=AsyncResult(tid, app=app); print(r.state, r.result)"
```

