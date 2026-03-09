class BaseHandler:
    def execute(self, run_id: str, mapping_table: str, schedule_config: dict) -> dict:
        raise NotImplementedError("請實作 execute 方法")
