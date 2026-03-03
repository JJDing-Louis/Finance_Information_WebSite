-- ============================================================================
-- TWSE / TPEX / ESB Raw Layer Tables (1:1 Mapping)
-- 規則：
-- 1) 不做正規化（Raw 落地表）
-- 2) 以官方網頁/介面欄位做 1 對 1 映射（欄位命名採英文金融術語）
-- 3) 每張表最後追加：
--    - web_date  : 網站資料時間（WebDate）
--    - data_date : 資料落地時間（DataDate）
-- DB：PostgreSQL
-- ============================================================================

-- 建議：若需統一 schema，可自行在前面加上：SET search_path TO <schema_name>, public;

-- ============================================================================
-- 1. TWSE_MI_INDEX：上市盤後成交（全市場）
-- 來源：TWSE /exchangeReport/MI_INDEX
-- ============================================================================
CREATE TABLE IF NOT EXISTS TWSE_MI_INDEX (
    trade_date              date,               -- 交易日期
    stock_code              varchar(10),        -- 證券代號
    stock_name              varchar(100),       -- 證券名稱
    trade_volume            bigint,             -- 成交股數
    trade_value             numeric(20,2),      -- 成交金額
    transaction_count       integer,            -- 成交筆數
    open_price              numeric(18,4),      -- 開盤價
    high_price              numeric(18,4),      -- 最高價
    low_price               numeric(18,4),      -- 最低價
    close_price             numeric(18,4),      -- 收盤價
    price_change            numeric(18,4),      -- 漲跌價差
    price_change_sign       varchar(5),         -- 漲跌方向（+ / - / X / 0 等；依網站格式）
    last_best_bid_price     numeric(18,4),      -- 最後揭示買價
    last_best_bid_volume    bigint,             -- 最後揭示買量
    last_best_ask_price     numeric(18,4),      -- 最後揭示賣價
    last_best_ask_volume    bigint,             -- 最後揭示賣量
    price_earnings_ratio    numeric(10,4),      -- 本益比（P/E Ratio）
    web_date                timestamptz,        -- 網站資料時間（WebDate）
    data_date               timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE TWSE_MI_INDEX IS '上市盤後成交（全市場）（Raw 落地表，欄位 1:1 對應官方網站資料）';
COMMENT ON COLUMN TWSE_MI_INDEX.trade_date IS '交易日期';
COMMENT ON COLUMN TWSE_MI_INDEX.stock_code IS '證券代號';
COMMENT ON COLUMN TWSE_MI_INDEX.stock_name IS '證券名稱';
COMMENT ON COLUMN TWSE_MI_INDEX.trade_volume IS '成交股數';
COMMENT ON COLUMN TWSE_MI_INDEX.trade_value IS '成交金額';
COMMENT ON COLUMN TWSE_MI_INDEX.transaction_count IS '成交筆數';
COMMENT ON COLUMN TWSE_MI_INDEX.open_price IS '開盤價';
COMMENT ON COLUMN TWSE_MI_INDEX.high_price IS '最高價';
COMMENT ON COLUMN TWSE_MI_INDEX.low_price IS '最低價';
COMMENT ON COLUMN TWSE_MI_INDEX.close_price IS '收盤價';
COMMENT ON COLUMN TWSE_MI_INDEX.price_change IS '漲跌價差';
COMMENT ON COLUMN TWSE_MI_INDEX.price_change_sign IS '漲跌方向（依網站字元）';
COMMENT ON COLUMN TWSE_MI_INDEX.last_best_bid_price IS '最後揭示買價';
COMMENT ON COLUMN TWSE_MI_INDEX.last_best_bid_volume IS '最後揭示買量';
COMMENT ON COLUMN TWSE_MI_INDEX.last_best_ask_price IS '最後揭示賣價';
COMMENT ON COLUMN TWSE_MI_INDEX.last_best_ask_volume IS '最後揭示賣量';
COMMENT ON COLUMN TWSE_MI_INDEX.price_earnings_ratio IS '本益比（P/E Ratio）';
COMMENT ON COLUMN TWSE_MI_INDEX.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN TWSE_MI_INDEX.data_date IS '資料落地時間（DataDate）';

-- ============================================================================
-- 2. TWSE_STOCK_DAY：個股月成交（單一股票）
-- 來源：TWSE /exchangeReport/STOCK_DAY
-- ============================================================================
CREATE TABLE IF NOT EXISTS TWSE_STOCK_DAY (
    trade_date          date,               -- 交易日期
    stock_code          varchar(10),        -- 股票代碼
    trade_volume        bigint,             -- 成交股數
    trade_value         numeric(20,2),      -- 成交金額
    open_price          numeric(18,4),      -- 開盤價
    high_price          numeric(18,4),      -- 最高價
    low_price           numeric(18,4),      -- 最低價
    close_price         numeric(18,4),      -- 收盤價
    price_change        numeric(18,4),      -- 漲跌價差
    transaction_count   integer,            -- 成交筆數
    web_date            timestamptz,        -- 網站資料時間（WebDate）
    data_date           timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE TWSE_STOCK_DAY IS '個股月成交（單一股票）（Raw 落地表，欄位 1:1 對應官方網站資料）';
COMMENT ON COLUMN TWSE_STOCK_DAY.trade_date IS '交易日期';
COMMENT ON COLUMN TWSE_STOCK_DAY.stock_code IS '股票代碼';
COMMENT ON COLUMN TWSE_STOCK_DAY.trade_volume IS '成交股數';
COMMENT ON COLUMN TWSE_STOCK_DAY.trade_value IS '成交金額';
COMMENT ON COLUMN TWSE_STOCK_DAY.open_price IS '開盤價';
COMMENT ON COLUMN TWSE_STOCK_DAY.high_price IS '最高價';
COMMENT ON COLUMN TWSE_STOCK_DAY.low_price IS '最低價';
COMMENT ON COLUMN TWSE_STOCK_DAY.close_price IS '收盤價';
COMMENT ON COLUMN TWSE_STOCK_DAY.price_change IS '漲跌價差';
COMMENT ON COLUMN TWSE_STOCK_DAY.transaction_count IS '成交筆數';
COMMENT ON COLUMN TWSE_STOCK_DAY.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN TWSE_STOCK_DAY.data_date IS '資料落地時間（DataDate）';

-- ============================================================================
-- 3. TWSE_T86：三大法人（上市）
-- 來源：TWSE /fund/T86
-- ============================================================================
CREATE TABLE IF NOT EXISTS TWSE_T86 (
    trade_date                  date,               -- 交易日期
    stock_code                  varchar(10),        -- 股票代碼
    stock_name                  varchar(100),       -- 股票名稱
    foreign_investor_buy        bigint,             -- 外資買進股數
    foreign_investor_sell       bigint,             -- 外資賣出股數
    foreign_investor_net        bigint,             -- 外資買賣超
    investment_trust_buy        bigint,             -- 投信買進股數
    investment_trust_sell       bigint,             -- 投信賣出股數
    investment_trust_net        bigint,             -- 投信買賣超
    dealer_buy                  bigint,             -- 自營商買進股數
    dealer_sell                 bigint,             -- 自營商賣出股數
    dealer_net                  bigint,             -- 自營商買賣超
    total_net                   bigint,             -- 三大法人合計買賣超
    web_date                    timestamptz,        -- 網站資料時間（WebDate）
    data_date                   timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE TWSE_T86 IS '三大法人（上市）（Raw 落地表，欄位 1:1 對應官方網站資料）';
COMMENT ON COLUMN TWSE_T86.trade_date IS '交易日期';
COMMENT ON COLUMN TWSE_T86.stock_code IS '股票代碼';
COMMENT ON COLUMN TWSE_T86.stock_name IS '股票名稱';
COMMENT ON COLUMN TWSE_T86.foreign_investor_buy IS '外資買進股數';
COMMENT ON COLUMN TWSE_T86.foreign_investor_sell IS '外資賣出股數';
COMMENT ON COLUMN TWSE_T86.foreign_investor_net IS '外資買賣超';
COMMENT ON COLUMN TWSE_T86.investment_trust_buy IS '投信買進股數';
COMMENT ON COLUMN TWSE_T86.investment_trust_sell IS '投信賣出股數';
COMMENT ON COLUMN TWSE_T86.investment_trust_net IS '投信買賣超';
COMMENT ON COLUMN TWSE_T86.dealer_buy IS '自營商買進股數';
COMMENT ON COLUMN TWSE_T86.dealer_sell IS '自營商賣出股數';
COMMENT ON COLUMN TWSE_T86.dealer_net IS '自營商買賣超';
COMMENT ON COLUMN TWSE_T86.total_net IS '三大法人合計買賣超';
COMMENT ON COLUMN TWSE_T86.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN TWSE_T86.data_date IS '資料落地時間（DataDate）';

-- ============================================================================
-- 4. TWSE_MI_MARGN：融資融券（上市）
-- 來源：TWSE /exchangeReport/MI_MARGN
-- ============================================================================
CREATE TABLE IF NOT EXISTS TWSE_MI_MARGN (
    trade_date              date,               -- 交易日期
    stock_code              varchar(10),        -- 股票代碼
    margin_purchase         bigint,             -- 融資餘額
    margin_purchase_change  bigint,             -- 融資增減
    short_sale              bigint,             -- 融券餘額
    short_sale_change       bigint,             -- 融券增減
    margin_quota            bigint,             -- 融資限額
    short_sale_quota        bigint,             -- 融券限額
    web_date                timestamptz,        -- 網站資料時間（WebDate）
    data_date               timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE TWSE_MI_MARGN IS '融資融券（上市）（Raw 落地表，欄位 1:1 對應官方網站資料）';
COMMENT ON COLUMN TWSE_MI_MARGN.trade_date IS '交易日期';
COMMENT ON COLUMN TWSE_MI_MARGN.stock_code IS '股票代碼';
COMMENT ON COLUMN TWSE_MI_MARGN.margin_purchase IS '融資餘額';
COMMENT ON COLUMN TWSE_MI_MARGN.margin_purchase_change IS '融資增減';
COMMENT ON COLUMN TWSE_MI_MARGN.short_sale IS '融券餘額';
COMMENT ON COLUMN TWSE_MI_MARGN.short_sale_change IS '融券增減';
COMMENT ON COLUMN TWSE_MI_MARGN.margin_quota IS '融資限額';
COMMENT ON COLUMN TWSE_MI_MARGN.short_sale_quota IS '融券限額';
COMMENT ON COLUMN TWSE_MI_MARGN.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN TWSE_MI_MARGN.data_date IS '資料落地時間（DataDate）';

-- ============================================================================
-- 5. TPEX_DAILY_CLOSE_QUOTES：上櫃盤後成交
-- 來源：TPEX /web/stock/aftertrading/daily_close_quotes/stk_quote_result.php
-- ============================================================================
CREATE TABLE IF NOT EXISTS TPEX_DAILY_CLOSE_QUOTES (
    trade_date          date,               -- 交易日期
    stock_code          varchar(10),        -- 股票代碼
    stock_name          varchar(100),       -- 股票名稱
    close_price         numeric(18,4),      -- 收盤價
    price_change        numeric(18,4),      -- 漲跌價差
    open_price          numeric(18,4),      -- 開盤價
    high_price          numeric(18,4),      -- 最高價
    low_price           numeric(18,4),      -- 最低價
    trade_volume        bigint,             -- 成交量（股數）
    trade_value         numeric(20,2),      -- 成交金額
    transaction_count   integer,            -- 成交筆數
    web_date            timestamptz,        -- 網站資料時間（WebDate）
    data_date           timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE TPEX_DAILY_CLOSE_QUOTES IS '上櫃盤後成交行情（Raw 落地表，欄位 1:1 對應官方網站資料）';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.trade_date IS '交易日期';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.stock_code IS '股票代碼';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.stock_name IS '股票名稱';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.close_price IS '收盤價';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.price_change IS '漲跌價差';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.open_price IS '開盤價';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.high_price IS '最高價';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.low_price IS '最低價';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.trade_volume IS '成交量（股數）';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.trade_value IS '成交金額';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.transaction_count IS '成交筆數';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN TPEX_DAILY_CLOSE_QUOTES.data_date IS '資料落地時間（DataDate）';

-- ============================================================================
-- 6. TPEX_INSTITUTIONAL_TRADES：上櫃三大法人（日）
-- 來源：TPEX /web/stock/3insti/daily_trade/3itrade_hedge_result.php
-- ============================================================================
CREATE TABLE IF NOT EXISTS TPEX_INSTITUTIONAL_TRADES (
    trade_date              date,               -- 交易日期
    stock_code              varchar(10),        -- 股票代碼
    foreign_investor_net    bigint,             -- 外資買賣超
    investment_trust_net    bigint,             -- 投信買賣超
    dealer_net              bigint,             -- 自營商買賣超
    total_net               bigint,             -- 三大法人合計買賣超
    web_date                timestamptz,        -- 網站資料時間（WebDate）
    data_date               timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE TPEX_INSTITUTIONAL_TRADES IS '上櫃三大法人買賣超（日報）（Raw 落地表）';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.trade_date IS '交易日期';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.stock_code IS '股票代碼';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.foreign_investor_net IS '外資買賣超';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.investment_trust_net IS '投信買賣超';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.dealer_net IS '自營商買賣超';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.total_net IS '三大法人合計買賣超';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN TPEX_INSTITUTIONAL_TRADES.data_date IS '資料落地時間（DataDate）';

-- ============================================================================
-- 7. TPEX_MARGIN_BALANCES：上櫃融資融券餘額
-- 來源：TPEX /web/stock/margin_trading/margin_balance/margin_bal_result.php
-- ============================================================================
CREATE TABLE IF NOT EXISTS TPEX_MARGIN_BALANCES (
    trade_date              date,               -- 交易日期
    stock_code              varchar(10),        -- 股票代碼
    margin_purchase         bigint,             -- 融資餘額
    margin_purchase_change  bigint,             -- 融資增減
    short_sale              bigint,             -- 融券餘額
    short_sale_change       bigint,             -- 融券增減
    web_date                timestamptz,        -- 網站資料時間（WebDate）
    data_date               timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE TPEX_MARGIN_BALANCES IS '上櫃融資融券餘額（Raw 落地表）';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.trade_date IS '交易日期';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.stock_code IS '股票代碼';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.margin_purchase IS '融資餘額';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.margin_purchase_change IS '融資增減';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.short_sale IS '融券餘額';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.short_sale_change IS '融券增減';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN TPEX_MARGIN_BALANCES.data_date IS '資料落地時間（DataDate）';

-- ============================================================================
-- 8. ESB_DAILY_CLOSE_QUOTES：興櫃盤後成交
-- 來源：TPEX ESB /web/emergingstock/aftertrading/daily_close_quotes/stk_quote_result.php
-- ============================================================================
CREATE TABLE IF NOT EXISTS ESB_DAILY_CLOSE_QUOTES (
    trade_date          date,               -- 交易日期
    stock_code          varchar(10),        -- 股票代碼
    stock_name          varchar(100),       -- 股票名稱
    close_price         numeric(18,4),      -- 收盤價
    price_change        numeric(18,4),      -- 漲跌價差
    trade_volume        bigint,             -- 成交量（股數）
    trade_value         numeric(20,2),      -- 成交金額
    transaction_count   integer,            -- 成交筆數
    web_date            timestamptz,        -- 網站資料時間（WebDate）
    data_date           timestamptz         -- 資料落地時間（DataDate）
);

COMMENT ON TABLE ESB_DAILY_CLOSE_QUOTES IS '興櫃盤後成交行情（Raw 落地表）';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.trade_date IS '交易日期';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.stock_code IS '股票代碼';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.stock_name IS '股票名稱';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.close_price IS '收盤價';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.price_change IS '漲跌價差';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.trade_volume IS '成交量（股數）';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.trade_value IS '成交金額';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.transaction_count IS '成交筆數';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.web_date IS '網站資料時間（WebDate）';
COMMENT ON COLUMN ESB_DAILY_CLOSE_QUOTES.data_date IS '資料落地時間（DataDate）';
