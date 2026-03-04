
-- ============================================================
-- 由 New_Table.sql (MSSQL) 轉換為 PostgreSQL 版本 + 補強爬蟲/HTTP 外部參數
-- 說明：
-- 1) 以 schema dbo 承接原 * 命名（避免改動既有程式碼太多）
-- 2) MSSQL nvarchar -> Postgres text / varchar
-- 3) MSSQL datetime/getdate() -> timestamptz/now()
-- 4) MSSQL bit -> boolean
-- 5) 補強：通用的「外部參數」表 tb_schedule_external_params（可放 header、cookie、代理、驗證、User-Agent、渲染等待等）
-- ============================================================

-- ------------------------------------------------------------
-- 選單資料
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_contexttype (
    name        varchar(100) PRIMARY KEY,
    value       varchar(50)  NOT NULL,
    description varchar(200) NOT NULL
);

COMMENT ON TABLE ref_contexttype IS '選單資料（原 RefContextType）';
COMMENT ON COLUMN ref_contexttype.name IS '代碼/名稱（主鍵）';
COMMENT ON COLUMN ref_contexttype.value IS '對應值';
COMMENT ON COLUMN ref_contexttype.description IS '中文說明';

-- ------------------------------------------------------------
-- 排程執行模式
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_schedulemode (
    name        varchar(100) PRIMARY KEY, -- 類別: API/FTP/FTPUpload/WEBCRAWL/PROCEDURE/PROCEDURE_CUSTOMER
    value       varchar(50),
    description varchar(200)
);

COMMENT ON TABLE ref_schedulemode IS '排程執行模式（原 RefScheduleMode）';
COMMENT ON COLUMN ref_schedulemode.name IS '模式代碼（主鍵），例如 API/FTP/WEBCRAWL';
COMMENT ON COLUMN ref_schedulemode.value IS '顯示值/短碼';
COMMENT ON COLUMN ref_schedulemode.description IS '中文說明';

-- ------------------------------------------------------------
-- 排程設定檔（主表）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_schedule_configs (
    schedule_name      varchar(100) PRIMARY KEY,
    schedule_opt       varchar(50)  NOT NULL,
    modify_time        timestamptz  NOT NULL DEFAULT now(),
    status             varchar(10)  NOT NULL,
    schedule_url       varchar(500) NOT NULL,
    schedule_mode      varchar(100) NOT NULL,       -- 類別: API/FTP/FTPUpload/WEBCRAWL/PROCEDURE/PROCEDURE_CUSTOMER
    timeout_ms         integer      NOT NULL DEFAULT 15000, -- 逾時時間
    retry_count        integer      NOT NULL DEFAULT 2,     -- 重試次數
    retry_backoff_ms   integer      NOT NULL DEFAULT 500,   -- 重試間隔（毫秒）
    mapping_table      varchar(50)  NOT NULL                 -- 對應的 Mapping 表名稱
);

COMMENT ON TABLE tb_schedule_configs IS '排程設定檔主表（原 TB_SCHEDULE_CONFIGS）';
COMMENT ON COLUMN tb_schedule_configs.schedule_name IS '排程名稱（主鍵）';
COMMENT ON COLUMN tb_schedule_configs.schedule_opt IS '排程選項（由系統定義）';
COMMENT ON COLUMN tb_schedule_configs.modify_time IS '最後修改時間';
COMMENT ON COLUMN tb_schedule_configs.status IS '狀態（例如: ENABLED/DISABLED）';
COMMENT ON COLUMN tb_schedule_configs.schedule_url IS '資料來源 URL（或入口 URL）';
COMMENT ON COLUMN tb_schedule_configs.schedule_mode IS '執行模式（API/FTP/WEBCRAWL/…）';
COMMENT ON COLUMN tb_schedule_configs.timeout_ms IS '逾時時間（毫秒）';
COMMENT ON COLUMN tb_schedule_configs.retry_count IS '重試次數';
COMMENT ON COLUMN tb_schedule_configs.retry_backoff_ms IS '重試間隔（毫秒）';
COMMENT ON COLUMN tb_schedule_configs.mapping_table IS '對應的 Mapping 設定表（資料落地欄位對應）';

