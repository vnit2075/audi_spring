package com.audi.car.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.audi.car.model.Car;
import com.audi.car.repository.CarRepository;

@Controller
public class CarController {

    @Autowired
    private CarRepository carRepository;

    // Home page - list all cars
    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("cars", carRepository.findAll());
        return "index"; // loads index.html
    }

    // Show add form
    @GetMapping("/cars/add")
    public String addCarForm(Model model) {
        model.addAttribute("car", new Car());
        return "car-form"; // loads car-form.html
    }

    // Show edit form
    @GetMapping("/cars/edit/{id}")
    public String editCarForm(@PathVariable Long id, Model model) {
        Car car = carRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Car not found with id " + id));
        model.addAttribute("car", car);
        return "car-form"; // loads car-form.html
    }

    // Save car (create or update)
    @PostMapping("/cars/save")
    public String saveCar(@ModelAttribute("car") Car car) {
        // Set a default premium placeholder image if none is provided
        if (car.getImageUrl() == null || car.getImageUrl().trim().isEmpty()) {
            car.setImageUrl("https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80");
        }
        carRepository.save(car);
        return "redirect:/";
    }

    // Delete car
    @GetMapping("/cars/delete/{id}")
    public String deleteCar(@PathVariable Long id) {
        carRepository.deleteById(id);
        return "redirect:/";
    }
}
