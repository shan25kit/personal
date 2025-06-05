package com.kit.project.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class UsrHomeController {
	
	@GetMapping("/usr/home/main")
	public String showMain() {
	return "usr/home/main";
}
}
