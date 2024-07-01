package com.motio.core.config.dev;

import org.springframework.beans.factory.DisposableBean;

import java.util.Collection;

public interface ModelInitializer<T> extends DisposableBean {

    Collection<T> initializeObjects();

    void addContextObjects(Collection<?> objects, Class<?> type);
}
