"""Analytics connectivity API; domain analytics will be added by its owner."""
from contextlib import asynccontextmanager
from copy import deepcopy
from datetime import datetime, timezone
import os

from fastapi import FastAPI, Request
from pydantic import BaseModel, Field


@asynccontextmanager
async def lifespan(app: FastAPI):
    client = None
    if os.getenv("EUREKA_ENABLED", "true").lower() == "true":
        from py_eureka_client.eureka_client import EurekaClient

        host = os.getenv("SERVICE_HOST", "localhost")
        port = int(os.getenv("SERVER_PORT", "8090"))
        client = EurekaClient(
            eureka_server=os.getenv("EUREKA_URL", "http://localhost:8761/eureka/"),
            app_name="ANALYTICS-SERVICE",
            instance_host=host,
            instance_ip=os.getenv("SERVICE_IP", "127.0.0.1"),
            instance_port=port,
            instance_id=f"{host}:analytics-service:{port}",
            health_check_url=f"http://{host}:{port}/health",
            status_page_url=f"http://{host}:{port}/docs",
        )
        await client.start()
    try:
        yield
    finally:
        if client is not None:
            await client.stop()


app = FastAPI(
    title="Reverde | Analytics",
    version="1.0.0",
    description=("Polyglot analytics service. Currently exposes connectivity and process health only. "
                 "Business analytics and persistence are planned. Use gateway Swagger for unified access."),
    lifespan=lifespan,
    openapi_url=None,
    docs_url=None,
    openapi_tags=[{"name": "Service connectivity", "description": "Instance identity and process health."}],
)


class ServiceIdentity(BaseModel):
    service: str = Field(examples=["analytics-service"])
    status: str = Field(examples=["UP"])
    message: str = Field(examples=["Hello from analytics-service"])
    port: int = Field(description="Actual listening port", examples=[8090])
    timestamp: datetime = Field(description="Response creation time in UTC")


class Health(BaseModel):
    status: str = Field(examples=["UP"])


@app.get("/hello", response_model=ServiceIdentity, tags=["Service connectivity"],
         summary="Identify a running analytics instance",
         description="Confirms routing and identifies which instance answered. Does not return domain analytics.")
def hello(request: Request) -> ServiceIdentity:
    return ServiceIdentity(service="analytics-service", status="UP", message="Hello from analytics-service",
                           port=request.scope["server"][1], timestamp=datetime.now(timezone.utc))


@app.get("/health", response_model=Health, tags=["Service connectivity"],
         summary="Check process health")
def health() -> Health:
    return Health(status="UP")


@app.get("/openapi.json", include_in_schema=False)
def openapi_document(request: Request):
    document = deepcopy(app.openapi())
    prefix = request.headers.get("x-forwarded-prefix", "")
    document["servers"] = [{"url": "/analytics" if prefix == "/analytics" else "/"}]
    return document


@app.get("/docs", include_in_schema=False)
def docs():
    from fastapi.openapi.docs import get_swagger_ui_html
    return get_swagger_ui_html(openapi_url="/openapi.json", title="Reverde | Analytics API")
