package com.motio.notification;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@EntityScan(basePackages = "com.motio.commons.model")
@EnableJpaRepositories(basePackages = {"com.motio.commons.repository", "com.motio.notification.repository"})
@ComponentScan(basePackages = {"com.motio.notification", "com.motio.commons"})
public class MotioNotificationApplication {

    public static void main(String[] args) {
        SpringApplication.run(MotioNotificationApplication.class, args);
    }

}
