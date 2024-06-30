package com.motio.config;

import com.motio.service.sender.ShoppingListUpdateSender;
import org.mockito.Mockito;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TestConfig {

    @Bean
    public ShoppingListUpdateSender shoppingListUpdateSender() {
        return Mockito.mock(ShoppingListUpdateSender.class);
    }
}
