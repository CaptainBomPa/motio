package com.motio.admin.controller;

import com.motio.admin.service.SystemInfoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/system")
@Tag(name = "System", description = "Checks the system info")
public class SystemInfoController {
    private final SystemInfoService systemInfoService;

    @GetMapping("/info")
    @Operation(summary = "Gets the information about the system", description = "Returns information about the system", tags = {"System"})
    public Map<String, Object> getSystemInfo() {
        return systemInfoService.getSystemInfo();
    }
}
