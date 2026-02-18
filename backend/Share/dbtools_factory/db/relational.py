from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Dict, Optional

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

from .base import BaseConnectionTool
from settings_provider import EnvDbSettings


class RelationalConnectionTool(BaseConnectionTool, ABC):
    """
    Base class for relational DBs (SQLite / MSSQL / Postgres / MySQL ...) using SQLAlchemy.

    Provides:
      - connect/close lifecycle
      - execute(sql, params)
      - CRUD sugar: insert/update/delete/select

    Important:
      - This is a thin convenience layer. For complex queries, use execute() with a parameterized SQL.
      - Dialect differences (TOP/LIMIT etc.) are not abstracted here.
    """

    def __init__(self, name: str, env: EnvDbSettings) -> None:
        super().__init__(name)
        self.env = env
        self.engine: Optional[Engine] = None

    @abstractmethod
    def _get_url(self) -> str: ...

    def connect(self) -> None:
        url = self._get_url()
        self.engine = create_engine(url, pool_pre_ping=True, future=True)

    def close(self) -> None:
        if self.engine is not None:
            self.engine.dispose()
            self.engine = None

    def execute(self, sql: str, params: Optional[Dict[str, Any]] = None):
        if self.engine is None:
            raise RuntimeError("Not connected. Use 'with ...' or call connect().")
        with self.engine.begin() as conn:
            r = conn.execute(text(sql), params or {})
            if sql.lstrip().lower().startswith("select"):
                return r.mappings().all()
            return r.rowcount

    # --- CRUD sugar (SQL) ---
    def insert(self, table: str, data: Dict[str, Any]):
        cols = ", ".join(data.keys())
        vals = ", ".join([f":{k}" for k in data.keys()])
        return self.execute(f"INSERT INTO {table} ({cols}) VALUES ({vals})", data)

    def update(self, table: str, data: Dict[str, Any], where: Dict[str, Any]):
        set_clause = ", ".join([f"{k} = :u_{k}" for k in data.keys()])
        where_clause = " AND ".join([f"{k} = :w_{k}" for k in where.keys()])
        params = {f"u_{k}": v for k, v in data.items()}
        params.update({f"w_{k}": v for k, v in where.items()})
        return self.execute(f"UPDATE {table} SET {set_clause} WHERE {where_clause}", params)

    def delete(self, table: str, where: Dict[str, Any]):
        where_clause = " AND ".join([f"{k} = :{k}" for k in where.keys()])
        return self.execute(f"DELETE FROM {table} WHERE {where_clause}", where)

    def select(self, table: str, where: Optional[Dict[str, Any]] = None):
        params: Dict[str, Any] = {}
        where_clause = ""
        if where:
            where_clause = " WHERE " + " AND ".join([f"{k} = :{k}" for k in where.keys()])
            params = where
        return self.execute(f"SELECT * FROM {table}{where_clause}", params)


class SQLiteConnectionTool(RelationalConnectionTool):
    """TYPE=sqlite, expects DB__<NAME>__URL like sqlite:///..."""
    def _get_url(self) -> str:
        return self.env.require(self.name, "URL")


class MSSQLConnectionTool(RelationalConnectionTool):
    """TYPE=mssql, expects DB__<NAME>__URL like mssql+pyodbc://..."""
    def _get_url(self) -> str:
        return self.env.require(self.name, "URL")


class PostgresConnectionTool(RelationalConnectionTool):
    """TYPE=postgres, expects DB__<NAME>__URL like postgresql+psycopg://..."""
    def _get_url(self) -> str:
        return self.env.require(self.name, "URL")


class MySQLConnectionTool(RelationalConnectionTool):
    """TYPE=mysql, expects DB__<NAME>__URL like mysql+pymysql://..."""
    def _get_url(self) -> str:
        return self.env.require(self.name, "URL")
