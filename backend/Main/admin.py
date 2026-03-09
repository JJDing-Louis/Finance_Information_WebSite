from django.contrib import admin
from Main.models import ScheduleConfig, ScheduleLog


@admin.register(ScheduleConfig)
class ScheduleConfigAdmin(admin.ModelAdmin):
    list_display = (
        "schedule_name",
        "schedule_opt",
        "status",
        "schedule_mode",
        "mapping_table",
        "timeout_ms",
        "retry_count",
        "retry_backoff_ms",
        "modify_time",
    )
    list_filter = ("status", "schedule_mode")
    search_fields = ("schedule_name", "mapping_table", "schedule_opt")


@admin.register(ScheduleLog)
class ScheduleLogAdmin(admin.ModelAdmin):
    list_display = ("run_id", "schedule_name", "status", "started_at", "ended_at")
    list_filter = ("status", "schedule_name")
    search_fields = ("run_id", "schedule_name")
