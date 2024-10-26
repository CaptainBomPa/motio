package com.motio.admin.service.impl;

import com.github.dockerjava.api.DockerClient;
import com.github.dockerjava.api.model.Container;
import com.github.dockerjava.core.DefaultDockerClientConfig;
import com.github.dockerjava.core.DockerClientBuilder;
import com.github.dockerjava.httpclient5.ApacheDockerHttpClient;
import com.github.dockerjava.transport.DockerHttpClient;
import com.motio.admin.service.DockerService;
import com.motio.commons.exception.throwable.ContainerNotFoundException;
import org.springframework.stereotype.Service;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class DockerServiceImpl implements DockerService {
    private final DockerClient dockerClient;

    public DockerServiceImpl() {
        DefaultDockerClientConfig config = DefaultDockerClientConfig.createDefaultConfigBuilder()
                .withDockerHost("unix:///var/run/docker.sock")
                .build();
        DockerHttpClient httpClient = new ApacheDockerHttpClient.Builder()
                .dockerHost(config.getDockerHost())
                .sslConfig(config.getSSLConfig())
                .maxConnections(100)
                .connectionTimeout(Duration.ofSeconds(30))
                .responseTimeout(Duration.ofSeconds(45))
                .build();

        this.dockerClient = DockerClientBuilder.getInstance(config)
                .withDockerHttpClient(httpClient)
                .build();
    }

    @Override
    public void startContainer(String imageName) {
        String containerId = getContainerIdByImage(imageName);
        if (containerId == null) {
            throw new ContainerNotFoundException("Container not managed by Docker: " + imageName);
        }
        dockerClient.startContainerCmd(containerId).exec();
    }

    @Override
    public void stopContainer(String imageName) {
        String containerId = getContainerIdByImage(imageName);
        if (containerId == null) {
            throw new ContainerNotFoundException("Container not managed by Docker: " + imageName);
        }
        dockerClient.stopContainerCmd(containerId).exec();
    }

    @Override
    public List<String> listContainers() {
        if (!isRunningInDocker()) {
            return List.of();
        }
        return dockerClient.listContainersCmd()
                .exec()
                .stream()
                .map(Container::getImage)
                .collect(Collectors.toList());
    }

    private boolean isRunningInDocker() {
        return Files.exists(Paths.get("/.dockerenv"));
    }

    private String getContainerIdByImage(String imageName) {
        List<Container> containers = dockerClient.listContainersCmd().withShowAll(true).exec();
        for (Container container : containers) {
            if (container.getImage().equals(imageName)) {
                return container.getId();
            }
        }
        return null;
    }
}
