package com.motio.core.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.StringHttpMessageConverter;

import java.nio.charset.StandardCharsets;

@Configuration
public class WebConfig {
    @Bean
    public StringHttpMessageConverter stringHttpMessageConverter() {
        return new StringHttpMessageConverter(StandardCharsets.UTF_8);
    }
}

