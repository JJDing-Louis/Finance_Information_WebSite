"""
Neon PostgreSQL 連線測試腳本
"""

import os
from pathlib import Path
from dotenv import load_dotenv
import psycopg

# 讀取專案執行更目錄
BASE_DIR = Path(__file__).resolve().parent.parent  # backend/
print(BASE_DIR)

# 載入 .env
load_dotenv(BASE_DIR / ".env")

uri = os.getenv("DB__POSTGRESQL__URL")
print("DB__POSTGRESQL__URL =", uri)

# 連線 Neon
conn = psycopg.connect(uri)

# 測試 query
with conn.cursor() as cur:
    cur.execute("SELECT 1;")
    result = cur.fetchone()
    print("query result =", result)

print("Neon DB connection ok")