from django.apps import AppConfig


class LoginConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'Login'

    def ready(self):
        # 在 Django app 啟動時註冊 signals
        from . import signals  # noqa: F401
