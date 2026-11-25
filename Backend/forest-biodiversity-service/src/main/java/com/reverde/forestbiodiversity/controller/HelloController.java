package com.reverde.forestbiodiversity.controller;

import java.time.Instant;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;

@RestController
@Tag(name = "Service connectivity", description = "Confirm gateway routing and identify the responding instance.")
public class HelloController {
    private final Environment environment;

    public HelloController(Environment environment) {
        this.environment = environment;
    }

    @GetMapping(value = "/hello", produces = "application/json")
    @Operation(summary = "Identify a running Forest & Biodiversity instance",
        description = "Returns this instance's identity, actual listening port, and current UTC time. "
            + "Repeated gateway requests may reach different instances. This endpoint does not return business records.")
    public ServiceIdentity hello() {
        int port = environment.getProperty("local.server.port", Integer.class,
            environment.getProperty("server.port", Integer.class, 8081));
        return new ServiceIdentity("forest-biodiversity-service", "UP", "Hello from forest-biodiversity-service", port, Instant.now());
    }

    @Schema(description = "Identity of the instance that answered the request.")
    public record ServiceIdentity(
        @Schema(example = "forest-biodiversity-service") String service,
        @Schema(example = "UP", allowableValues = {"UP"}) String status,
        @Schema(example = "Hello from forest-biodiversity-service") String message,
        @Schema(example = "8081", description = "Actual instance port; changes when scaling locally.") int port,
        @Schema(description = "Response creation time in UTC", format = "date-time") Instant timestamp
    ) {}
}
