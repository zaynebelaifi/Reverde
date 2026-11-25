import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { firstValueFrom, timeout } from 'rxjs';
import { gatewayBase, gatewayUrl } from './gateway-url';

export interface ModuleInfo { id: string; prefix: string; title: string; description: string; domain: string; code: string; }
export interface Identity { service: string; status: string; port: number; timestamp: string; message: string; }
export interface Result { state: 'idle' | 'loading' | 'up' | 'error'; body?: Identity; error?: string; elapsed?: number; checkedAt?: string; }
export const MODULES: ModuleInfo[] = [
 { id:'forest-biodiversity-service', prefix:'forests', title:'Forest & biodiversity', description:'Understand the forest, its zones, and the species that call it home.', domain:'Forest zones · Species · Observations', code:'FO' },
 { id:'fire-risk-service', prefix:'fire-risk', title:'Fire risk & weather', description:'Connect weather observations with the assessment of fire risk.', domain:'Weather · Assessments · Thresholds', code:'RI' },
 { id:'incident-service', prefix:'incidents', title:'Fire incidents', description:'Record fires and assess their impact on forest ecosystems.', domain:'Incidents · Damage assessments', code:'IN' },
 { id:'recovery-service', prefix:'recovery', title:'Recovery & reforestation', description:'Turn post-fire recovery into coordinated restoration projects.', domain:'Recovery projects · Planting records', code:'RE' },
 { id:'volunteer-service', prefix:'volunteers', title:'Volunteer coordination', description:'Connect people with activities that help forests recover.', domain:'Volunteers · Activities · Registrations', code:'VO' },
 { id:'resource-service', prefix:'resources', title:'Equipment & resources', description:'Coordinate the tools and equipment needed in the field.', domain:'Equipment · Categories · Allocations', code:'EQ' },
 { id:'analytics-service', prefix:'analytics', title:'Analytics', description:'Bring a shared analytical perspective to forest protection.', domain:'Analytics foundation', code:'AN' }
];
@Injectable({providedIn:'root'})
export class GatewayApi {
 private http = inject(HttpClient);
 readonly modules = MODULES;
 readonly base = signal('');
 readonly configError = signal('');
 readonly results = signal<Record<string, Result>>({});
 readonly busy = computed(() => Object.values(this.results()).some(r => r.state === 'loading'));
 readonly online = computed(() => Object.values(this.results()).filter(r => r.state === 'up').length);
 readonly checked = computed(() => Object.values(this.results()).filter(r => ['up','error'].includes(r.state)).length);
 async configure(defaultBase = '') {
   try {
     const response = await fetch('config.json');
     const config = response.ok ? await response.json() : {};
     this.base.set(gatewayBase(localStorage.getItem('reverde.gateway') ?? config.gatewayUrl ?? defaultBase));
     if (!this.base() && defaultBase) this.base.set(gatewayBase(defaultBase));
   } catch { this.base.set(defaultBase); this.configError.set('Could not load gateway settings. Check the connection address.'); }
 }
 setBase(value: string) {
   try { this.base.set(gatewayBase(value)); localStorage.setItem('reverde.gateway', this.base()); this.results.set({}); this.configError.set(''); }
   catch (error) { this.configError.set(error instanceof Error ? error.message : 'Invalid gateway address.'); }
 }
 endpoint(module: ModuleInfo) { return gatewayUrl(this.base(), module.prefix); }
 docs() { return `${this.base()}/swagger-ui.html`; }
 result(module: ModuleInfo): Result { return this.results()[module.id] ?? {state:'idle'}; }
 async probe(module: ModuleInfo) {
   if (this.result(module).state === 'loading') return;
   this.results.update(all => ({...all,[module.id]:{state:'loading'}}));
   const started = performance.now();
   let result: Result;
   try {
     const body = await firstValueFrom(this.http.get<Identity>(this.endpoint(module)).pipe(timeout(12000)));
     if (body.service !== module.id || body.status !== 'UP') throw new Error('Unexpected service response. Check the gateway route.');
     result = {state:'up',body,elapsed:Math.round(performance.now()-started),checkedAt:new Date().toISOString()};
   } catch (error) {
     const status = error instanceof HttpErrorResponse ? error.status : undefined;
     const message = status === 503 ? 'No available instance. Start this service and check Eureka.' : status === 404 ? 'Route or endpoint not found.' : status === 0 ? 'Gateway unreachable. Check its address and allowed client origin.' : error instanceof Error ? error.message : 'Request failed.';
     result = {state:'error',error:message,elapsed:Math.round(performance.now()-started),checkedAt:new Date().toISOString()};
   }
   this.results.update(all => ({...all,[module.id]:result}));
 }
 async probeAll() { await Promise.all(this.modules.map(module=>this.probe(module))); }
}
