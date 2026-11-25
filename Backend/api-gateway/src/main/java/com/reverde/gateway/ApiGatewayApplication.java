package com.reverde.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication
public class ApiGatewayApplication {
    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(ApiGatewayApplication.class, args);
        String port = context.getEnvironment().getProperty("local.server.port",
                context.getEnvironment().getProperty("server.port", "8080"));
        System.out.println("Eureka Dashboard: http://localhost:8761/");
        System.out.println("Centralized Swagger UI: http://localhost:" + port + "/swagger-ui.html");
        System.out.println("Fire Risk Swagger UI: http://localhost:8082/swagger-ui/index.html");
        System.out.println("Fire Risk API: http://localhost:" + port + "/fire-risk/hello");
    }
}
