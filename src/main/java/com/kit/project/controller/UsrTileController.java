package com.kit.project.controller;

import java.util.Random;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kit.project.dto.Fungus;
import com.kit.project.service.FungusService;

@Controller
public class UsrTileController {
	private FungusService fungusService;

	public UsrTileController(FungusService fungusService) {
		this.fungusService = fungusService;
	}
	
	@GetMapping("/fungus/random")
	@ResponseBody
	public ResponseEntity<Fungus> getRandomFungus() {
	    Random rand = new Random();
        int id = rand.nextInt(666) + 1;
        Fungus fungus = fungusService.getFungusById(id);
	    
	    return ResponseEntity.ok(fungus);
	}
}
