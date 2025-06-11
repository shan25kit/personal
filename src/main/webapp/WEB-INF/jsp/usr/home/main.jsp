<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="pageTitle" value="메인" />
<%@ include file="/WEB-INF/jsp/common/header.jsp"%>

<div class="main-container">
	<%-- <div class="score">
			최고 점수: <span id="highScore">${highScore}</span>
		</div> --%>
	<div id="hex-grid" class="hex-grid"></div>
</div>
<div class="deck-area">
	<div id="card-deck-player" class="card-deck">card-deck-player</div>
	<div id="card-deck-opponent" class="card-deck">card-deck-opponent</div>
</div>

<!-- 	<div class="scoreboard">
		점수: <span id="Score">0</span>
	</div> -->

<script>

	$(document).ready(function() {
		api1();

		const size = 50;
		const tileWidth = Math.sqrt(3) * size;
		const tileHeight = 2 * size;
	
		const center = { x: 0, y: 0, z: 0};
		
		console.log("Key for tile:", { x: 0, y: 0, z: 0}); 
		const { x, y } = cubeToPixel({ x: 0, y: 0, z: 0});
		console.log("Cube to pixel:", x, y); 
		const gridWidth = $('#hex-grid').width();
		const gridHeight = $('#hex-grid').height();
		const left = (gridWidth ?? 0) / 2 + x - tileWidth / 2;
		const top = (gridHeight ?? 0) / 2 + y - tileHeight / 2;
		console.log("Calculated Position:", { left, top });
		const tile = $('<div class="hex-tile"></div>').text("MIS");
		tile.css({
		    left: left + 'px',
		    top: top + 'px'
		});

		tile.on('click', function () {
			console.log("Tile clicked:", key(center));
		    expandFrom(center, gridWidth, gridHeight);  // cube: 현재 클릭된 중앙 타일의 좌표
		});
		
		tileMap.set(key(center), true);
		$('#hex-grid').append(tile);
	})

	const api1 = function() {
		$.ajax({
					url : 'http://apis.data.go.kr/1400119/FungiService/fngsPilbkSearch',
					type : 'GET',
					data : {
						serviceKey : '${apiKey}',
						pageNo : 1,
						numOfRows : 667,
						returnType : 'xml'
					},
					dataType : 'xml',
					success : function(data) {
						const itemList = [];

						$(data).find('item').each(
								function() {
									const fngsGnrlNm = $(this).find(
											'fngsGnrlNm').text();
									const fngsPilbkNo = $(this).find(
											'fngsPilbkNo').text();

									itemList.push({
										fngsGnrlNm : fngsGnrlNm,
										fngsPilbkNo : fngsPilbkNo
									});
								});

						$.ajax({
							url : '/api/postFngsData',
							type : 'POST',
							contentType : 'application/json',
							data : JSON.stringify(itemList),
							success : function(res) {
								console.log('성공:', res);
							},
							error : function(xhr, status, error) {
								console.log('실패:', error);
							}
						});
					},
					error : function(xhr, status, error) {
						console.log('XML 요청 실패:', error);
					}
				});
	}
	
	function cubeToPixel(cube) {
	const size = 50;
	const tileWidth = Math.sqrt(3) * size;
	const tileHeight = 2 * size;
	
	    const x = size * Math.sqrt(3) * (cube.x + cube.z / 2);
	    const y = size * 3 / 2 * cube.z;
	    return { x, y };
	}
	const tileMap = new Map(); // 중복 방지용

	function key(cube) {
	    return `${cube.x},${cube.y},${cube.z}`;
	}
	
	function createTile(cube,label, gridWidth, gridHeight){
		const size = 50;
		const tileWidth = Math.sqrt(3) * size;
		const tileHeight = 2 * size;
	
/* 		console.log("Key for tile:", key(cube)); */
	
		if (tileMap.has(key(cube))) return;

		
		const { x, y } = cubeToPixel(cube);
/* 		console.log("Cube to pixel:", x, y); */
		const tile = $('<div class="hex-tile"></div>').text(label);
		
		const left = (gridWidth ?? 0) / 2 + x - tileWidth / 2;
		const top = (gridHeight ?? 0) / 2 + y - tileHeight / 2;

		console.log("Calculated Position:", { left, top });
		    
		tile.css({
		    left: left + 'px',
		    top: top + 'px'
		});
		
		tile.on('click', function () {
			console.log("Tile clicked:", key(cube));
		    expandFrom(cube, gridWidth, gridHeight);  // cube: 현재 클릭된 중앙 타일의 좌표
		});
		
		tileMap.set(key(cube), true);
		$('#hex-grid').append(tile);
	};
	
	function expandFrom(cube, gridWidth, gridHeight) {
	    const directions = [
	        { x: +1, y: -1, z: 0 },
	        { x: +1, y: 0, z: -1 },
	        { x: 0, y: +1, z: -1 },
	        { x: -1, y: +1, z: 0 },
	        { x: -1, y: 0, z: +1 },
	        { x: 0, y: -1, z: +1 },
	    ];

	    directions.forEach(dir => {
	        const neighbor = {
	            x: cube.x + dir.x,
	            y: cube.y + dir.y,
	            z: cube.z + dir.z
	        };

	        createTile(neighbor, "", gridWidth, gridHeight);
	    });
	}
	
</script>

<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>