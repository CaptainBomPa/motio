package com.motio.admin.controller;

import com.motio.admin.service.SystemInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/system")
public class SystemInfoController {

    private final SystemInfoService systemInfoService;

    @Autowired
    public SystemInfoController(SystemInfoService systemInfoService) {
        this.systemInfoService = systemInfoService;
    }

    @GetMapping("/info")
    public Map<String, Object> getSystemInfo() {
        return systemInfoService.getSystemInfo();
    }
}
