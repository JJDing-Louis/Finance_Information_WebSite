from django.shortcuts import render, redirect
from django.contrib.auth import authenticate
from django.contrib import auth

def index(request):
    if request.user.is_authenticated:
        return redirect("home")

    if request.method == "POST":
        username = (request.POST.get("username") or "").strip()
        password = request.POST.get("password") or ""
        user = authenticate(request, username=username, password=password)

        if user is not None:
            auth.login(request, user)
            return redirect("home")

        return render(request, "Login.html", {"message": "帳號或密碼錯誤"})

    return render(request, "Login.html")


# Create your views here.
def login(request):
    return index(request)


def logout(request):
    auth.logout(request)
    return redirect("login")
