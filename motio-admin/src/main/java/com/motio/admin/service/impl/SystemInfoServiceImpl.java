package com.motio.admin.service.impl;

import com.motio.admin.service.SystemInfoService;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

@Service
public class SystemInfoServiceImpl implements SystemInfoService {

    @Override
    public Map<String, Object> getSystemInfo() {
        return getHostSystemInfo();
    }

    private Map<String, Object> getHostSystemInfo() {
        Map<String, Object> systemInfo = new HashMap<>();

        try {
            // Pobierz informacje o pamięci
            Map<String, Long> memInfo = getMemInfo();
            systemInfo.put("totalMemory", memInfo.get("MemTotal"));
            systemInfo.put("usedMemory", memInfo.get("MemUsed"));

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

    private Map<String, Long> getMemInfo() throws IOException {
        Map<String, Long> memInfo = new HashMap<>();

        // Inicjalizacja wartości
        long memTotal = 0;
        long memFree = 0;
        long buffers = 0;
        long cached = 0;

        for (String line : Files.readAllLines(Paths.get("/proc/meminfo"))) {
            String[] parts = line.split("\\s+");
            switch (parts[0]) {
                case "MemTotal:":
                    memTotal = Long.parseLong(parts[1]) * 1024; // Konwersja z kB na bajty
                    break;
                case "MemFree:":
                    memFree = Long.parseLong(parts[1]) * 1024; // Konwersja z kB na bajty
                    break;
                case "Buffers:":
                    buffers = Long.parseLong(parts[1]) * 1024; // Konwersja z kB na bajty
                    break;
                case "Cached:":
                    cached = Long.parseLong(parts[1]) * 1024; // Konwersja z kB na bajty
                    break;
            }
        }

        // Oblicz używaną pamięć (bez cache i buforów)
        long memUsed = memTotal - memFree - buffers - cached;

        memInfo.put("MemTotal", memTotal);
        memInfo.put("MemUsed", memUsed);

        return memInfo;
    }

    private double getSystemLoadAverage() throws IOException {
        String[] loadAverages = Files.lines(Paths.get("/proc/loadavg")).findFirst().orElse("0.0").split(" ");
        return Double.parseDouble(loadAverages[0]);
    }
}
