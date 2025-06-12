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
		/* api1(); */
		createInitialTile();
	})

	/* const api1 = function() {
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
	} */
	function createTile(cube, label = "") {

		  let keyStr = key(cube);
		  if (tileMap.has(keyStr)) return;
		  console.log("Trying to create tile with key:", keyStr);
		  console.log(centerCube);
		  // 중심 타일 기준 상대 좌표
		  const pixel = cubeToPixel(cube);
		  console.log(pixel);
		
		  const tile = $('<div class="hex-tile"></div>').text(label);
		  tile.css({
		    left: `calc(50% + \${pixel.x - tileWidth / 2}px)`,
		    top: `calc(50% + \${pixel.y - tileHeight / 2}px)`
		  });
		  tile.on('click', function () {
			  
			  if (key(cube) !== key(centerCube)) {
		          moveCenterTo(cube);}
		    
		  });
		  tileMap.set(keyStr, tile);
		  $('#hex-grid').append(tile);
	}
	
	let centerCube = { x: 0, y: 0, z: 0 };
    const size = 50;
    const tileWidth = Math.sqrt(3) * size;
    const tileHeight = 2 * size;
	const tileMap = new Map(); // 중복 생성 방지\
	
	function key(cube) {
		  return `\${cube.x},\${cube.y},\${cube.z}`;
		}
	function cubeToPixel(cube) {
		  const size = 50;
		  return {
		    x: size * Math.sqrt(3) * (cube.x + cube.z / 2),
		    y: size * 3 / 2 * cube.z
		  };
		}
	
	function createInitialTile() {
		const gridWidth = $('#hex-grid').width();
		const gridHeight = $('#hex-grid').height();
		createTile(centerCube, "MIS", gridWidth, gridHeight);
		const centerTile = tileMap.get(key(centerCube))
		centerTile.one('click', function () {
			  generateNeighborTiles(centerCube);
		  });
	/* 	tileMap.clear();
		$('#hex-grid').empty(); */
		}
	
	function generateNeighborTiles(centerCube) {
		  console.log('▶ generateNeighborTiles for', key(centerCube));
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
		      x: centerCube.x + dir.x,
		      y: centerCube.y + dir.y,
		      z: centerCube.z + dir.z
		    };
		    
		    if (!tileMap.has(key(neighbor))) {
		      createTile(neighbor, "" );
		    }
		    
		  });
		}
	function moveCenterTo(newCenter) {
		 const offset = cubeToPixel({
		        x: centerCube.x - newCenter.x,
		        y: centerCube.y - newCenter.y,
		        z: centerCube.z - newCenter.z
		      });

		      $('#hex-grid').css('transform', `translate(\${offset.x}px, \${offset.y}px)`);

		      centerCube = { ...newCenter };
		      console.log("센터변경:",centerCube);
		      generateNeighborTiles(centerCube);
	}
		      
</script>

<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>