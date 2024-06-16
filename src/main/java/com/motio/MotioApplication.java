package com.motio;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class MotioApplication {

	public static void main(String[] args) {
		SpringApplication.run(MotioApplication.class, args);
	}

}
