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
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getFngsGnrlNm() {
		return fngsGnrlNm;
	}
	public void setFngsGnrlNm(String fngsGnrlNm) {
		this.fngsGnrlNm = fngsGnrlNm;
	}
	public int getFngsPilbkNo() {
		return fngsPilbkNo;
	}
	public void setFngsPilbkNo(int fngsPilbkNo) {
		this.fngsPilbkNo = fngsPilbkNo;
	}
	public String getPurpose() {
		return purpose;
	}
	public void setPurpose(String purpose) {
		this.purpose = purpose;
	}
	public String getEnvrionment() {
		return envrionment;
	}
	public void setEnvrionment(String envrionment) {
		this.envrionment = envrionment;
	}
}
