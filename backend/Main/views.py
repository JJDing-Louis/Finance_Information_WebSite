import os

from celery.result import AsyncResult
from django.http import JsonResponse
from django.views.decorators.http import require_GET

from config.celery import app
from Main.services.schedule_executor import schedule_implement


@require_GET
def schedule_implement_view(request):
    schedule_name = (request.GET.get("scheduleName") or "").strip()
    expected_token = (os.getenv("SCHEDULE_ENTRY_TOKEN") or "").strip()
    request_token = (
        request.headers.get("X-Schedule-Token")
        or request.GET.get("token")
        or ""
    ).strip()

    if not schedule_name:
        return JsonResponse(
            {"success": False, "message": "scheduleName is required"},
            status=400,
        )
    if expected_token and request_token != expected_token:
        return JsonResponse(
            {"success": False, "message": "Unauthorized schedule entry"},
            status=401,
        )

    result = schedule_implement(schedule_name)
    return JsonResponse(
        {
            "success": result.success,
            "mode": "direct",
            "schedule_name": schedule_name,
            "run_id": result.run_id,
            "message": result.message,
            "data": result.data,
        },
        status=200 if result.success else 500,
    )


@require_GET
def task_status_view(request, task_id: str):
    result = AsyncResult(task_id, app=app)
    return JsonResponse(
        {
            "task_id": task_id,
            "state": result.state,
            "result": result.result if result.successful() else None,
            "error": str(result.result) if result.failed() else None,
        }
    )
