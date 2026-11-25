import type { CapacitorConfig } from '@capacitor/cli';
const config: CapacitorConfig = {
  appId: 'tn.reverde.field',
  appName: 'Reverde',
  webDir: '../dist/mobile.APP/browser',
  // Local workshop HTTP. Use HTTPS and set false for release builds.
  server: { androidScheme: 'http', cleartext: true }
};
export default config;
