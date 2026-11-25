# Reverde API Gateway

Spring Cloud Gateway on 8080, Eureka on 8761, round-robin routing to all seven services.

- Unified Swagger: http://localhost:8080/swagger-ui.html
- Health: http://localhost:8080/actuator/health
- Prefixes: /forests, /fire-risk, /incidents, /recovery, /volunteers, /resources, /analytics
- Example: GET /incidents/hello reaches a discovered INCIDENT-SERVICE instance's /hello.

Use `mvnw.cmd spring-boot:run`, or the managed backend launcher. Start Eureka and target services first.
Run `mvnw.cmd test` for routing, discovery/load-balancing, Swagger, CORS, and failure tests.

See [the integration guide](../../documentation/gateway-and-clients.md).
