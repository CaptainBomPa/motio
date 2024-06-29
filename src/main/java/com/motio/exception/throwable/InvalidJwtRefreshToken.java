package com.motio.exception.throwable;

public class InvalidJwtRefreshToken extends RuntimeException {
    public InvalidJwtRefreshToken() {
        super("Invalid refresh token");
    }
}
