package com.example.petclinic.controller;

import com.example.petclinic.model.Visit;
import com.example.petclinic.service.PetService;
import com.example.petclinic.service.VisitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/visits")
public class VisitController {

    @Autowired
    private VisitService visitService;

    @Autowired
    private PetService petService;

    @GetMapping
    public String listVisits(Model model) {
        model.addAttribute("visits", visitService.getAllVisits());
        return "visits";
    }

    @GetMapping("/add")
    public String addVisitForm(Model model) {
        model.addAttribute("visit", new Visit());
        model.addAttribute("pets", petService.getAllPets());
        return "add-visit";
    }

    @PostMapping("/add")
    public String addVisit(Visit visit) {
        visitService.saveVisit(visit);
        return "redirect:/visits";
    }
}
