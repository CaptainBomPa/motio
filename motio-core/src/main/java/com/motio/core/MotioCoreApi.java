package com.motio.core;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableCaching
@EntityScan(basePackages = "com.motio.commons.model")
@EnableJpaRepositories(basePackages = {"com.motio.core.repository", "com.motio.commons.repository"})
@ComponentScan(basePackages = {"com.motio.core", "com.motio.commons"})
public class MotioCoreApi {

	public static void main(String[] args) {
		SpringApplication.run(MotioCoreApi.class, args);
	}

}
