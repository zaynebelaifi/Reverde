/** One gateway origin for both clients; never service addresses. */
export function gatewayBase(value: string): string {
  const trimmed = value.trim().replace(/\/+$/, '');
  if (!trimmed) return '';
  const url = new URL(trimmed);
  if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password || url.search || url.hash || url.pathname !== '/') {
    throw new Error('Use a gateway origin such as http://localhost:8080, without a path or credentials.');
  }
  return url.origin;
}
export function gatewayUrl(base: string, prefix: string, path = '/hello'): string {
  if (!/^[a-z-]+$/.test(prefix) || !path.startsWith('/') || path.startsWith('//')) throw new Error('Invalid API path.');
  return `${gatewayBase(base)}/${prefix}${path}`;
}
