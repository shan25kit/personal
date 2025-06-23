package com.kit.project.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.kit.project.dto.Fungus;
import com.kit.project.service.FungusService;

@Controller
public class ApiController {

	private FungusService fungusService;
	
	public ApiController(FungusService fungusService) {
		this.fungusService = fungusService;
	}


	@PostMapping("/api/postFngsData")
	@ResponseBody
	public ResponseEntity<String> postFngsdata(@RequestBody List<Fungus> dataList) {
		fungusService.postFngsdata(dataList);
		return ResponseEntity.ok("데이터 저장 완료");
	}
}
