package com.motio.service.util;

import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class ImageSaveUtil {

    public static String saveImage(MultipartFile file, String directoryPath) throws IOException {
        Path directory = Paths.get(directoryPath);
        if (!Files.exists(directory)) {
            Files.createDirectories(directory);
        }
        String originalFileName = file.getOriginalFilename();
        if (originalFileName != null) {
            Path filePath = directory.resolve(file.getOriginalFilename());
            Files.write(filePath, file.getBytes());
            return filePath.toString();
        }
        throw new IllegalArgumentException("File name cannot be empty");
    }
}
