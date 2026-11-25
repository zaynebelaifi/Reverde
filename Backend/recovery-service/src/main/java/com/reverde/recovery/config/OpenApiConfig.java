package com.reverde.recovery.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI().info(new Info().title("Reverde | Recovery & Reforestation").version("1.0.0")
            .description("Recovery projects and planting records linked to fire incidents.\n\n"
                + "Current implementation: service connectivity only. Domain CRUD, persistence, and authentication "
                + "are planned and are not exposed by this API yet. Use the centralized gateway Swagger UI "
                + "to call this service through discovery and load balancing."));
    }
}
