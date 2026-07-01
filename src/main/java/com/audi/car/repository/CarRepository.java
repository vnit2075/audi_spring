package com.audi.car.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.audi.car.model.Car;

public interface CarRepository extends JpaRepository<Car, Long> {
}
