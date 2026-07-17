"""Shared response envelopes."""

from typing import Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class Page(BaseModel, Generic[T]):
    """Standard offset/limit pagination envelope for list endpoints."""

    items: list[T]
    total: int
    limit: int
    offset: int


class ErrorResponse(BaseModel):
    """The single error shape used for all handled errors (404, 422, ...)."""

    detail: str
