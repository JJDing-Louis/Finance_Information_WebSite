from __future__ import annotations

from typing import Any, Dict, List, Optional, Tuple

from .base import BaseConnectionTool
from settings_provider import EnvDbSettings

try:
    from pymongo import MongoClient  # type: ignore
except Exception:  # pragma: no cover
    MongoClient = None  # type: ignore


class MongoConnectionTool(BaseConnectionTool):
    """
    MongoDB connection tool.

    Required env keys:
      DB__<NAME>__URI
      DB__<NAME>__DB
    """

    def __init__(self, name: str, env: EnvDbSettings) -> None:
        super().__init__(name)
        self.env = env
        self.client = None
        self.db = None

    def connect(self) -> None:
        if MongoClient is None:
            raise ImportError("pymongo is not installed. Run: pip install pymongo")

        uri = self.env.require(self.name, "URI")
        db_name = self.env.require(self.name, "DB")

        self.client = MongoClient(uri)
        self.db = self.client[db_name]

    def close(self) -> None:
        if self.client is not None:
            try:
                self.client.close()
            except Exception:
                pass
        self.client = None
        self.db = None

    # --- CRUD (Mongo) ---
    def insert_one(self, collection: str, doc: Dict[str, Any]) -> str:
        if self.db is None:
            raise RuntimeError("Not connected.")
        r = self.db[collection].insert_one(doc)
        return str(r.inserted_id)

    def find(
        self,
        collection: str,
        filter: Optional[Dict[str, Any]] = None,
        projection: Optional[Dict[str, int]] = None,
        limit: Optional[int] = None,
        sort: Optional[List[Tuple[str, int]]] = None,
    ) -> List[Dict[str, Any]]:
        if self.db is None:
            raise RuntimeError("Not connected.")
        cursor = self.db[collection].find(filter or {}, projection)
        if sort:
            cursor = cursor.sort(sort)
        if limit is not None:
            cursor = cursor.limit(int(limit))

        docs: List[Dict[str, Any]] = []
        for d in cursor:
            if "_id" in d:
                d["_id"] = str(d["_id"])
            docs.append(d)
        return docs

    def update_many(self, collection: str, filter: Dict[str, Any], update: Dict[str, Any]) -> int:
        if self.db is None:
            raise RuntimeError("Not connected.")
        r = self.db[collection].update_many(filter, {"$set": update})
        return int(r.modified_count)

    def delete_many(self, collection: str, filter: Dict[str, Any]) -> int:
        if self.db is None:
            raise RuntimeError("Not connected.")
        r = self.db[collection].delete_many(filter)
        return int(r.deleted_count)
