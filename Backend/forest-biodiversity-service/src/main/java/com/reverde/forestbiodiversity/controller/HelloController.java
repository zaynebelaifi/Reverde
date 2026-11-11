package com.reverde.forestbiodiversity.controller;
import java.time.Instant;import java.util.Map;import org.springframework.web.bind.annotation.*;
@RestController public class HelloController{@GetMapping("/hello") public Map<String,Object> hello(){return Map.of("service","forest-biodiversity-service","status","UP","message","Hello from forest-biodiversity-service","port",8081,"timestamp",Instant.now().toString());}}
