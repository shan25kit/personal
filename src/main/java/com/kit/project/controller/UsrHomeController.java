package com.kit.project.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class UsrHomeController {

	@Value("${custom.api-key}")
	private String apiKey;

	@GetMapping("/usr/home/main")
	public String showMain(Model model) {
		model.addAttribute("apiKey", apiKey);
		return "usr/home/main";
	}
	@GetMapping("/usr/home/threeTest")
	public String showThree() {
		return "usr/home/threeTest";
	}
	@GetMapping("/")
	public String showRoot() {
		return "redirect:/usr/home/main";
	}

}
