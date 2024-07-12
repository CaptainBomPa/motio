package com.motio.commons.exception.throwable;

public class DebtNotFoundException extends RuntimeException {
    public DebtNotFoundException(Long id) {
        super("Debt with ID " + id + " not found");
    }

    public DebtNotFoundException() {
        super("Debt not found");
    }
}
