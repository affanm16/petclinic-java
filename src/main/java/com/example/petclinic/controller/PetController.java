package com.example.petclinic.controller;

import com.example.petclinic.model.Pet;
import com.example.petclinic.service.PetService;
import com.example.petclinic.service.OwnerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/pets")
public class PetController {

    @Autowired
    private PetService petService;

    @Autowired
    private OwnerService ownerService;

    @GetMapping
    public String listPets(Model model) {
        model.addAttribute("pets", petService.getAllPets());
        return "pets";
    }

    @GetMapping("/add")
    public String addPetForm(Model model) {
        model.addAttribute("pet", new Pet());
        model.addAttribute("owners", ownerService.getAllOwners());
        return "add-pet";
    }

    @PostMapping("/add")
    public String addPet(Pet pet) {
        petService.savePet(pet);
        return "redirect:/pets";
    }
}
