package com.reverde.gateway;

import java.util.UUID;
import org.springframework.core.Ordered;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

/** Correlates client, gateway, and downstream requests without exposing instance addresses. */
@Component
public class RequestIdFilter implements WebFilter, Ordered {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String requestId = exchange.getRequest().getHeaders().getFirst("X-Request-Id");
        if (requestId == null || !requestId.matches("[A-Za-z0-9._-]{1,80}")) {
            requestId = UUID.randomUUID().toString();
        }
        exchange.getResponse().getHeaders().set("X-Request-Id", requestId);
        final String correlationId = requestId;
        return chain.filter(exchange.mutate().request(builder -> builder.headers(
            headers -> headers.set("X-Request-Id", correlationId))).build());
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }
}
