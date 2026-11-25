# Reverde backend

Six Spring Boot business services, FastAPI analytics, Eureka, and a shared API Gateway.
Set JAVA_HOME to an installed JDK 17+; analytics requires Python 3.10+.

```powershell
./run-all.bat -InstallPython
./test-all.ps1
./stop-all.bat
```

Swagger: http://localhost:8080/swagger-ui.html. Eureka: http://localhost:8761.
The launcher refuses occupied ports and records owned processes/logs under ignored `.runtime/`.
Stop IDE instances through IntelliJ. All seven services register with Eureka.
Domain persistence, authentication, messaging, and Config Server remain planned.

See [the integration guide](../documentation/gateway-and-clients.md).
