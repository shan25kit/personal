package com.kit.project.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.kit.project.dao.FungusDao;
import com.kit.project.dto.Fungus;

@Service
public class FungusService {
	private FungusDao fungusDao;

	public FungusService(FungusDao apiDao) {
		this.fungusDao = apiDao;
	}

	public void postFngsdata(List<Fungus> dataList) {
		this.fungusDao.postFngsdata(dataList);
	}

	public Fungus getFungusById(int id) {
		return this.fungusDao.getFungusById(id);
	}
	
}