-- ------------------------------------------------------------
-- 通用外部參數（強烈建議用這張表承接「爬蟲/HTTP」一切可變設定）
-- 特色：
-- - 可存放 Header、Cookie、QueryString、Body 模板、Proxy、Auth、User-Agent、JS 渲染等待條件等
-- - param_value 建議放字串；若為結構化資料（headers/cookies），用 jsonb 存於 param_json
-- - is_secret=true 的項目建議在程式端改讀取密碼庫/環境變數，資料庫只存參考鍵（例如 param_value = "ENV:TWSE_TOKEN"）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_schedule_externalparams (
    schedule_name  varchar(100) NOT NULL REFERENCES tb_schedule_configs(schedule_name) ON DELETE CASCADE,
    param_group    varchar(50)  NOT NULL DEFAULT 'HTTP',  -- 例如: HTTP/CRAWL/PAGING/PARSE/AUTH/FILES
    param_key      varchar(100) NOT NULL,                 -- 例如: method, response_format, user_agent, headers, cookies, proxy_url, wait_selector
    param_value    text,                                  -- 文字值（可放模板，如 {{YYYYMMDD}}）
    param_json     jsonb,                                 -- 結構化值（headers/cookies/抽取規則等）
    param_type     varchar(30) NOT NULL DEFAULT 'string',  -- string/int/bool/json/template/secret_ref
    is_secret      boolean     NOT NULL DEFAULT false,
    remark         text,
    modify_time    timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT pk_tb_schedule_externalparams PRIMARY KEY (schedule_name, param_group, param_key)
);

COMMENT ON TABLE tb_schedule_externalparams IS '排程外部參數（補強）：爬蟲/HTTP/解析/分頁/驗證等可變配置';
COMMENT ON COLUMN tb_schedule_externalparams.param_group IS '參數群組（HTTP/CRAWL/PAGING/PARSE/AUTH/FILES…）';
COMMENT ON COLUMN tb_schedule_externalparams.param_key IS '參數鍵（例如 headers、cookies、method、response_format）';
COMMENT ON COLUMN tb_schedule_externalparams.param_value IS '參數值（文字或模板）';
COMMENT ON COLUMN tb_schedule_externalparams.param_json IS '參數值（JSON 結構），例如 headers/cookies/抽取規則';
COMMENT ON COLUMN tb_schedule_externalparams.param_type IS '參數型別（string/int/bool/json/template/secret_ref）';
COMMENT ON COLUMN tb_schedule_externalparams.is_secret IS '是否為敏感資訊（建議只存參考鍵）';

CREATE INDEX IF NOT EXISTS ix_tb_schedule_external_params_group
ON tb_schedule_externalparams (param_group, param_key);

-- ------------------------------------------------------------
-- SESSION 設定檔（若你仍要保留原表）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_session_configs (
    schedule_name   varchar(100) PRIMARY KEY
        REFERENCES tb_schedule_configs(schedule_name) ON DELETE CASCADE,

    auth_value      varchar(200) NOT NULL,   -- 原 authorization/Anthorization：改安全欄位名
    send_type       varchar(50),             -- 發送方式(GET/POST)
    url             varchar(500),
    headers         jsonb                    -- Header 結構
);

COMMENT ON TABLE tb_session_configs IS 'SESSION 設定檔（原 TB_SESSION_CONFIGS）；建議逐步移轉至 tb_schedule_external_params';
COMMENT ON COLUMN tb_session_configs.auth_value IS '授權資訊（建議改存 ENV/密碼庫參考）';
COMMENT ON COLUMN tb_session_configs.send_type IS 'HTTP 方法（GET/POST/PUT…）';
COMMENT ON COLUMN tb_session_configs.headers IS 'HTTP Headers（JSON）';

