package com.motio.core.service.impl;

import com.motio.core.service.ImageService;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
public class ImageServiceImpl implements ImageService {

    @Override
    public Resource loadImage(String imagePath) throws IOException {
        if (imagePath == null) {
            return null;
        }
        Path path = Paths.get(imagePath);
        Resource resource = new UrlResource(path.toUri());

        if (!resource.exists() || !resource.isReadable()) {
            throw new RuntimeException("Could not read the file!");
        }

        return resource;
    }
}
