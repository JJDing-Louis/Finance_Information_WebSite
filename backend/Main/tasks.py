import os
from datetime import datetime

import requests
from celery import shared_task
from django.utils import timezone

from Share.Tool.schedule_fun import ScheduleFun


def _match_field(expr: str, value: int, min_value: int) -> bool:
    parts = [p.strip() for p in expr.split(",") if p.strip()]
    for part in parts:
        if part == "*":
            return True
        if part.startswith("*/"):
            step = int(part[2:])
            if step > 0 and (value - min_value) % step == 0:
                return True
            continue
        if "-" in part:
            start, end = part.split("-", 1)
            if int(start) <= value <= int(end):
                return True
            continue
        if int(part) == value:
            return True
    return False


def _is_due(schedule_opt: str, now_dt: datetime) -> bool:
    cron = (schedule_opt or "").strip()
    parts = cron.split()
    if len(parts) != 5:
        return False

    minute, hour, day_of_month, month, day_of_week = parts
    cron_weekday = (now_dt.weekday() + 1) % 7

    return (
        _match_field(minute, now_dt.minute, 0)
        and _match_field(hour, now_dt.hour, 0)
        and _match_field(day_of_month, now_dt.day, 1)
        and _match_field(month, now_dt.month, 1)
        and _match_field(day_of_week, cron_weekday, 0)
    )


@shared_task(bind=True)
def run_schedule_by_name(self, schedule_name: str):
    schedule_fun = ScheduleFun()
    schedule_row = schedule_fun.get_tb_schedule_config(schedule_name)
    if not schedule_row:
        return {
            "success": False,
            "schedule_name": schedule_name,
            "message": "Not Match schedule",
        }

    timeout_ms = int(schedule_row.get("timeout_ms") or 15000)
    retry_count = int(schedule_row.get("retry_count") or 2)
    retry_backoff_ms = int(schedule_row.get("retry_backoff_ms") or 500)

    base_url = (os.getenv("SCHEDULE_ENTRY_BASE_URL") or "http://127.0.0.1:8000").rstrip("/")
    token = (os.getenv("SCHEDULE_ENTRY_TOKEN") or "").strip()
    params = {
        "scheduleName": schedule_name,
    }
    if token:
        params["token"] = token

    timeout_seconds = max(timeout_ms / 1000.0, 1.0)
    url = f"{base_url}/main/scheduleImplement"

    try:
        response = requests.get(url, params=params, timeout=timeout_seconds)
    except requests.RequestException as ex:
        if self.request.retries < retry_count:
            raise self.retry(exc=ex, countdown=max(int(retry_backoff_ms / 1000), 1))
        return {
            "success": False,
            "schedule_name": schedule_name,
            "message": f"HTTP request failed: {ex}",
        }

    if response.status_code >= 500 and self.request.retries < retry_count:
        raise self.retry(exc=Exception(response.text), countdown=max(int(retry_backoff_ms / 1000), 1))

    try:
        payload = response.json()
    except ValueError:
        payload = {"raw": response.text}

    return {
        "success": 200 <= response.status_code < 300,
        "schedule_name": schedule_name,
        "status_code": response.status_code,
        "response": payload,
    }


@shared_task(bind=True)
def dispatch_schedules_via_http(self):
    schedule_fun = ScheduleFun()
    now_dt = timezone.localtime()
    schedules = schedule_fun.get_tb_schedule_configs()

    queued = []
    for row in schedules:
        schedule_name = row.get("schedule_name")
        status = str(row.get("status") or "").upper()
        schedule_opt = str(row.get("schedule_opt") or "")

        if not schedule_name:
            continue
        if status not in ("ENABLED", "ON"):
            continue
        if not _is_due(schedule_opt, now_dt):
            continue

        run_schedule_by_name.delay(schedule_name)
        queued.append(schedule_name)

    return {
        "success": True,
        "queued_count": len(queued),
        "queued": queued,
        "run_at": now_dt.isoformat(),
    }
