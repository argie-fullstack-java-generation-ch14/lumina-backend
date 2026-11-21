package com.lumina.service;

import com.lumina.model.AppUser;
import com.lumina.repository.AppUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

  private final AppUserRepository appUserRepository;

  @Autowired
  public UserDetailsServiceImpl(AppUserRepository appUserRepository) {
    this.appUserRepository = appUserRepository;
  }

  @Override
  public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
    AppUser user = appUserRepository.findByEmail(email)
      .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado con email: " + email));

    String roleName = user.getRole() == null ? "CUSTOMER" : user.getRole().getName();

    return User.builder()
      .username(user.getEmail())
      .password(user.getPasswordHash())
      .roles(roleName)
      .build();
  }
}
