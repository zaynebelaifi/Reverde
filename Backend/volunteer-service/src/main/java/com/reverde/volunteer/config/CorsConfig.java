package com.reverde.volunteer.config;
import org.springframework.context.annotation.*;import org.springframework.web.servlet.config.annotation.*;
@Configuration public class CorsConfig implements WebMvcConfigurer{@Override public void addCorsMappings(CorsRegistry r){r.addMapping("/**").allowedOrigins("http://localhost:3000","http://localhost:5173").allowedMethods("*");}}
