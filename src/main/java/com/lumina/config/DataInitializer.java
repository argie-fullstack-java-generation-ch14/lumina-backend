package com.lumina.config;

import com.lumina.usuario.Role;
import com.lumina.usuario.RoleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

// Al arrancar, crea los roles si todavía no existen.
// Así el registro funciona aunque no se haya corrido un script de datos iniciales.
@Configuration
public class DataInitializer {

  @Bean
  CommandLineRunner createBasicData(RoleRepository roles) {
    return args -> {
      createRole(roles, "ADMIN", "Gestiona productos, pedidos y usuarios.");
      createRole(roles, "CUSTOMER", "Compra productos y administra sus pedidos.");
      createRole(roles, "STAFF", "Apoya la gestion de pedidos.");
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