-- ------------------------------------------------------------
-- WebCrawl 設定（爬蟲進階設定）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS webcrawl_configs (
    schedule_name         varchar(100) PRIMARY KEY REFERENCES tb_schedule_configs(schedule_name) ON DELETE CASCADE,
    url                   varchar(500),
    send_data             text,
    send_type             varchar(50),      -- 發送方式(GET/POST)
    batch_path            varchar(500),
    batch_file_name       varchar(500),
    data_replace_role     varchar(10),
    data_replace_day_count integer,
    is_cover              varchar(10),      -- 是/否（保留原意；若可改，建議改 boolean）
    skip_row              integer,
    skip_end_row          integer,

    -- ====== 補強：爬蟲常用外部參數（也可改存至 tb_schedule_external_params）======
    response_format       varchar(30) DEFAULT 'html',   -- html/json/csv/xlsx/pdf
    charset               varchar(40),                  -- 例如 utf-8、big5
    user_agent            varchar(300),
    accept_language       varchar(100),
    proxy_url             varchar(500),
    cookies               jsonb,                        -- { "foo": "bar" }
    headers               jsonb,                        -- { "User-Agent": "...", ... }
    js_render             boolean NOT NULL DEFAULT false, -- 是否需要 JS 渲染（Playwright/Selenium）
    wait_ms               integer,                      -- JS 渲染等待毫秒
    wait_selector         varchar(300),                 -- 等待元素（CSS selector）
    max_pages             integer,                      -- 分頁最大頁數（避免無限抓）
    rate_limit_ms         integer                       -- 每次請求間隔（毫秒）
);

COMMENT ON TABLE webcrawl_configs IS 'WebCrawl 設定（原 WebCrawl_CONFIGS）+ 補強外部參數';
COMMENT ON COLUMN webcrawl_configs.response_format IS '回應格式（html/json/csv/xlsx/pdf）';
COMMENT ON COLUMN webcrawl_configs.charset IS '回應編碼（utf-8/big5…）';
COMMENT ON COLUMN webcrawl_configs.user_agent IS 'User-Agent（若空則程式端給預設）';
COMMENT ON COLUMN webcrawl_configs.proxy_url IS '代理伺服器（http(s)://host:port）';
COMMENT ON COLUMN webcrawl_configs.cookies IS 'Cookie（JSON）';
COMMENT ON COLUMN webcrawl_configs.headers IS 'Headers（JSON）';
COMMENT ON COLUMN webcrawl_configs.js_render IS '是否需要 JS 渲染';
COMMENT ON COLUMN webcrawl_configs.wait_selector IS '等待頁面載入完成的 selector（CSS）';
COMMENT ON COLUMN webcrawl_configs.max_pages IS '最大分頁數（保護性上限）';

-- ------------------------------------------------------------
-- API 設定
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_api_configs (
    schedule_name         varchar(100) PRIMARY KEY REFERENCES tb_schedule_configs(schedule_name) ON DELETE CASCADE,
    api_url               varchar(500), -- URL
    send_data             text,         -- 發送資料（可放模板）
    send_type             varchar(50),  -- 發送方式(GET/POST)
    batch_path            varchar(500), -- 批次檔路徑
    batch_file_name       varchar(500), -- 批次檔名稱
    data_replace_role     varchar(10),  -- 資料替換規則(無/每天/每週/月/每年)
    data_replace_day_count integer,     -- 資料替換天數
    is_cover              varchar(10),  -- 是否覆蓋(是/否)
    skip_row              integer,
    skip_end_row          integer,

    -- ====== 補強：API 常用外部參數（也可改存至 tb_schedule_external_params）======
    response_format       varchar(30) DEFAULT 'json', -- json/csv/xlsx
    content_type          varchar(100),               -- 例如 application/json
    headers               jsonb,
    cookies               jsonb,
    auth_type             varchar(30),                -- none/bearer/basic/api_key
    auth_value            text,                       -- 建議存 ENV/密碼庫參考
    query_params          jsonb                        -- { "date": "{{YYYYMMDD}}", "response": "json" }
);

COMMENT ON TABLE tb_api_configs IS 'API 設定（原 TB_API_CONFIGS）+ 補強外部參數';
COMMENT ON COLUMN tb_api_configs.response_format IS '回應格式（json/csv/xlsx）';
COMMENT ON COLUMN tb_api_configs.headers IS 'HTTP Headers（JSON）';
COMMENT ON COLUMN tb_api_configs.query_params IS 'QueryString 參數（JSON；可放模板）';

