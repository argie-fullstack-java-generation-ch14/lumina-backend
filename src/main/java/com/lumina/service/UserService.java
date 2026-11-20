package com.lumina.service;

import com.lumina.dto.request.LoginRequest;
import com.lumina.dto.request.RegisterRequest;
import com.lumina.dto.request.UpdateUserRequest;
import com.lumina.dto.response.UserResponse;
import com.lumina.exception.ConflictException;
import com.lumina.exception.ResourceNotFoundException;
import com.lumina.exception.UnauthorizedException;
import com.lumina.model.AppUser;
import com.lumina.model.Role;
import com.lumina.repository.AppUserRepository;
import com.lumina.repository.RoleRepository;
import java.util.List;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

  private final AppUserRepository users;
  private final RoleRepository roles;
  private final PasswordEncoder passwordEncoder;

  public UserService(AppUserRepository users, RoleRepository roles, PasswordEncoder passwordEncoder) {
    this.users = users;
    this.roles = roles;
    this.passwordEncoder = passwordEncoder;
  }

  @Transactional
  public UserResponse register(RegisterRequest request) {
    // el correo es el nombre de usuario: lo guardo en minúsculas y sin espacios
    String email = request.email().trim().toLowerCase();

    if (users.existsByEmail(email)) {
      throw new ConflictException("Este correo ya está registrado.");
    }

    Role customerRole = roles.findByName("CUSTOMER")
        .orElseThrow(() -> new IllegalStateException("Falta el rol CUSTOMER en la base de datos."));

    AppUser user = new AppUser();
    user.setFullName(request.fullName().trim());
    user.setPhone(request.phone().trim());
    user.setEmail(email);
    user.setPasswordHash(passwordEncoder.encode(request.password()));
    user.setRole(customerRole);

    return UserResponse.from(users.save(user));
  }

  public UserResponse login(LoginRequest request) {
    String email = request.email().trim().toLowerCase();

    // el mensaje es el mismo si falla el correo o la contraseña, para no dar pistas
    AppUser user = users.findByEmail(email)
        .orElseThrow(() -> new UnauthorizedException("Correo o contraseña incorrectos."));

    if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
      throw new UnauthorizedException("Correo o contraseña incorrectos.");
    }

    return UserResponse.from(user);
  }

  public List<UserResponse> findAll() {
    return users.findAll().stream().map(UserResponse::from).toList();
  }

  public UserResponse findById(Long id) {
    return UserResponse.from(getUser(id));
  }

  @Transactional
  public UserResponse update(Long id, UpdateUserRequest request) {
    AppUser user = getUser(id);
    user.setFullName(request.fullName().trim());
    user.setPhone(request.phone().trim());
    return UserResponse.from(users.save(user));
  }

  @Transactional
  public void delete(Long id) {
    users.delete(getUser(id));
  }

  // También lo usan otros servicios (pedidos, velas personalizadas...)
  public AppUser getUser(Long id) {
    return users.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("No existe el usuario " + id + "."));
  }
}
