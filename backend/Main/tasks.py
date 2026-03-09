from celery import shared_task

from Main.services.schedule_executor import schedule_implement


@shared_task(bind=True)
def run_schedule_by_name(self, schedule_name: str):
    result = schedule_implement(schedule_name)
    return {
        "success": result.success,
        "run_id": result.run_id,
        "message": result.message,
        "data": result.data,
    }
