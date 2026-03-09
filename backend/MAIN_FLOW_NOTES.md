# Main 模組執行流程說明

## 1. 執行流程圖（僅非同步）

```mermaid
flowchart TD
    A[呼叫 scheduleImplement] --> B{async 是否為 true}
    B -- 否 --> C[回傳 400 僅支援非同步]
    B -- 是 --> D[Main view 入口]
    D --> E[送出 Celery 任務]
    E --> F[回傳 task id]
    F --> G[查詢 task 狀態]
    E --> H[Main tasks 執行]
    H --> I[Schedule Executor]

    I --> J[建立執行紀錄 RUNNING]
    J --> K[查詢排程設定]
    K --> L{有找到設定?}
    L -- 否 --> M[更新紀錄 NG]
    M --> N[回傳失敗結果]

    L -- 是 --> O[組合 schedule config]
    O --> P[Registry 選擇 Handler]
    P --> Q[嘗試客製 Handler]
    Q --> R{客製存在?}
    R -- 是 --> S[執行客製 Handler]
    R -- 否 --> T[執行預設 Handler]
    T --> U[取得執行結果]
    S --> V[取得執行結果]
    U --> V

    V --> W[更新紀錄 SUCCESS]
    W --> X[寫回執行結果]
```

---

## 2. 檔案對應圖（職責分層）

```mermaid
flowchart LR
    U[Main urls] --> V[Main views]
    V -->|非同步| T[Main tasks]
    T --> S
    S --> R[Main registry]
    R --> H1[Default Handler]
    R --> H2[Customize Handler]
    S --> M1[ScheduleConfig Model]
    S --> M2[ScheduleLog Model]
```

---

## 3. 呼叫方式

1. 非同步執行
```http
GET /main/scheduleImplement?scheduleName=TestSchedule1&async=true
```
回傳 `task_id`，再查：
```http
GET /main/tasks/<task_id>
```

2. 若傳入 `async=false`（或非 `true`）
```http
GET /main/scheduleImplement?scheduleName=TestSchedule1&async=false
```
回傳 `400`，訊息為僅支援非同步。

---

## 4. 資料表用途

1. `tb_schedule_config`
- 存排程設定主檔（`schedule_name`、`schedule_mode`、`mapping_table`、`config_json`、`enabled`）

2. `tb_schedule_log`
- 存每次執行紀錄（`run_id`、`status`、`message`、`result_json`、時間欄位）

---

## 5. 後續擴充建議

1. 在 `Main/handlers/customize/` 依 `mapping_table` 放客製 Handler。  
2. 逐步把 `DEFAULT_HANDLER_BY_MODE` 從 `default` 換成真實流程 Handler。  
3. 若要定時執行，再加 `celery beat` 或 `django-celery-beat`。  
