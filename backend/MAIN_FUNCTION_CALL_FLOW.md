# Main APP Function 呼叫流程圖

## 1. Celery 定時觸發流程（HangFire 類似模式）

```mermaid
flowchart TD
    A[Celery Beat 每分鐘] --> B[dispatch_schedules_via_http]
    B --> C[讀 tb_schedule_configs]
    C --> D[依 schedule_opt 判斷是否到點]
    D --> E[run_schedule_by_name delay schedule_name]
    E --> F[Celery Worker]
    F --> G[GET main scheduleImplement]
    G --> H[query: scheduleName and token]
    H --> I[Main.views.schedule_implement_view]
    I --> J{檢查 token}
    J -- 失敗 --> K[回傳 401]
    J -- 通過 --> N[直接呼叫 schedule_implement]
    N --> O[讀 tb_schedule_configs]
    O --> P[依 schedule_mode 讀 tb_api tb_ftp tb_file 等設定]
    P --> Q[resolve_handler]
    Q --> R[handler execute]
    R --> S[寫入 tb_schedule_log]
```

## 2. 查詢任務狀態

```mermaid
flowchart TD
    A[HTTP GET /main/tasks task_id] --> B[Main.views.task_status_view]
    B --> C[AsyncResult task_id app]
    C --> D[回傳 state result error]
```

## 3. 檔案對應

- `Main/urls.py`
  - `scheduleImplement` -> `Main.views.schedule_implement_view`
  - `tasks/<task_id>` -> `Main.views.task_status_view`
- `Main/views.py`
  - 入口驗證 token；永遠直接執行 `schedule_implement`
- `Main/tasks.py`
  - `dispatch_schedules_via_http`：掃排程、到點建立 job
  - `run_schedule_by_name`：以 GET 呼叫 `/main/scheduleImplement`
- `Main/services/schedule_executor.py`
  - 核心流程：先讀 `tb_schedule_configs`，再依 `schedule_mode` 讀其他表、選 handler、寫 log
- `Share/Tool/schedule_fun.py`
  - 透過 DBTool 讀 `tb_*_configs` 外部設定表
- `Main/registry.py`
  - `schedule_mode` 與 handler 對應
- `Main/handlers/*`
  - 實際業務執行函式
