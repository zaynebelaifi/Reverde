# Reverde clients

Angular web (`web.APP`) and Ionic Angular/Capacitor mobile (`mobile.APP`) share a typed gateway client in `shared`.

```powershell
npm ci
npm start                  # web: localhost:4200
npm run start:mobile       # mobile preview: localhost:8100
npm test
npm run build
npm run mobile:sync
npm run mobile:android     # Android Studio/SDK required
```

Start the backend first. Both clients call the API Gateway, never individual service ports.
They inspect actual connectivity and responses; business CRUD is still planned.
Configure the gateway using Connection settings or each application's `public/config.json`.
Android native source is included. The emulator uses 10.0.2.2:8080; a physical device needs
its computer's LAN gateway address. Native iOS builds require macOS.

See [the integration guide](../documentation/gateway-and-clients.md) for configuration and deployment.
