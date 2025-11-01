package com.example.petclinic.controller;

import com.example.petclinic.model.Owner;
import com.example.petclinic.service.OwnerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/owners")
public class OwnerController {

    @Autowired
    private OwnerService ownerService;

    @GetMapping
    public String listOwners(Model model) {
        model.addAttribute("owners", ownerService.getAllOwners());
        return "owners";
    }

    @GetMapping("/add")
    public String addOwnerForm(Model model) {
        model.addAttribute("owner", new Owner());
        return "add-owner";
    }

    @PostMapping("/add")
    public String addOwner(Owner owner) {
        ownerService.saveOwner(owner);
        return "redirect:/owners";
    }
}
