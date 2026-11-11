package com.reverde.firerisk.controller;
import java.time.Instant;import java.util.Map;import org.springframework.web.bind.annotation.*;
@RestController public class HelloController{@GetMapping("/hello") public Map<String,Object> hello(){return Map.of("service","fire-risk-service","status","UP","message","Hello from fire-risk-service","port",8082,"timestamp",Instant.now().toString());}}
