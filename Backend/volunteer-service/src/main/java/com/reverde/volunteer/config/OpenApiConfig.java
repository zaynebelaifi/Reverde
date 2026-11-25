package com.reverde.volunteer.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI().info(new Info().title("Reverde | Volunteer Coordination").version("1.0.0")
            .description("Volunteer profiles, activities, and registrations.\n\n"
                + "Current implementation: service connectivity only. Domain CRUD, persistence, and authentication "
                + "are planned and are not exposed by this API yet. Use the centralized gateway Swagger UI "
                + "to call this service through discovery and load balancing."));
    }
}
