"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.http import JsonResponse
from django.urls import include, path
from django.contrib import admin
from Login import views as LoginController
from Home import views as HomeController



def healthz(_request):
    return JsonResponse({"status": "ok"})
urlpatterns = [
    # path("healthz/", healthz),
    path("admin/", admin.site.urls),
    # 登入畫面
    path("", LoginController.index, name="login"),
    path("home/", HomeController.index, name="home"),
    path("logout/", LoginController.logout, name="logout"),
    path("main/", include("Main.urls")),
    path("api/", include("API.urls")),
]


# def home(request):
#     return HttpResponse("Finance Information API Server Running 🚀")
# urlpatterns = [
#     path('', home),
#     path('admin/', admin.site.urls),
# ]
