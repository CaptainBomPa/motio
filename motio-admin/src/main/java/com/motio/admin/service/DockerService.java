package com.motio.admin.service;

import java.util.List;

public interface DockerService {
    void startContainer(String containerId);

    void stopContainer(String containerId);

    List<String> listContainers();
}
