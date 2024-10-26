package com.motio.commons.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
@Tag(name = "Health Check", description = "Health check of API")
public class HealthCheckController {

    /**
     * This controller is intended to run on each service.
     * It might be later expanded to serve more status information
     * As of now, it returns only HTTP OK
     */
    @GetMapping("/status")
    @Operation(summary = "Status of the service", description = "Return HTTP OK if service is available", tags = {"Health"})
    public ResponseEntity<Void> status() {
        return ResponseEntity.ok().build();
    }
}
