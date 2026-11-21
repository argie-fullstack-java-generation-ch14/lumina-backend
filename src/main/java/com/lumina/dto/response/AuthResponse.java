package com.lumina.dto.response;

// Respuesta del login: token de acceso y datos del usuario autenticado
public record AuthResponse(String token, UserResponse user) {}
