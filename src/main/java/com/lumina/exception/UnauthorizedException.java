package com.lumina.exception;

// Credenciales incorrectas (401)
public class UnauthorizedException extends RuntimeException {

  public UnauthorizedException(String message) {
    super(message);
  }
}
