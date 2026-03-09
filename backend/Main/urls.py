from django.urls import path

from Main import views


urlpatterns = [
    path("scheduleImplement", views.schedule_implement_view, name="schedule_implement"),
    path("tasks/<str:task_id>", views.task_status_view, name="task_status"),
]
