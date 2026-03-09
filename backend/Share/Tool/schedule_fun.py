from __future__ import annotations

from Share.DBTool.factory import create_db
from Share.DBTool.settings_provider import EnvDbSettings


class ScheduleFun:
    """讀取排程相關外部設定表。"""

    def __init__(self, db_name: str = "POSTGRESQL") -> None:
        self.db_name = db_name
        self.env = EnvDbSettings()

    def _fetch_all(self, sql: str, params: dict | None = None) -> list[dict]:
        db_tool = create_db(self.db_name, self.env)
        with db_tool as db:
            rows = db.execute(sql, params or {})
        return [dict(row) for row in rows]

    def _fetch_one(self, sql: str, params: dict | None = None) -> dict:
        rows = self._fetch_all(sql, params)
        return rows[0] if rows else {}

    def get_tb_schedule_configs(
        self,
        schedule_name: str | None = None,
        schedule_mode: str | None = None,
    ) -> list[dict]:
        conditions: list[str] = []
        params: dict = {}

        if schedule_mode:
            conditions.append("schedule_mode = :schedule_mode")
            params["schedule_mode"] = schedule_mode
        if schedule_name:
            conditions.append("UPPER(schedule_name) LIKE UPPER(:like_name)")
            params["like_name"] = f"%{schedule_name}%"

        where_clause = f"WHERE {' AND '.join(conditions)}" if conditions else ""
        sql = f"""
            SELECT *
            FROM tb_schedule_configs
            {where_clause}
        """
        return self._fetch_all(sql, params)

    def get_tb_schedule_config(self, schedule_name: str) -> dict:
        sql = """
            SELECT *
            FROM tb_schedule_configs
            WHERE UPPER(schedule_name) = UPPER(:schedule_name)
            LIMIT 1
        """
        return self._fetch_one(sql, {"schedule_name": schedule_name})

    def get_tb_ftp_configs(self, schedule_name: str) -> dict:
        sql = """
            SELECT *
            FROM tb_ftp_configs
            WHERE UPPER(schedule_name) = UPPER(:schedule_name)
            LIMIT 1
        """
        return self._fetch_one(sql, {"schedule_name": schedule_name})

    def get_tb_api_configs(self, schedule_name: str) -> dict:
        sql = """
            SELECT *
            FROM tb_api_configs
            WHERE UPPER(schedule_name) = UPPER(:schedule_name)
            LIMIT 1
        """
        return self._fetch_one(sql, {"schedule_name": schedule_name})

    def get_table_transfer_config(self, schedule_name: str) -> dict:
        if not schedule_name:
            raise ValueError("ScheduleName is empty")

        sql = """
            SELECT *
            FROM tb_tabletransferconfig
            WHERE UPPER(schedule_name) = UPPER(:schedule_name)
            LIMIT 1
        """
        row = self._fetch_one(sql, {"schedule_name": schedule_name})
        if not row:
            raise ValueError(f"ScheduleName: {schedule_name} is not found in tb_tabletransferconfig")
        return row

    def get_tb_mapping_configs(
        self,
        schedule_name: str,
        mapping_col: str | None = None,
        excelsheet: int | None = None,
    ) -> list[dict]:
        if mapping_col is None or excelsheet is None:
            sql = """
                SELECT *
                FROM tb_mapping_configs
                WHERE schedule_name = :schedule_name
            """
            return self._fetch_all(sql, {"schedule_name": schedule_name})

        sql = """
            SELECT *
            FROM tb_mapping_configs
            WHERE schedule_name = :schedule_name
              AND mapping_col = :mapping_col
              AND excelsheet = :excelsheet
        """
        return self._fetch_all(
            sql,
            {
                "schedule_name": schedule_name,
                "mapping_col": mapping_col,
                "excelsheet": excelsheet,
            },
        )

    def get_tb_file_configs(self, schedule_name: str) -> dict:
        sql = """
            SELECT *
            FROM tb_file_configs
            WHERE UPPER(schedule_name) = UPPER(:schedule_name)
            LIMIT 1
        """
        return self._fetch_one(sql, {"schedule_name": schedule_name})
