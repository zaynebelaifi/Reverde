package com.reverde.gateway;

import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.stream.IntStream;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.cloud.client.DefaultServiceInstance;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.ReactiveDiscoveryClient;
import reactor.core.publisher.Flux;
import org.springframework.context.annotation.Bean;
import org.springframework.test.web.reactive.server.WebTestClient;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = {"eureka.client.enabled=false"}, classes = {ApiGatewayApplication.class, GatewayRoutingTest.Registry.class})
class GatewayRoutingTest {
    private static final List<String> SERVICES = List.of("FOREST-BIODIVERSITY", "FIRE-RISK", "INCIDENT",
        "RECOVERY", "VOLUNTEER", "RESOURCE", "ANALYTICS");
    private static final List<String> PREFIXES = List.of("forests", "fire-risk", "incidents",
        "recovery", "volunteers", "resources", "analytics");
    private static final HttpServer FIRST = server();
    private static final HttpServer SECOND = server();
    private static volatile boolean resourceAvailable = true;
    @Autowired WebTestClient client;

    private static HttpServer server() {
        try {
            HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
            server.createContext("/", exchange -> {
                String body = "{\"path\":\"" + exchange.getRequestURI() + "\",\"port\":"
                    + server.getAddress().getPort() + ",\"requestId\":\""
                    + exchange.getRequestHeaders().getFirst("X-Request-Id") + "\"}";
                byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, bytes.length);
                exchange.getResponseBody().write(bytes);
                exchange.close();
            });
            server.start();
            return server;
        } catch (Exception exception) {
            throw new IllegalStateException(exception);
        }
    }

    @AfterAll static void stop() { FIRST.stop(0); SECOND.stop(0); }

    @Test void forwardsEveryServiceAndPreservesQueryAndCorrelation() {
        for (String prefix : PREFIXES) {
            client.get().uri("/" + prefix + "/hello?check=1").header("X-Request-Id", "route-test")
                .exchange().expectStatus().isOk().expectHeader().valueEquals("X-Request-Id", "route-test")
                .expectBody().jsonPath("$.path").isEqualTo("/hello?check=1")
                .jsonPath("$.requestId").isEqualTo("route-test");
        }
    }

    @Test void balancesAcrossTwoDiscoveredInstances() {
        Set<Integer> ports = new HashSet<>();
        IntStream.range(0, 8).forEach(index -> client.get().uri("/incidents/hello").exchange()
            .expectStatus().isOk().expectBody().jsonPath("$.port").value(value -> ports.add(((Number) value).intValue())));
        assertThat(ports).containsExactlyInAnyOrder(FIRST.getAddress().getPort(), SECOND.getAddress().getPort());
    }

    @Test void exposesSevenDocumentationChoicesAndServesSwaggerUi() {
        client.get().uri("/v3/api-docs/swagger-config").exchange().expectStatus().isOk()
            .expectBody().jsonPath("$.urls.length()").isEqualTo(7);
        client.get().uri("/webjars/swagger-ui/index.html").exchange().expectStatus().isOk();
        client.get().uri("/incidents/v3/api-docs").exchange().expectStatus().isOk()
            .expectBody().jsonPath("$.path").isEqualTo("/v3/api-docs");
        client.get().uri("/analytics/openapi.json").exchange().expectStatus().isOk()
            .expectBody().jsonPath("$.path").isEqualTo("/openapi.json");
    }

    @Test void acceptsWebAndMobilePreflightButRejectsUnknownOrigins() {
        for (String origin : List.of("http://localhost:4200", "http://localhost:8100", "https://localhost", "capacitor://localhost")) {
            client.options().uri("/incidents/hello").header("Origin", origin)
                .header("Access-Control-Request-Method", "GET").exchange().expectStatus().isOk()
                .expectHeader().valueEquals("Access-Control-Allow-Origin", origin);
        }
        client.options().uri("/incidents/hello").header("Origin", "https://unknown.example")
            .header("Access-Control-Request-Method", "GET").exchange().expectStatus().isForbidden();
        client.get().uri("/incidents/hello").header("Origin", "http://localhost:4200")
            .exchange().expectStatus().isOk()
            .expectHeader().valueEquals("Access-Control-Allow-Origin", "http://localhost:4200");
    }

    @Test void returnsNotFoundForUnknownPublicRoute() {
        client.get().uri("/not-a-service/hello").exchange().expectStatus().isNotFound();
    }

    @Test void returnsServiceUnavailableWhenRegistryHasNoInstance() {
        resourceAvailable = false;
        try {
            client.get().uri("/resources/hello").exchange().expectStatus().isEqualTo(503);
        } finally {
            resourceAvailable = true;
        }
    }

    @TestConfiguration
    static class Registry {
        @Bean ReactiveDiscoveryClient testDiscoveryClient() {
            return new ReactiveDiscoveryClient() {
                public String description() { return "Test registry with two live instances per service"; }
                public Flux<String> getServices() { return Flux.fromIterable(SERVICES.stream().map(name -> name + "-SERVICE").toList()); }
                public Flux<ServiceInstance> getInstances(String serviceId) {
                    if (serviceId.equals("RESOURCE-SERVICE") && !resourceAvailable) return Flux.empty();
                    if (!SERVICES.contains(serviceId.replace("-SERVICE", ""))) return Flux.empty();
                    return Flux.just(new DefaultServiceInstance("one", serviceId, "127.0.0.1", FIRST.getAddress().getPort(), false),
                        new DefaultServiceInstance("two", serviceId, "127.0.0.1", SECOND.getAddress().getPort(), false));
                }
            };
        }
    }
}

