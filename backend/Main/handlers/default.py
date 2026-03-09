from Main.handlers.base import BaseHandler


class DefaultHandler(BaseHandler):
    def execute(self, run_id: str, mapping_table: str, schedule_config: dict) -> dict:
        return {
            "run_id": run_id,
            "mapping_table": mapping_table,
            "schedule_name": schedule_config.get("schedule_name", ""),
            "schedule_mode": schedule_config.get("schedule_mode", ""),
            "message": "DefaultHandler 已執行，請替換為實際商業邏輯",
        }
