package com.motio.service;

import org.springframework.core.io.Resource;

import java.io.IOException;

public interface ImageService {
    Resource loadImage(String imagePath) throws IOException;
}
