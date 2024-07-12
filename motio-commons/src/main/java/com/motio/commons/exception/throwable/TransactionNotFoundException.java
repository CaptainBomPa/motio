package com.motio.commons.exception.throwable;

public class TransactionNotFoundException extends RuntimeException {
    public TransactionNotFoundException(Long id) {
        super("Transaction with ID " + id + " not found");
    }

    public TransactionNotFoundException() {
        super("Transaction not found");
    }
}
