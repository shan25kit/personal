package com.kit.project.util;

import org.w3c.dom.*;
import javax.xml.parsers.*;
import java.io.File;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/*
 * public class Util {
 * 
 * public static void XmlToMySQL() { String xmlFilePath =
 * "C:/Users/admin/Downloads/response_1749018849525.xml";
 * 
 * String url = "jdbc:mysql://localhost:3306/MIS_D";
 * 
 * String user = "root"; String password = "";
 * 
 * try { // 1. XML 파싱 File xmlFile = new File(xmlFilePath);
 * DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
 * DocumentBuilder builder = factory.newDocumentBuilder(); Document doc =
 * builder.parse(xmlFile); doc.getDocumentElement().normalize();
 * 
 * NodeList itemList = doc.getElementsByTagName("item");
 * 
 * // 2. MySQL 연결 Connection conn = DriverManager.getConnection(url, user,
 * password); String sql =
 * "INSERT INTO fungus (familyKorNm, familyNm, fngsGnrlNm, fngsPilbkNo, fngsScnm, genusKorNm, genusNm, lastUpdtDtm) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
 * ; PreparedStatement pstmt = conn.prepareStatement(sql);
 * 
 * // 3. 아이템 반복 처리 for (int i = 0; i < itemList.getLength(); i++) { Node node =
 * itemList.item(i); if (node.getNodeType() == Node.ELEMENT_NODE) { Element e =
 * (Element) node;
 * 
 * pstmt.setString(1, getTagValue(e, "familyKorNm")); pstmt.setString(2,
 * getTagValue(e, "familyNm")); pstmt.setString(3, getTagValue(e,
 * "fngsGnrlNm"));
 * 
 * String pilbkNo = getTagValue(e, "fngsPilbkNo"); pstmt.setInt(4, pilbkNo !=
 * null && !pilbkNo.isEmpty() ? Integer.parseInt(pilbkNo) : 0);
 * 
 * pstmt.setString(5, getTagValue(e, "fngsScnm")); pstmt.setString(6,
 * getTagValue(e, "genusKorNm")); pstmt.setString(7, getTagValue(e, "genusNm"));
 * 
 * String dateStr = getTagValue(e, "lastUpdtDtm"); if (dateStr != null &&
 * dateStr.length() == 8) { LocalDate date = LocalDate.parse(dateStr,
 * DateTimeFormatter.ofPattern("yyyyMMdd")); pstmt.setDate(8,
 * Date.valueOf(date)); } else { pstmt.setDate(8, null); }
 * 
 * pstmt.executeUpdate(); } }
 * 
 * pstmt.close(); conn.close();
 * System.out.println("XML 데이터가 성공적으로 MySQL에 삽입되었습니다.");
 * 
 * } catch (Exception e) { e.printStackTrace(); } }
 * 
 * // XML 태그 값 추출 헬퍼 메서드 private static String getTagValue(Element element,
 * String tag) { NodeList list = element.getElementsByTagName(tag); if
 * (list.getLength() > 0 && list.item(0).getTextContent() != null) { return
 * list.item(0).getTextContent().trim(); } return null; } }
 */