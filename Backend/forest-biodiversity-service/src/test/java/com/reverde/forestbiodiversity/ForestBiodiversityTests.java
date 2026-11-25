package com.reverde.forestbiodiversity;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(properties = "eureka.client.enabled=false")
@AutoConfigureMockMvc
class ForestBiodiversityTests {
    @Autowired MockMvc mockMvc;

    @Test void helloIsUp() throws Exception {
        mockMvc.perform(get("/hello")).andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("UP"))
            .andExpect(jsonPath("$.service").value("forest-biodiversity-service"))
            .andExpect(jsonPath("$.port").isNumber());
    }

    @Test void documentsTypedResponsesAndGatewayServer() throws Exception {
        mockMvc.perform(get("/v3/api-docs")
                .header("X-Forwarded-Host", "localhost:8080")
                .header("X-Forwarded-Proto", "http")
                .header("X-Forwarded-Prefix", "/forests"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.paths['/hello'].get.summary").isNotEmpty())
            .andExpect(jsonPath("$.components.schemas.ServiceIdentity.properties.port.type").value("integer"))
            .andExpect(jsonPath("$.servers[0].url").value("http://localhost:8080/forests"));
    }
}
