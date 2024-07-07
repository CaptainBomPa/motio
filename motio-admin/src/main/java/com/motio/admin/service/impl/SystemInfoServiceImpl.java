package com.motio.admin.service.impl;

import com.motio.admin.service.SystemInfoService;
import org.springframework.stereotype.Service;

import java.lang.management.ManagementFactory;
import java.lang.management.OperatingSystemMXBean;
import java.util.HashMap;
import java.util.Map;

@Service
public class SystemInfoServiceImpl implements SystemInfoService {

    @Override
    public Map<String, Object> getSystemInfo() {
        Map<String, Object> systemInfo = new HashMap<>();

        OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
        systemInfo.put("availableProcessors", osBean.getAvailableProcessors());
        systemInfo.put("systemLoadAverage", osBean.getSystemLoadAverage());

        Runtime runtime = Runtime.getRuntime();
        systemInfo.put("totalMemory", runtime.totalMemory());
        systemInfo.put("freeMemory", runtime.freeMemory());
        systemInfo.put("maxMemory", runtime.maxMemory());

        return systemInfo;
    }
}
