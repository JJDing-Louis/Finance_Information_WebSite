from __future__ import annotations

from typing import Union

from settings_provider import EnvDbSettings
from db.relational import (
    SQLiteConnectionTool,
    MSSQLConnectionTool,
    PostgresConnectionTool,
    MySQLConnectionTool,
)
from db.nonrelational import MongoConnectionTool

DbTool = Union[
    SQLiteConnectionTool,
    MSSQLConnectionTool,
    PostgresConnectionTool,
    MySQLConnectionTool,
    MongoConnectionTool,
]


def create_db(name: str, env: EnvDbSettings) -> DbTool:
    """
    Factory that creates a DB tool based on:
      DB__<NAME>__TYPE

    TYPE values (case-insensitive):
      - sqlite
      - mssql
      - postgres / postgresql
      - mysql
      - mongo / mongodb
    """
    t = (env.get(name, "TYPE", "") or "").strip().lower()
    if not t:
        raise ValueError(f"Missing DB__{name.upper()}__TYPE")

    if t == "sqlite":
        return SQLiteConnectionTool(name, env)
    if t == "mssql":
        return MSSQLConnectionTool(name, env)
    if t in ("postgres", "postgresql"):
        return PostgresConnectionTool(name, env)
    if t == "mysql":
        return MySQLConnectionTool(name, env)
    if t in ("mongo", "mongodb"):
        return MongoConnectionTool(name, env)

    raise ValueError(f"Unknown DB type for {name}: {t}")
