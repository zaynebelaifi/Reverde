package com.reverde.incident.controller;
import java.time.Instant;import java.util.Map;import org.springframework.web.bind.annotation.*;
@RestController public class HelloController{@GetMapping("/hello") public Map<String,Object> hello(){return Map.of("service","incident-service","status","UP","message","Hello from incident-service","port",8083,"timestamp",Instant.now().toString());}}
