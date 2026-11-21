package com.lumina.repository;

import com.lumina.model.Role;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> {

  Optional<Role> findByName(String name);

}
