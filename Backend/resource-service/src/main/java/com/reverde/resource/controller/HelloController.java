package com.reverde.resource.controller;
import java.time.Instant;import java.util.Map;import org.springframework.web.bind.annotation.*;
@RestController public class HelloController{@GetMapping("/hello") public Map<String,Object> hello(){return Map.of("service","resource-service","status","UP","message","Hello from resource-service","port",8086,"timestamp",Instant.now().toString());}}
