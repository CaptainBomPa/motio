package com.motio.commons.exception.throwable;

public class DebtAlreadyExistsException extends RuntimeException {
    public DebtAlreadyExistsException(Long user1Id, Long user2Id) {
        super("Debt between user " + user1Id + " and user " + user2Id + " already exists");
    }
}
