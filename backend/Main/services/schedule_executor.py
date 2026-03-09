import traceback
import uuid
from dataclasses import dataclass

from django.utils import timezone

from Main.models import ScheduleConfig, ScheduleLog
from Main.registry import resolve_handler


@dataclass
class ExecuteResult:
    success: bool
    run_id: str
    message: str
    data: dict | None = None


def _build_schedule_config(schedule: ScheduleConfig) -> dict:
    return {
        "schedule_name": schedule.schedule_name,
        "schedule_opt": schedule.schedule_opt,
        "status": schedule.status,
        "schedule_url": schedule.schedule_url,
        "schedule_mode": schedule.schedule_mode,
        "timeout_ms": schedule.timeout_ms,
        "retry_count": schedule.retry_count,
        "retry_backoff_ms": schedule.retry_backoff_ms,
        "mapping_table": schedule.mapping_table,
        "modify_time": schedule.modify_time.isoformat() if schedule.modify_time else None,
    }


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
        schedule = (
            ScheduleConfig.objects.filter(
                schedule_name=schedule_name,
                status__iexact="ENABLED",
            ).first()
        )
        if not schedule:
            raise ValueError(f"Not Match {schedule_name}")

        schedule_config = _build_schedule_config(schedule)
        handler = resolve_handler(schedule.schedule_mode, schedule.mapping_table)
        result = handler.execute(run_id, schedule.mapping_table, schedule_config) or {}

        log.schedule_mode = schedule.schedule_mode
        log.mapping_table = schedule.mapping_table
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
