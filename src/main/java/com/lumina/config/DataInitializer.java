package com.lumina.config;

import com.lumina.model.AppUser;
import com.lumina.model.Role;
import com.lumina.repository.AppUserRepository;
import com.lumina.repository.RoleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

// Al arrancar, crea los roles y un usuario admin de prueba si todavía no existen.
// Así el registro y el login funcionan aunque no se haya corrido un script de datos iniciales.
@Configuration
public class DataInitializer {

  @Bean
  CommandLineRunner createBasicData(RoleRepository roles, AppUserRepository users, PasswordEncoder encoder) {
    return args -> {
      createRole(roles, "ADMIN", "Gestiona productos, pedidos y usuarios.");
      createRole(roles, "CUSTOMER", "Compra productos y administra sus pedidos.");
      createRole(roles, "STAFF", "Apoya la gestion de pedidos.");

      Role adminRole = roles.findByName("ADMIN").orElseThrow();
      if (users.findByEmail("admin@lumina.com").isEmpty()) {
        AppUser admin = new AppUser();
        admin.setFullName("Administrador");
        admin.setPhone("3000000000");
        admin.setEmail("admin@lumina.com");
        admin.setPasswordHash(encoder.encode("Admin123"));
        admin.setRole(adminRole);
        users.save(admin);
      }
    };
  }

  private void createRole(RoleRepository roles, String name, String description) {
    if (roles.findByName(name).isEmpty()) {
      Role role = new Role();
      role.setName(name);
      role.setDescription(description);
      roles.save(role);
    }
  }
}
