package com.motio.admin.service.impl;

import com.motio.admin.service.SystemInfoService;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.management.OperatingSystemMXBean;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Stream;

@Service
public class SystemInfoServiceImpl implements SystemInfoService {

    @Override
    public Map<String, Object> getSystemInfo() {
        Map<String, Object> systemInfo = new HashMap<>();

        if (isRunningInDocker()) {
            systemInfo.putAll(getHostSystemInfo());
        } else {
            systemInfo.putAll(getLocalSystemInfo());
        }

        return systemInfo;
    }

    private boolean isRunningInDocker() {
        try (Stream<String> stream = Files.lines(Paths.get("/proc/1/cgroup"))) {
            return stream.anyMatch(line -> line.contains("/docker"));
        } catch (IOException e) {
            return false;
        }
    }

    private Map<String, Object> getHostSystemInfo() {
        Map<String, Object> systemInfo = new HashMap<>();

        try {
            // Pobierz informacje o pamięci
            Map<String, Long> memInfo = getMemInfo();
            systemInfo.put("totalMemory", memInfo.get("MemTotal"));
            systemInfo.put("availableMemory", memInfo.get("MemAvailable"));

            // Pobierz informacje o procesorach
            long availableProcessors = Files.lines(Paths.get("/proc/cpuinfo"))
                    .filter(line -> line.startsWith("processor"))
                    .count();
            systemInfo.put("availableProcessors", availableProcessors);

            // Pobierz średnie obciążenie systemu
            double systemLoadAverage = getSystemLoadAverage();
            systemInfo.put("systemLoadAverage", systemLoadAverage);
        } catch (IOException e) {
            systemInfo.put("error", "Unable to read system info from host");
        }

        return systemInfo;
    }

    private Map<String, Object> getLocalSystemInfo() {
        Map<String, Object> systemInfo = new HashMap<>();

        OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();

        // Pobierz podstawowe informacje o systemie
        systemInfo.put("availableProcessors", osBean.getAvailableProcessors());
        systemInfo.put("systemLoadAverage", osBean.getSystemLoadAverage());

        // Rzutowanie na com.sun.management.OperatingSystemMXBean, aby uzyskać dodatkowe informacje
        if (osBean instanceof com.sun.management.OperatingSystemMXBean) {
            com.sun.management.OperatingSystemMXBean sunOsBean = (com.sun.management.OperatingSystemMXBean) osBean;
            systemInfo.put("totalPhysicalMemorySize", sunOsBean.getTotalPhysicalMemorySize());
            systemInfo.put("availablePhysicalMemorySize", sunOsBean.getFreePhysicalMemorySize());
            systemInfo.put("usedPhysicalMemorySize", sunOsBean.getTotalPhysicalMemorySize() - sunOsBean.getFreePhysicalMemorySize());
        }

        // Pobierz informacje o pamięci JVM
        Runtime runtime = Runtime.getRuntime();
        systemInfo.put("jvmTotalMemory", runtime.totalMemory());
        systemInfo.put("jvmFreeMemory", runtime.freeMemory());
        systemInfo.put("jvmMaxMemory", runtime.maxMemory());

        return systemInfo;
    }

    private Map<String, Long> getMemInfo() throws IOException {
        Map<String, Long> memInfo = new HashMap<>();

        Files.lines(Paths.get("/proc/meminfo")).forEach(line -> {
            String[] parts = line.split("\\s+");
            if (parts[0].startsWith("MemTotal:")) {
                memInfo.put("MemTotal", Long.parseLong(parts[1]) * 1024); // Konwersja z kB na bajty
            } else if (parts[0].startsWith("MemAvailable:")) {
                memInfo.put("MemAvailable", Long.parseLong(parts[1]) * 1024); // Konwersja z kB na bajty
            }
        });

        return memInfo;
    }

    private double getSystemLoadAverage() throws IOException {
        String[] loadAverages = Files.lines(Paths.get("/proc/loadavg")).findFirst().orElse("0.0").split(" ");
        return Double.parseDouble(loadAverages[0]);
    }
}
