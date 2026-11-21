package com.lumina.exception;

// Datos que no se pueden procesar (400)
public class BadRequestException extends RuntimeException {

  public BadRequestException(String message) {
    super(message);
  }
}
