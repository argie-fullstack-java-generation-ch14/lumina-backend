package com.lumina.repository;

import com.lumina.model.Product;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {

  Optional<Product> findBySlug(String slug);

  boolean existsBySlug(String slug);

  List<Product> findByAvailableTrue();

  List<Product> findByCategoryIgnoreCase(String category);

  List<Product> findByCategoryIgnoreCaseAndAvailableTrue(String category);

}
