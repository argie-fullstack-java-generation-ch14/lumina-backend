package com.lumina.exception;

// Choca con algo que ya existe (409)
public class ConflictException extends RuntimeException {

  public ConflictException(String message) {
    super(message);
  }
}
