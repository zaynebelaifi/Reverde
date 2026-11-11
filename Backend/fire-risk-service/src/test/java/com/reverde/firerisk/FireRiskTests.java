package com.reverde.firerisk;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import org.junit.jupiter.api.Test;import org.springframework.beans.factory.annotation.Autowired;import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;import org.springframework.boot.test.context.SpringBootTest;import org.springframework.test.web.servlet.MockMvc;
@SpringBootTest @AutoConfigureMockMvc class FireRiskTests{@Autowired MockMvc mockMvc;@Test void helloIsUp() throws Exception{mockMvc.perform(get("/hello")).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("UP"));}}
