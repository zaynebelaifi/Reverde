# Integration validation - 25 November 2026

Checkout branch: `ela/incident-service`.

## Passed

- Six Java business-service suites: 2 tests each, zero failures/errors.
- Gateway suite: 6 tests, zero failures/errors. Includes all seven routes, query preservation,
  correlation IDs, two discovered HTTP instances, Swagger, web/mobile CORS, 404, and 503.
- Analytics: 3 Python tests passed (identity, health, direct/gateway OpenAPI server addresses).
- Shared frontend URL construction: 2 Node tests passed.
- Angular web production build and Ionic Angular mobile production build passed.
- Capacitor generated/synchronized the Android project and copied the built mobile assets.
- Live isolated stack on gateway 18080 / Eureka 18761: all seven real services registered UP;
  all seven routed identity endpoints and OpenAPI documents passed checks.
- Live Eureka-backed load balancing: eight incident requests reached instance 18083 four times
  and instance 18183 four times.
- Real GET requests with web, Ionic preview, and Capacitor origins returned 200 with the
  appropriate Access-Control-Allow-Origin header.
- All seven service requests passed through each Angular development proxy (4200 and 8100).
- Swagger UI HTML and its seven-entry configuration returned successfully.
- Generated portable OpenAPI snapshots contain the implemented /hello operation and gateway paths.
- Git whitespace check passed.

## Verification limits

Browser automation could not initialize: the host reported "failed to write kernel assets".
Browser rendering, visual layout, and actual button interaction were therefore not verified.
Frontend checks covered production compilation, HTML serving, API proxying, and shared URL logic.

Android Studio/SDK are not installed on this PC. Android source and asset synchronization are
verified; native APK compilation, emulator/device execution, and iOS builds are not verified.
The Python test run reports a Starlette/httpx deprecation warning; the tests pass.

These checks validate the integration foundation. They do not claim domain CRUD, authentication,
database persistence, messaging, or deployment readiness; those remain in the documented backlog.
