package com.motio.exception.throwable;

public class GenericObjectNotFoundException extends RuntimeException {
    public GenericObjectNotFoundException(Class<?> type) {
        super(type.getSimpleName() + " not found");
    }
}
