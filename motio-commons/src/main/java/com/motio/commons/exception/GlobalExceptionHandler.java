package com.motio.commons.exception;

import com.motio.commons.exception.throwable.GenericObjectNotFoundException;
import com.motio.commons.exception.throwable.InvalidCredentialsException;
import com.motio.commons.exception.throwable.InvalidJwtRefreshToken;
import com.motio.commons.exception.throwable.UserNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handleGlobalException(Exception ex, WebRequest request) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler(UserNotFoundException.class)
    private ResponseEntity<?> handleUserNotFoundException(UserNotFoundException ex, WebRequest request) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(InvalidJwtRefreshToken.class)
    private ResponseEntity<?> handleInvalidRefreshToken(InvalidJwtRefreshToken ex, WebRequest request) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    private ResponseEntity<?> handleInvalidCredentials(InvalidCredentialsException ex, WebRequest request) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(GenericObjectNotFoundException.class)
    private ResponseEntity<?> handleObjectNotFound(GenericObjectNotFoundException ex, WebRequest request) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.NOT_FOUND);
    }
}
