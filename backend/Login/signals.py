import os

from django.apps import apps
from django.contrib.auth import get_user_model
from django.db import connection
from django.db.models.signals import post_migrate
from django.dispatch import receiver


@receiver(post_migrate)
def ensure_admin_superuser(sender, **kwargs):
    """
    每次 migration 完成後，確保有一個名為 Admin 的超級使用者。
    此流程可重跑，不會重複建立帳號。
    """
    # 避免在 auth app 尚未就緒時執行
    if not apps.is_installed("django.contrib.auth"):
        return

    # 若 user 資料表尚未建立，直接跳過（避免初始階段報錯）
    user_model = get_user_model()
    user_table = user_model._meta.db_table
    if user_table not in connection.introspection.table_names():
        return

    username = os.getenv("DJANGO_BOOTSTRAP_SUPERUSER_USERNAME", "Admin")
    email = os.getenv("DJANGO_BOOTSTRAP_SUPERUSER_EMAIL", "admin@example.com")
    password = os.getenv("DJANGO_BOOTSTRAP_SUPERUSER_PASSWORD", "Admin")

    user, created = user_model.objects.get_or_create(
        username=username,
        defaults={
            "email": email,
            "is_staff": True,
            "is_superuser": True,
            "is_active": True,
        },
    )

    # 已存在但權限不完整時，補齊管理員權限
    need_save = False
    if not user.is_staff:
        user.is_staff = True
        need_save = True
    if not user.is_superuser:
        user.is_superuser = True
        need_save = True
    if not user.is_active:
        user.is_active = True
        need_save = True
    if need_save:
        user.save(update_fields=["is_staff", "is_superuser", "is_active"])

    # 僅在新建時設定密碼，避免每次 migrate 重設密碼
    if created:
        user.set_password(password)
        user.save(update_fields=["password"])
