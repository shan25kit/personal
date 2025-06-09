package com.kit.project.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import com.kit.project.dto.Fungus;
import com.kit.project.service.HomeService;
@Controller
public class UsrHomeController {
	
	private HomeService homeService;

	public UsrHomeController(HomeService homeService) {
		this.homeService = homeService;
	}
	@GetMapping("/usr/home/main")
	public String showMain() {

		return "usr/home/main";
	}
	@GetMapping("/usr/home/api1")
	public String api1() {
		return "usr/home/api1";
	}
	@PostMapping("/api/fngs-data")
    public ResponseEntity<String> saveData(@RequestBody List<Fungus> dataList) {
		homeService.saveAll(dataList);
        return ResponseEntity.ok("데이터 저장 완료");
    }	
	}
			