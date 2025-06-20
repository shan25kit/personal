package com.kit.project.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Fungus {
	private int id;
	private String fngsGnrlNm;
	private int fngsPilbkNo;
	private String purpose;
	private String envrionment;
}
