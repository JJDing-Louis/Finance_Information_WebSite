"""
MongoDB連線測試腳本
"""
import os
from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient

# 讀取專案執行更目錄
BASE_DIR = Path(__file__).resolve().parent.parent  # backend/
print(BASE_DIR)
load_dotenv(BASE_DIR / ".env")

uri = os.getenv("DB__MONGO__URI")
print("DB__MONGO__URI =", uri)

client = MongoClient(uri, serverSelectionTimeoutMS=5000)
client.admin.command("ping")
print("ping ok")