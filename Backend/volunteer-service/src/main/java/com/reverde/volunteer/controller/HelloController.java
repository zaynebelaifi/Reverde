package com.reverde.volunteer.controller;
import java.time.Instant;import java.util.Map;import org.springframework.web.bind.annotation.*;
@RestController public class HelloController{@GetMapping("/hello") public Map<String,Object> hello(){return Map.of("service","volunteer-service","status","UP","message","Hello from volunteer-service","port",8085,"timestamp",Instant.now().toString());}}
