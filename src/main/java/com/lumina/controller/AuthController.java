package com.lumina.controller;

import com.lumina.dto.request.LoginRequest;
import com.lumina.dto.response.AuthResponse;
import com.lumina.dto.response.UserResponse;
import com.lumina.model.AppUser;
import com.lumina.repository.AppUserRepository;
import com.lumina.security.JwtUtil;
import com.lumina.service.UserDetailsServiceImpl;
import jakarta.validation.Valid;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class AuthController {

  private final AuthenticationManager authenticationManager;
  private final UserDetailsServiceImpl userDetailsService;
  private final JwtUtil jwtUtil;
  private final AppUserRepository users;

  public AuthController(AuthenticationManager authenticationManager,
                        UserDetailsServiceImpl userDetailsService,
                        JwtUtil jwtUtil,
                        AppUserRepository users) {
    this.authenticationManager = authenticationManager;
    this.userDetailsService = userDetailsService;
    this.jwtUtil = jwtUtil;
    this.users = users;
  }

  @PostMapping("/login")
  public AuthResponse login(@Valid @RequestBody LoginRequest request) {
    authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(request.email(), request.password()));

    UserDetails userDetails = userDetailsService.loadUserByUsername(request.email());
    String token = jwtUtil.generateToken(userDetails);

    AppUser user = users.findByEmail(request.email())
        .orElseThrow(() -> new IllegalStateException("Usuario no encontrado tras autenticación"));

    return new AuthResponse(token, UserResponse.from(user));
  }
}
