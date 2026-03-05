from pymongo import MongoClient
from django.conf import settings

_client = None

def get_mongo_client() -> MongoClient:
    global _client
    if _client is None:
        if not settings.MONGODB_URI:
            raise RuntimeError("MONGODB_URI is empty. Check backend/.env and settings.py load_dotenv.")
        _client = MongoClient(settings.MONGODB_URI)
    return _client

def get_mongo_db():
    client = get_mongo_client()
    return client[settings.MONGODB_DB_NAME]