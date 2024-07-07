package com.motio.core.service.util;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.MetadataException;
import com.drew.metadata.exif.ExifIFD0Directory;
import org.imgscalr.Scalr;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class ImageSaveUtil {

    public static String saveImage(MultipartFile file, String directoryPath) throws IOException, ImageProcessingException, MetadataException {
        Path directory = Paths.get(directoryPath);
        if (!Files.exists(directory)) {
            Files.createDirectories(directory);
        }
        String originalFileName = file.getOriginalFilename();
        if (originalFileName != null) {
            InputStream inputStream = file.getInputStream();
            BufferedImage originalImage = ImageIO.read(inputStream);

            Metadata metadata = ImageMetadataReader.readMetadata(file.getInputStream());
            int orientation = 1;
            for (Directory direction : metadata.getDirectories()) {
                if (direction.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
                    orientation = direction.getInt(ExifIFD0Directory.TAG_ORIENTATION);
                    break; // We only need the orientation, so break after finding it
                }
            }
            BufferedImage rotatedImage = rotateImage(originalImage, orientation);
            BufferedImage resizedImage = Scalr.resize(rotatedImage, 800);
            Path filePath = directory.resolve(originalFileName);
            ImageIO.write(resizedImage, "jpg", filePath.toFile());
            ImageIO.write(resizedImage, "png", filePath.toFile());
            return filePath.toString();
        }
        throw new IllegalArgumentException("File name cannot be empty");
    }

    private static BufferedImage rotateImage(BufferedImage image, int orientation) {
        return switch (orientation) {
            case 6 -> Scalr.rotate(image, Scalr.Rotation.CW_90);
            case 3 -> Scalr.rotate(image, Scalr.Rotation.CW_180);
            case 8 -> Scalr.rotate(image, Scalr.Rotation.CW_270);
            default -> image;
        };
    }
}
