package com.motio.commons.exception.throwable;

public class NotSufficientRoleException extends RuntimeException {
    public NotSufficientRoleException() {
        super("User has not sufficient role to login as admin");
    }
}
