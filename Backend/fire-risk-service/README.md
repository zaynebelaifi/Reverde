# Fire Risk Service

Purpose: weather and fire risk.

- Owner: Emna
- Port: 8082
- Run: start Eureka first, then run `mvnw.cmd spring-boot:run`
- Swagger UI: http://localhost:8082/swagger-ui/index.html
- Eureka: http://localhost:8761/ (FIRE-RISK-SERVICE)
- Gateway: http://localhost:8080/fire-risk/hello
- Centralized Swagger: http://localhost:8080/swagger-ui.html (Fire Risk Service)

The gateway removes the `/fire-risk` prefix and routes requests to this
service through Eureka. For example, `/fire-risk/hello` is forwarded to
`/hello` on port 8082.
