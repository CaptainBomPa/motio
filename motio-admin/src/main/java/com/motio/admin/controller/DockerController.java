package com.motio.admin.controller;

import com.motio.admin.service.DockerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/docker")
@Tag(name = "Docker", description = "Manages Docker containers")
public class DockerController {
    private final DockerService dockerService;

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/start/{containerId}")
    @Operation(summary = "Starts a container", description = "Starts a Docker container by its ID", tags = {"Docker"})
    public ResponseEntity<String> startContainer(@PathVariable String containerId) {
        dockerService.startContainer(containerId);
        return ResponseEntity.ok("Container started: " + containerId);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/stop/{containerId}")
    @Operation(summary = "Stops a container", description = "Stops a Docker container by its ID", tags = {"Docker"})
    public ResponseEntity<String> stopContainer(@PathVariable String containerId) {
        dockerService.stopContainer(containerId);
        return ResponseEntity.ok("Container stopped: " + containerId);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/list")
    @Operation(summary = "Lists all containers", description = "Lists all Docker containers", tags = {"Docker"})
    public ResponseEntity<List<String>> listContainers() {
        List<String> containers = dockerService.listContainers();
        return ResponseEntity.ok(containers);
    }
}
