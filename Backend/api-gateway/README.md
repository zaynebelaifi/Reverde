# API Gateway

Shared Spring Cloud Gateway entry point on port 8080. Uses Java 17+,
Spring Boot 3.3.5, and Spring Cloud 2023.0.3, matching the existing services.

## Run

Start Eureka on port 8761 and incident-service on port 8083 first.
From this directory, run `mvnw.cmd spring-boot:run` on Windows or
`./mvnw spring-boot:run` on Linux/macOS. In IntelliJ, add this pom.xml
as a Maven project and run ApiGatewayApplication.

## Verify

- Gateway health: http://localhost:8080/actuator/health
- Routed incident endpoint: http://localhost:8080/incidents/hello
- Eureka dashboard: http://localhost:8761/ (API-GATEWAY and INCIDENT-SERVICE)

Requests under `/incidents/**` resolve `INCIDENT-SERVICE` through Eureka.
The gateway strips the `/incidents` prefix: `/incidents/hello` becomes
`/hello` on the incident service. Discovery cache refresh can take about
30 seconds. A 503 indicates no available incident instance; check Eureka.

## Centralized Swagger

Open http://localhost:8080/swagger-ui.html and select **Incident Service**.
The UI loads `/incidents/v3/api-docs` through the gateway. The incident
service processes forwarded headers so its generated server URL includes
the gateway address and `/incidents` prefix. **Try it out** for `/hello`
therefore calls `http://localhost:8080/incidents/hello`.

Only the incident service is listed. Its direct Swagger page on port 8083
remains usable. The gateway root `/` has no homepage.
