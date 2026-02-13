import os
from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient

BASE_DIR = Path(__file__).resolve().parent  # backend/
load_dotenv(BASE_DIR / ".env")

uri = os.getenv("MONGODB_URI")
print("MONGODB_URI =", uri)

client = MongoClient(uri, serverSelectionTimeoutMS=5000)
client.admin.command("ping")
print("ping ok")