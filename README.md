# Reverde

A microservices platform for forest fire prevention, monitoring, and post-fire recovery in Tunisia.

- [Architecture, routes, setup, and acceptance guide](documentation/gateway-and-clients.md)
- [Backend](Backend/README.md): Eureka, load-balanced gateway, six Spring Boot modules, FastAPI analytics
- [Angular web and Ionic mobile](Frontend/README.md): shared gateway client and module workspaces
- [Architecture presentation](documentation/presentation/indexDoc.html): domain boundaries and target workflows
- [Postman collection](documentation/postman/Reverde-Gateway.postman_collection.json)

Unified Swagger: http://localhost:8080/swagger-ui.html after starting the backend.
Domain CRUD, persistence, authentication, and asynchronous workflows remain planned.
