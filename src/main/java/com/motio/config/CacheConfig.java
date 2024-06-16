package com.motio.config;

import com.github.benmanes.caffeine.cache.CaffeineSpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
@EnableCaching
public class CacheConfig {
    @Value("${spring.cache.caffeine.spec}")
    private String caffeineSpec;
    @Value("${spring.cache.cache-names}")
    private List<String> cacheNames;

    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();
        cacheManager.setCaffeineSpec(CaffeineSpec.parse(caffeineSpec));
        cacheManager.setCacheNames(cacheNames);
        return cacheManager;
    }
}
