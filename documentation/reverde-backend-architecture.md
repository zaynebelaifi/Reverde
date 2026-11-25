> Historical skeleton report. See [the current integration guide](gateway-and-clients.md) for gateway, discovery, Swagger, and Angular clients.

# Reverde Backend Architecture Report

## 1. Scope

This report describes the backend skeleton currently implemented for Reverde, a forest-fire management platform for Tunisia.

The current stage is intentionally minimal. It proves that each team microservice can run independently, expose a REST endpoint, and publish interactive API documentation.

Implemented features:

- Six independent Spring Boot 3.3.5 services using Java 17.
- One independent FastAPI service using Python.
- A Eureka registry server on port 8761.
- Eureka registration for the forest-biodiversity-service.
- A common `GET /hello` endpoint for all seven services.
- Swagger/OpenAPI documentation for every service.
- CORS configuration for the React development origins.
- Health endpoints through Spring Boot Actuator and FastAPI.
- Per-service tests.
- Scripts to start, test, and stop the complete backend locally.

The following features are deliberately deferred:

- API Gateway
- Authentication and authorization
- PostgreSQL databases
- RabbitMQ messaging
- Eureka discovery for the remaining five Spring Boot business services
- Spring Cloud Config Server
- Docker Compose orchestration
- Business workflows and domain persistence

## 2. Current Runtime Architecture

The current architecture is a collection of seven standalone services:

```text
React Frontend (future)
        |
        | Direct local HTTP calls during this stage
        |
+-------+----------------------+----------------------+----------------------+
|       |                      |                      |                      |
8081  8082                   8083                   8084 ... 8086          8090
|       |                      |                      |                      |
Forest  Fire Risk             Incident                Recovery, Volunteer,  Analytics
Bio.    Service               Service                 Resource Services     FastAPI
```

Each service owns its own HTTP port and can be started, tested, and stopped independently. There is no gateway or shared database yet.

## 3. Service Inventory

| Service                             | Technology            | Port | Owner                 | Responsibility                          |
| ----------------------------------- | --------------------- | ---: | --------------------- | --------------------------------------- |
| forest-biodiversity-service         | Spring Boot / Java 17 | 8081 | Omar                  | Forest zones, species, and biodiversity |
| fire-risk-service                   | Spring Boot / Java 17 | 8082 | Emna                  | Weather and fire-risk data              |
| incident-service                    | Spring Boot / Java 17 | 8083 | Ela                   | Fire incidents                          |
| recovery-service                    | Spring Boot / Java 17 | 8084 | Zayneb                | Reforestation and recovery              |
| volunteer-service                   | Spring Boot / Java 17 | 8085 | Chebbi                | Volunteers                              |
| resource-service                    | Spring Boot / Java 17 | 8086 | Ahmed                 | Equipment and resources                 |
| <br /><br /><br />analytics-service | FastAPI / Python      | 8090 | Demonstration service | Technological diversity example         |

## 4. Spring Boot Service Architecture

Every Java service follows the same structure:

```text
<service>/
|-- pom.xml
|-- mvnw
|-- mvnw.cmd
|-- .mvn/wrapper/
|-- README.md
|-- src/
    |-- main/
    |   |-- java/com/reverde/<servicepackage>/
    |   |   |-- <Name>Application.java
    |   |   |-- controller/HelloController.java
    |   |   |-- config/OpenApiConfig.java
    |   |   |-- config/CorsConfig.java
    |   |-- resources/application.yml
    |-- test/
        |-- java/com/reverde/<servicepackage>/<Name>Tests.java
```

### Application class

`<Name>Application.java` is the Spring Boot entry point. Each service is executable and has its own application context.

### Controller

`HelloController.java` exposes:

```http
GET /hello
```

The response contains:

```json
{
  "service": "example-service",
  "status": "UP",
  "message": "Hello from example-service",
  "port": 8081,
  "timestamp": "2026-01-01T12:00:00Z"
}
```

The timestamp is generated at request time in ISO-8601 format.

### OpenAPI configuration

`OpenApiConfig.java` creates an OpenAPI bean with:

- Module-specific API title.
- Version `1.0.0`.
- A description of the module responsibility.

Swagger UI is available at:

```text
http://localhost:<port>/swagger-ui/index.html
```

