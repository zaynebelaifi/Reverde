import test from 'node:test';
import assert from 'node:assert/strict';
import { gatewayBase, gatewayUrl } from '../shared/gateway-url.ts';
test('both clients build requests against one gateway origin',()=>{
 assert.equal(gatewayUrl('', 'incidents'), '/incidents/hello');
 assert.equal(gatewayUrl('http://10.0.2.2:8080/', 'forests'), 'http://10.0.2.2:8080/forests/hello');
 assert.equal(gatewayUrl('https://api.reverde.example', 'analytics','/openapi.json'), 'https://api.reverde.example/analytics/openapi.json');
});
test('rejects credentials, scripts, and ambiguous gateway paths',()=>{
 for(const value of ['javascript:alert(1)','https://user:secret@example.com','https://example.com/incidents','https://example.com?x=1'])assert.throws(()=>gatewayBase(value));
 assert.throws(()=>gatewayUrl('', '../incidents'));
 assert.throws(()=>gatewayUrl('', 'incidents', '//other.example'));
});
