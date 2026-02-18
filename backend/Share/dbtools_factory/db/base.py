from __future__ import annotations

from abc import ABC, abstractmethod


class BaseConnectionTool(ABC):
    """Common lifecycle for a DB connection tool."""

    def __init__(self, name: str) -> None:
        self.name = name

    @abstractmethod
    def connect(self) -> None: ...

    @abstractmethod
    def close(self) -> None: ...

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc, tb):
        self.close()
        return False
