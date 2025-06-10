package com.kit.project.controller;

import java.util.Random;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.kit.project.dto.Fungus;
import com.kit.project.service.FungusService;

@Controller
public class UsrTileController {
	private FungusService fungusService;

	public UsrTileController(FungusService fungusService) {
		this.fungusService = fungusService;
	}
	
	@GetMapping("/fungus/random")
	public ResponseEntity<Fungus> getRandomFungus(Model model) {
	    Random rand = new Random();
        int id = rand.nextInt(667) + 1;
        Fungus fungus = fungusService.getFungusById(id);
	    model.addAttribute("fungus",fungus);
	    
	    return ResponseEntity.ok(fungus);
	}
}
