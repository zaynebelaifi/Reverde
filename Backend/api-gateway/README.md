# API Gateway

Shared Spring Cloud Gateway entry point on port 8087. Uses Java 17+,
Spring Boot 3.3.5, and Spring Cloud 2023.0.3, matching the existing services.

## Run

Start Eureka on port 8761, then incident-service on port 8083 and
fire-risk-service on port 8082.
From this directory, run `mvnw.cmd spring-boot:run` on Windows or
`./mvnw spring-boot:run` on Linux/macOS. In IntelliJ, add this pom.xml
as a Maven project and run ApiGatewayApplication.

## Verify

- Gateway health: http://localhost:8087/actuator/health
- Routed incident endpoint: http://localhost:8087/incidents/hello
- Routed fire-risk endpoint: http://localhost:8087/fire-risk/hello
- Eureka dashboard: http://localhost:8761/ (API-GATEWAY, INCIDENT-SERVICE, and FIRE-RISK-SERVICE)

Requests under `/incidents/**` resolve `INCIDENT-SERVICE` through Eureka.
The gateway strips the `/incidents` prefix: `/incidents/hello` becomes
`/hello` on the incident service. Discovery cache refresh can take about
30 seconds. A 503 indicates no available incident instance; check Eureka.

Requests under `/fire-risk/**` resolve `FIRE-RISK-SERVICE` through Eureka.
The gateway strips the `/fire-risk` prefix, so `/fire-risk/hello` becomes
`/hello` on the fire-risk service. A 503 indicates no available fire-risk
instance; check Eureka and confirm the service is running on port 8082.

## Centralized Swagger

Open http://localhost:8087/swagger-ui.html and select **Incident Service**
or **Fire Risk Service**. The UI loads each service's API description through
the gateway. The fire-risk service processes forwarded headers so **Try it
out** calls use the gateway's `/fire-risk` route.

The direct Swagger pages on ports 8083 and 8082 remain usable. The gateway
root `/` has no homepage.
