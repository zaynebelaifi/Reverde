package com.reverde.recovery.controller;
import java.time.Instant;import java.util.Map;import org.springframework.web.bind.annotation.*;
@RestController public class HelloController{@GetMapping("/hello") public Map<String,Object> hello(){return Map.of("service","recovery-service","status","UP","message","Hello from recovery-service","port",8084,"timestamp",Instant.now().toString());}}
