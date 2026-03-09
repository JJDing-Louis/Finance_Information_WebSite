from django.http import JsonResponse


def index(_request):
    return JsonResponse({"app": "API", "status": "ok"})
