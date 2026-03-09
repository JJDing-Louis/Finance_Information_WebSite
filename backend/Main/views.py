from celery.result import AsyncResult
from django.http import JsonResponse
from django.views.decorators.http import require_GET

from config.celery import app
from Main.tasks import run_schedule_by_name


@require_GET
def schedule_implement_view(request):
    schedule_name = (request.GET.get("scheduleName") or "").strip()

    if not schedule_name:
        return JsonResponse(
            {"success": False, "message": "scheduleName is required"},
            status=400,
        )

    task = run_schedule_by_name.delay(schedule_name)
    return JsonResponse(
        {
            "success": True,
            "mode": "async",
            "schedule_name": schedule_name,
            "task_id": task.id,
        },
        status=202,
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