-- ------------------------------------------------------------
-- FTP 設定
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_ftp_configs (
    schedule_name            varchar(100) PRIMARY KEY REFERENCES tb_schedule_configs(schedule_name) ON DELETE CASCADE,
    ftp_domain               varchar(50)  NOT NULL,
    ftp_ac                   varchar(50),
    ftp_p                    varchar(500),
    ftp_file_name            varchar(100),
    ftp_path                 varchar(500) NOT NULL,
    local_path               varchar(500) NOT NULL,
    local_file_name          varchar(500),
    mapping_type             varchar(50)  NOT NULL,
    file_name_replace_role   varchar(10),
    file_name_replace_day_count integer,
    skip_row                 integer,
    is_cover                 varchar(10)  NOT NULL,
    custom_csv_delimiter     varchar(4),
    is_need_excel_title      boolean
);

COMMENT ON TABLE tb_ftp_configs IS 'FTP 設定（原 TB_FTP_CONFIGS）';

-- ------------------------------------------------------------
-- 檔案設定
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_file_configs (
    schedule_name         varchar(100) PRIMARY KEY REFERENCES tb_schedule_configs(schedule_name) ON DELETE CASCADE,
    template_file_name    varchar(255),
    file_path             varchar(255),
    file_name             varchar(255),
    data_replace_role     varchar(10),
    data_replace_day_count integer
);

COMMENT ON TABLE tb_file_configs IS '檔案設定（原 TB_FILE_CONFIGS）';

-- ------------------------------------------------------------
-- 郵件設定
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_mail_configs (
    mailscriptname varchar(1000),
    create_time    timestamptz  NOT NULL,
    mailto         varchar(500) NOT NULL,
    ccto           varchar(500) NOT NULL,
    subject        varchar(1000),
    body           text,
    modify_time    timestamptz,
    mail_type      varchar(10),
    mail_to_name   varchar(100)
);

COMMENT ON TABLE tb_mail_configs IS '郵件設定（原 TB_MAIL_CONFIGS）';

-- ------------------------------------------------------------
-- Mapping 設定
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_mapping_configs (
    schedule_name varchar(100) PRIMARY KEY REFERENCES tb_schedule_configs(schedule_name) ON DELETE CASCADE,
    start_len     integer,
    end_len       integer,
    source_col    varchar(100),
    mapping_col   varchar(100),
    excelsheet    varchar(100),
    doc_index     integer,
    sort          integer
);

COMMENT ON TABLE tb_mapping_configs IS 'Mapping 設定（原 TB_MAPPING_CONFIGS）';

-- ------------------------------------------------------------
-- 使用者設定
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tuser (
    id          varchar(200) PRIMARY KEY,
    is_active   boolean,
    ad_login    boolean,
    salt        varchar(50),
    encrypt_pw  varchar(200),
    extension   varchar(20),
    rid         varchar(1020),
    email       varchar(250),
    user_name   varchar(50)
);

COMMENT ON TABLE tuser IS '使用者設定（原 TUSER）';

-- ------------------------------------------------------------
-- 發送郵件紀錄
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sendmail (
    mailid      varchar(36) PRIMARY KEY,
    create_time timestamptz  NOT NULL,
    mailto      varchar(500) NOT NULL,
    ccto        varchar(500),
    subject     varchar(1000),
    body        text,
    status      varchar(30)  NOT NULL,
    modify_time timestamptz,
    filepath    text,
    zipp        varchar(1000),
    mail_type   varchar(10),
    mail_to_name varchar(100)
);

COMMENT ON TABLE sendmail IS '發送郵件紀錄（原 SENDMAIL）';

-- ============================================================
-- 建議（非必要）：把常用爬蟲/HTTP 外部參數以「範本」方式塞進 tb_schedule_external_params
-- 你可以針對每個 schedule_name 覆寫以下 keys：
--   HTTP/method             -> GET | POST
--   HTTP/response_format    -> json | csv | html
--   HTTP/headers            -> JSON
--   HTTP/cookies            -> JSON
--   AUTH/auth_type          -> bearer | basic | api_key
--   AUTH/auth_value         -> ENV:XXXX (不要直接放 token)
--   CRAWL/js_render         -> true/false
--   CRAWL/wait_selector     -> '#content' 之類
--   PAGING/type             -> none | page_param | next_link | cursor
--   PAGING/page_param       -> 'page'
--   PAGING/page_start       -> 1
--   PAGING/page_size_param  -> 'pageSize'
--   PAGING/page_size        -> 50
--   PARSE/extract_rule      -> JSON（CSS/XPath/table index 等）
-- ============================================================
