from __future__ import annotations

import os
from typing import Any


class EnvDbSettings:
    """
    Read database settings from OS environment / .env using a namespace convention.

    Key convention (double-underscore namespaces):
      DB__<NAME>__TYPE
      DB__<NAME>__URL          (SQL databases via SQLAlchemy)
      DB__<NAME>__URI          (Mongo)
      DB__<NAME>__DB           (Mongo)

    Common TYPE values:
      - sqlite
      - mssql
      - postgres / postgresql
      - mysql
      - mongo / mongodb

    Notes:
      - `.env` itself has no nesting; this naming scheme simulates grouping.
      - In production (e.g., Render), prefer OS env vars over local `.env`.
    """

    def __init__(self, prefix: str = "DB") -> None:
        self.prefix = prefix

    def env_key(self, name: str, key: str) -> str:
        return f"{self.prefix}__{name.upper()}__{key.upper()}"

    def get(self, name: str, key: str, default: Any = None) -> Any:
        k = self.env_key(name, key)
        v = os.getenv(k)
        return v if (v is not None and v != "") else default

    def require(self, name: str, key: str) -> str:
        v = self.get(name, key, None)
        if v is None or str(v).strip() == "":
            raise ValueError(f"Missing env var: {self.env_key(name, key)}")
        return str(v)
