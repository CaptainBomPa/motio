package com.motio.core.config;

import com.motio.core.service.sender.TodoListUpdateSender;
import org.mockito.Mockito;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TestConfig {

    @Bean
    public TodoListUpdateSender todoListUpdateSender() {
        return Mockito.mock(TodoListUpdateSender.class);
    }
}
