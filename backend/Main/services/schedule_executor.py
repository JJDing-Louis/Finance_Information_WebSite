import traceback
import uuid
from dataclasses import dataclass

from django.utils import timezone

from Main.models import ScheduleLog
from Main.registry import resolve_handler
from Share.Tool.schedule_fun import ScheduleFun


@dataclass
class ExecuteResult:
    success: bool
    run_id: str
    message: str
    data: dict | None = None


def _pick(row: dict, *keys: str):
    for key in keys:
        if key in row:
            return row[key]
    return None


def _build_schedule_config(schedule_row: dict) -> dict:
    schedule_fun = ScheduleFun()
    schedule_name = _pick(schedule_row, "schedule_name", "scheduleName")
    schedule_mode = str(_pick(schedule_row, "schedule_mode", "scheduleMode") or "").upper()
    mapping_table = _pick(schedule_row, "mapping_table", "mappingTable") or ""

    config = {
        "schedule_name": schedule_name,
        "schedule_opt": _pick(schedule_row, "schedule_opt", "scheduleOpt"),
        "status": _pick(schedule_row, "status"),
        "schedule_url": _pick(schedule_row, "schedule_url", "scheduleUrl"),
        "schedule_mode": schedule_mode,
        "timeout_ms": _pick(schedule_row, "timeout_ms", "timeoutMs"),
        "retry_count": _pick(schedule_row, "retry_count", "retryCount"),
        "retry_backoff_ms": _pick(schedule_row, "retry_backoff_ms", "retryBackoffMs"),
        "mapping_table": mapping_table,
        "modify_time": _pick(schedule_row, "modify_time", "modifyTime"),
        "mapping_configs": schedule_fun.get_tb_mapping_configs(schedule_name),
    }

    if schedule_mode in ("FTP", "FTPUPLOAD"):
        config["mode_config"] = schedule_fun.get_tb_ftp_configs(schedule_name)
    elif schedule_mode in ("API", "SPAPI"):
        config["mode_config"] = schedule_fun.get_tb_api_configs(schedule_name)
    elif schedule_mode == "TRANSFERTABLE":
        config["mode_config"] = schedule_fun.get_table_transfer_config(schedule_name)
    elif schedule_mode == "FILETEMPLATEEXPORT":
        config["mode_config"] = schedule_fun.get_tb_file_configs(schedule_name)
    else:
        config["mode_config"] = {}

    return config


def schedule_implement(schedule_name: str) -> ExecuteResult:
    run_id = uuid.uuid4().hex
    started_at = timezone.now()

    log = ScheduleLog.objects.create(
        run_id=run_id,
        schedule_name=schedule_name,
        status="RUNNING",
        started_at=started_at,
        message="開始執行",
    )

    try:
        schedule_fun = ScheduleFun()
        schedule_row = schedule_fun.get_tb_schedule_config(schedule_name)
        if not schedule_row:
            raise ValueError(f"Not Match {schedule_name}")
        status = str(_pick(schedule_row, "status") or "").upper()
        if status not in ("ENABLED", "ON"):
            raise ValueError(f"Schedule {schedule_name} is disabled")

        schedule_mode = str(_pick(schedule_row, "schedule_mode", "scheduleMode") or "")
        mapping_table = str(_pick(schedule_row, "mapping_table", "mappingTable") or "")
        schedule_config = _build_schedule_config(schedule_row)
        handler = resolve_handler(schedule_mode, mapping_table)
        result = handler.execute(run_id, mapping_table, schedule_config) or {}

        log.schedule_mode = schedule_mode
        log.mapping_table = mapping_table
        log.status = "SUCCESS"
        log.ended_at = timezone.now()
        log.message = "執行成功"
        log.result_json = result
        log.save(
            update_fields=[
                "schedule_mode",
                "mapping_table",
                "status",
                "ended_at",
                "message",
                "result_json",
            ]
        )

        return ExecuteResult(success=True, run_id=run_id, message="Success", data=result)
    except Exception as ex:
        err = f"{ex}\n{traceback.format_exc()}"
        log.status = "NG"
        log.ended_at = timezone.now()
        log.message = err[:4000]
        log.save(update_fields=["status", "ended_at", "message"])
        return ExecuteResult(
            success=False,
            run_id=run_id,
            message=f"Fail ! {schedule_name} 執行錯誤",
            data={"error": str(ex)},
        )
