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
	
	const api2 = function(fungus,tile){
		console.log(fungus,tile);
		$.ajax({
			url : 'http://apis.data.go.kr/1400119/FungiService/fngsPilbkInfo',
			type : 'GET',
			data : {
				serviceKey : '${apiKey}',
				reqFngsPilbkNo: fungus.fngsPilbkNo
				},
			dataType : 'xml',
			success : function(data) {
	
			$(data).find('item').each(function() {
							  const detail = {
							          name: $(this).find('fngsGnrlNm').text(),
							          familyKor: $(this).find('familyKorNm').text(),
							          family: $(this).find('familyNm').text(),
							          genusKor: $(this).find('genusKorNm').text(),
							          genus: $(this).find('genusNm').text(),
							          type: $(this).find('mshrmTpcdNm').text(),
							          ecology: $(this).find('fngsEclgTpcdNm').text(),
							          environment: $(this).find('grwEvrntDesc').text(),
							          season: $(this).find('occrrSsnNm').text(),
							          color: $(this).find('mshrmColorCdNm').text(),
							          shape: $(this).find('shpe').text(),
							          purpose: $(this).find('fngsPrpseTpcdNm').text()
							        };
							
					
							tile.data('detail', detail);
							console.log(detail);
							 
					const html =`
							<div class="fungus-detail" style="display: none;">
								<div>\${detail.name}</div>
							</div>
							`;
							 $(tile).append(html); 
					
						});
					},
				error : function(xhr, status, error) {
					console.log('실패:', error);
				}
			})
	};
		
	function createTile(cube, label = "") {

		  let keyStr = key(cube);
		  if (tileMap.has(keyStr)) return;
		  console.log("Trying to create tile with key:", keyStr);
		  console.log(centerCube);
		  // 중심 타일 기준 상대 좌표
		  const pixel = cubeToPixel(cube);
		  console.log(pixel);
		
		  let tile = $('<div class="hex-tile"></div>').text(label);
		  tile.css({
		    left: `calc(50% + \${pixel.x - tileWidth / 2}px)`,
		    top: `calc(50% + \${pixel.y - tileHeight / 2}px)`
		  });
		  tile.off('click').on('click', function () {
			  
			  if (key(cube) !== key(centerCube)) {
		          moveCenterTo(cube);
		          tile.css({
		        	backgroundColor: 'black',
		  			color: 'white'
		  		  });
			  }
			    $(this).find('.fungus-detail').show();
			    
			    const detail = $(this).data('detail');
			    
			    if (detail) {
			      renderToCardDeck(detail);
			    }
			    
		  });
		  tileMap.set(keyStr, tile);
		  console.log("tile instance for", keyStr, tile);
		  console.log(tileMap);
		  $('#hex-grid').append(tile);
		  
		  if (key(cube) !== key(centerCube)) {
	          $.get('/fungus/random', function(fungus) {
	        	  console.log(fungus,tile);
	        	  api2(fungus,tile);	  
			  	})
		  }
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
		/* tileMap.clear();
		$('#hex-grid').empty();  */
		const gridWidth = $('#hex-grid').width();
		const gridHeight = $('#hex-grid').height();
		createTile(centerCube, "MIS", gridWidth, gridHeight);
		const centerTile = tileMap.get(key(centerCube))
		centerTile.css({
			backgroundColor: 'black',
			color: 'white',
			fontSize: '1.5rem'
			  });
		centerTile.one('click', function () {
			  generateNeighborTiles(centerCube);
			  
		  });
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
		        x: -newCenter.x,
		        y: -newCenter.y,
		        z: -newCenter.z
		      });

		      $('#hex-grid').css('transform', `translate(\${offset.x}px, \${offset.y}px)`);

		      /* centerCube = { ...newCenter }; */
		      console.log("센터변경:",newCenter);
		      generateNeighborTiles(newCenter);
	}
	
	function renderToCardDeck(detail) {
		  const html = `
		    <div class="card">
			  <h3>\${detail.name}</h3>
		      <p><strong>과:</strong> \${detail.familyKor}</p>
		      <p><strong> \${detail.family}</strong></p>
		      <p><strong>속:</strong> \${detail.genusKor}</p>
		      <p><strong>  \${detail.genus}</strong></p>
		      <p><strong>형태:</strong> \${detail.shape}</p>
		      <p><strong>생태:</strong> \${detail.environment}</p>
		      <p><strong>계절:</strong> \${detail.season}</p>
		      <p><strong>\${detail.purpose}</strong></p>
		    </div>
		  `;
		  $('#card-deck-player').html(html);
		}
		      
</script>

<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>