package com.kit.project.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.kit.project.dao.HomeDao;
import com.kit.project.dto.Fungus;

@Service
public class HomeService {
	private HomeDao homeDao;

	public HomeService(HomeDao homeDao) {
		this.homeDao = homeDao;
	}

	public void saveAll(List<Fungus> dataList) {
		this.homeDao.saveAll(dataList);
	}
	
}
