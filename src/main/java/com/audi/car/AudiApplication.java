package com.audi.car;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import com.audi.car.model.Car;
import com.audi.car.repository.CarRepository;

@SpringBootApplication
public class AudiApplication {

    public static void main(String[] args) {
        SpringApplication.run(AudiApplication.class, args);
    }

    @Bean
    public CommandLineRunner initDatabase(CarRepository repository) {
        return args -> {
            if (repository.count() == 0) {
                Car r8 = new Car();
                r8.setModel("Audi R8 Coupe");
                r8.setYear(2023);
                r8.setPrice(158600.0);
                r8.setColor("Mythos Black Metallic");
                r8.setImageUrl("https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?auto=format&fit=crop&w=800&q=80");

                Car etron = new Car();
                etron.setModel("Audi RS e-tron GT");
                etron.setYear(2024);
                etron.setPrice(147100.0);
                etron.setColor("Tactical Green Metallic");
                etron.setImageUrl("https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=800&q=80");

                Car rs6 = new Car();
                rs6.setModel("Audi RS6 Avant");
                rs6.setYear(2024);
                rs6.setPrice(125800.0);
                rs6.setColor("Nardo Gray");
                rs6.setImageUrl("https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80");

                repository.save(r8);
                repository.save(etron);
                repository.save(rs6);

                System.out.println("Pre-populated Audi car showroom database with premium models.");
            }
        };
    }
}