### CORS configuration

`CorsConfig.java` allows the React development origins:

- `http://localhost:3000`
- `http://localhost:5173`

All HTTP methods are allowed for all paths during this initial development stage.

### Configuration

Each `application.yml` defines:

- The server port.
- The Spring application name.
- Actuator exposure for `health` and `info`.
- The Springdoc Swagger path.

### Tests

Each service contains a `@SpringBootTest` with MockMvc. The test verifies that:

- `GET /hello` returns HTTP 200.
- The response status is `UP`.

Each service also includes an official Maven Wrapper, so Maven can be downloaded and used automatically by teammates.

## 5. FastAPI Analytics Architecture

The analytics service is intentionally implemented in a different technology stack.

```text
analytics-service/
|-- main.py
|-- requirements.txt
|-- README.md
|-- tests/test_hello.py
|-- .venv/              ignored local virtual environment
```

`main.py` creates:

- A FastAPI application named `Analytics Service API`.
- Version `1.0.0`.
- CORS middleware with the same React origins.
- `GET /hello`.
- `GET /health`.

FastAPI automatically provides:

- Swagger UI: `http://localhost:8090/docs`
- OpenAPI JSON: `http://localhost:8090/openapi.json`

The test suite uses FastAPI's `TestClient` and verifies the hello and health endpoints.

## 6. Backend Automation

The shared files are located directly in `Reverde/Backend`.

### run-all.bat

Starts one command window per service:

- Six Spring Boot services through `mvnw.cmd spring-boot:run`.
- The analytics service through its local virtual environment and Uvicorn.

The launcher configures the installed Java 17 and Maven paths for new Windows command windows.

### test-all.ps1

Tests all seven services and prints a table containing:

- Service name.
- Port.
- PASS or FAIL.
- The returned JSON or an error message.

The script retries each service for up to 60 seconds, allowing Spring Boot and Uvicorn enough time to start.

### stop-all.bat

Finds processes listening on ports 8081 through 8086 and 8090 and terminates their process trees.

## 7. Request Flow at This Stage

A typical local request currently follows this path:

```text
Browser or REST client
        |
        | GET http://localhost:8081/hello
        v
Forest Biodiversity Service
        |
        | JSON response
        v
Browser or REST client
```

The same pattern applies to every other port.

There is no authentication, token validation, gateway routing, service discovery, or inter-service communication yet. This makes the current version easy to demonstrate and debug.

## 8. Verification

The implemented backend was verified with:

- Java 17.
- Maven 3.9.12.
- Python virtual environment.
- FastAPI tests.
- Six Spring Boot `clean test` executions.
- All seven `GET /hello` endpoints.
- All seven Swagger pages.
- The shared `test-all.ps1` workflow.

The expected result is seven PASS rows:

```text
forest-biodiversity-service  PASS
fire-risk-service            PASS
incident-service             PASS
recovery-service             PASS
volunteer-service            PASS
resource-service             PASS
analytics-service            PASS
```

## 9. Planned Target Architecture

The future production-oriented architecture will introduce shared platform components:

```text
React Frontend
      |
      v
Spring Cloud API Gateway
      |
      +--> JWT authentication and authorization
      |
      +--> Eureka Service Discovery
      |
      +--> Spring Boot Microservices
      |       |
      |       +--> PostgreSQL database per service
      |       +--> REST communication
      |       +--> RabbitMQ events
      |
      +--> FastAPI Analytics Service
      |
      +--> Spring Cloud Config Server
```

Docker Compose will later package the gateway, discovery server, config server, RabbitMQ, databases, and services for local development.

## 10. Planned Evolution

The recommended implementation order is:

1. Add the API Gateway and route requests to the existing ports.
2. Add JWT-based authentication at the gateway.
3. Add Eureka for service registration and discovery.
4. Add Config Server for centralized configuration.
5. Give each business service its own PostgreSQL database.
6. Add REST clients for synchronous communication.
7. Add RabbitMQ events for asynchronous workflows.
8. Add domain entities, validation, error handling, and business logic.
9. Add Docker Compose for repeatable local environments.
10. Add integration tests covering gateway routing and service communication.

The current service boundaries and identical project structures are designed to make these future steps incremental rather than requiring a rewrite.
