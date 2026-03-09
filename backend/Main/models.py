from django.db import models


class ScheduleConfig(models.Model):
    schedule_name = models.CharField(max_length=100, primary_key=True)
    schedule_opt = models.CharField(max_length=50, default="")
    modify_time = models.DateTimeField(auto_now=True)
    status = models.CharField(max_length=10, default="ENABLED")
    schedule_url = models.CharField(max_length=500, default="")
    schedule_mode = models.CharField(max_length=100, default="API")
    timeout_ms = models.IntegerField(default=15000)
    retry_count = models.IntegerField(default=2)
    retry_backoff_ms = models.IntegerField(default=500)
    mapping_table = models.CharField(max_length=50, default="")

    class Meta:
        db_table = "tb_schedule_configs"

    def __str__(self) -> str:
        return self.schedule_name


class ScheduleLog(models.Model):
    STATUS_CHOICES = (
        ("RUNNING", "RUNNING"),
        ("SUCCESS", "SUCCESS"),
        ("NG", "NG"),
    )

    run_id = models.CharField(max_length=32, unique=True)
    schedule_name = models.CharField(max_length=128)
    schedule_mode = models.CharField(max_length=64, blank=True, default="")
    mapping_table = models.CharField(max_length=128, blank=True, default="")
    status = models.CharField(max_length=16, choices=STATUS_CHOICES)
    message = models.TextField(blank=True, default="")
    result_json = models.JSONField(default=dict, blank=True)
    started_at = models.DateTimeField()
    ended_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "tb_schedule_log"
        indexes = [
            models.Index(fields=["schedule_name", "created_at"]),
            models.Index(fields=["status", "created_at"]),
        ]

    def __str__(self) -> str:
        return f"{self.schedule_name}-{self.run_id}"
