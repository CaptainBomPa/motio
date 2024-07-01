package com.motio.auth;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan(basePackages = "com.motio.commons.model")
@EnableJpaRepositories(basePackages = {"com.motio.commons.repository"})
@ComponentScan(basePackages = {"com.motio.auth", "com.motio.commons"})
public class MotioAuthApi {

    public static void main(String[] args) {
        SpringApplication.run(MotioAuthApi.class, args);
    }
}