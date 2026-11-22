# Reverde Backend

Eight standalone Spring infrastructure/business services plus the FastAPI analytics service: six Spring Boot business services, one Eureka registry, and one FastAPI analytics service. Each business/service endpoint is available independently. Databases, security, messaging, gateway, and remaining discovery integration are deferred.

Services: forest-biodiversity-service (Omar, 8081), fire-risk-service (Emna, 8082), incident-service (Ela, 8083), recovery-service (Zayneb, 8084), volunteer-service (Chebbi, 8085), resource-service (Ahmed, 8086), analytics-service (8090).

The forest-biodiversity-service is registered with the Eureka server (8761) under the name `FOREST-BIODIVERSITY-SERVICE`. Eureka is available at http://localhost:8761/.

Prerequisites: Java 17+, Maven 3.9+ or included wrappers, Python 3.10+, and Git. Run all with run-all.bat, test with powershell -ExecutionPolicy Bypass -File .\test-all.ps1, and stop with stop-all.bat. Use stop-all.bat for occupied ports, mvnw.cmd if mvn is unavailable, and set JAVA_HOME to JDK 17 if Java is not found.

Next: API Gateway, PostgreSQL per service, RabbitMQ, Eureka, Config Server, and Docker Compose.
