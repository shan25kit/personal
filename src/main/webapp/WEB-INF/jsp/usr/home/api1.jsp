<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="pageTitle" value="API Test" />

<%@ include file="/WEB-INF/jsp/common/header.jsp"%>

<script>
		const api_key = '/GqDl/lZoJANdiXzVbb0Uz1cswM/8Gw9xSMjNUmVt1PVcFGKIXy63kroYJKIgkNM+reraQP098nIRsBOmOjBSQ==';
		const url = 'http://apis.data.go.kr/1400119/FungiService/fngsPilbkSearch';
		const api1 = function () {
		    $.ajax({
		        url: url,
		        type: 'GET',
		        data: {
		            serviceKey: api_key,
		            pageNo: 1,
		            numOfRows: 667,
		            returnType: 'xml'
		        },
		        dataType: 'xml',
		        success: function (data) {
		            const itemList = [];

		            $(data).find('item').each(function () {
		                const fngsGnrlNm = $(this).find('fngsGnrlNm').text();
		                const fngsPilbkNo = $(this).find('fngsPilbkNo').text();

		                itemList.push({
		                    fngsGnrlNm: fngsGnrlNm,
		                    fngsPilbkNo: fngsPilbkNo
		                });
		            });

		            // 서버로 전송
		            $.ajax({
		                url: '/api/fngs-data',  // Spring 컨트롤러 매핑 주소
		                type: 'POST',
		                contentType: 'application/json',
		                data: JSON.stringify(itemList),
		                success: function (res) {
		                    console.log('성공:', res);
		                },
		                error: function (xhr, status, error) {
		                    console.log('실패:', error);
		                }
		            });
		        },
		        error: function (xhr, status, error) {
		            console.log('XML 요청 실패:', error);
		        }
		    });
		}

		api1();
	
	</script>

<section class="mt-8">
	<div class="container mx-auto">
		<div>API TEST 페이지 입니다</div>
	</div>
</section>

<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>
