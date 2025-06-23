<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="pageTitle" value="메인" />
<%@ include file="/WEB-INF/jsp/common/header.jsp"%>

<div class="message-area" style="display: none;">
	<div id="nickname-display"></div>
	<div id="turn-info"></div>
	<button id="end-turn" disabled>-></button>
</div>

<div class="main-container">
	<div id="hex-grid" class="hex-grid"></div>
</div>
<div class="deck-area">
	<div id="card-deck-player" class="card-deck">
		<h1>MUSHROOM CARD</h1>
		<div id="score-area-player">
			<span>Score: <strong id="total-score-player">0</strong></span>
		</div>
	</div>
	<div id="card-deck-opponent" class="card-deck">
		<div id="score-area-opponent">
			<span>Score: <strong id="total-score-opponent">0</strong></span>
			<div id="opponent-name"></div>
		</div>
	</div>
</div>


<script>

//초기 변수 및 상수 설정
const centerCube = { x: 0, y: 0, z: 0 };
const size = 50;
const tileWidth = Math.sqrt(3) * size;
const tileHeight = 2 * size;
const tileMap = new Map();

const defaultTileColor = '#f5f5f5';
const centerTileColor = 'black';

const environmentColors = {
  'leaves': '#f5debf',
  'tree': '#dcf5ec',
  'rotting': '#efe9f5',
  'soil': '#ffe2d6',
  'else': '#f5f5f5'
};

let stompClient = null;
let nickname = null;
let isSingle = true;
let totalScore = 0;

$(document).ready(function () {
  api1();
  createInitialTile();
  
 
  });

// --- 데이터 API 요청 ---
function api1() {
  $.ajax({
    url: 'http://apis.data.go.kr/1400119/FungiService/fngsPilbkSearch',
    type: 'GET',
    data: {
      serviceKey: '${apiKey}',
      pageNo: 1,
      numOfRows: 667,
      returnType: 'xml'
    },
    dataType: 'xml',
    success: function (data) {
      const itemList = [];
      $(data).find('item').each(function () {
        itemList.push({
          fngsGnrlNm: $(this).find('fngsGnrlNm').text(),
          fngsPilbkNo: $(this).find('fngsPilbkNo').text()
        });
      });

      $.ajax({
        url: '/api/postFngsData',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(itemList)
      });
    }
  });
}

function api2(fungus, tile) {
	  return new Promise((resolve, reject) => {
	    $.ajax({
	      url: 'http://apis.data.go.kr/1400119/FungiService/fngsPilbkInfo',
	      type: 'GET',
	      data: {
	        serviceKey: '${apiKey}',
	        reqFngsPilbkNo: fungus.fngsPilbkNo
	      },
	      dataType: 'xml',
	      success: function (data) {
	        $(data).find('item').each(function () {
	          const purpose = $(this).find('fngsPrpseTpcdNm').text() ?? '';
	          const detail = {
	        	fngsPilbkNo: $(this).find('fngsPilbkNo').text(),
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
	            purpose: purpose,
	            score: updateScore(purpose)
	          };
	          tile.data('detail', detail);
	          resolve(); // 데이터 세팅 완료
	        });
	      },
	      error: reject
	    });
	  });
	}


// --- 타일 생성 관련 ---
async function createTile(cube, options = {}) {
  const keyStr = key(cube);
  if (tileMap.has(keyStr)) return;

  const pixel = cubeToPixel(cube);
  const tile = $('<div class="hex-tile"></div>');
  tile.text(options.label || "");
  tile.css({
    left: `calc(50% + \${pixel.x - tileWidth / 2}px)`,
    top: `calc(50% + \${pixel.y - tileHeight / 2}px)`,
    backgroundColor: defaultTileColor
  });
  tile.data('cube', cube);

  if (key(cube) !== key(centerCube)) {
	  try {
		  const fungus = await $.ajax({ url: '/fungus/random' });
	      await api2(fungus, tile); // detail이 세팅될 때까지 대기
	    } catch (error) {
	      console.error("API 오류:", error);
	      return; // 실패 시 타일 추가하지 않음
	    }
   
  }
  
  tile.hover(function () {
	  const detail = $(this).data('detail');
	  if (!detail || $(this).data('clicked')) return; // 이미 선택된 건 hover 무시

	  const env = getEnvironmentKeyword(detail.environment);
	  tileMap.forEach(t => {
	    const d = t.data('detail');
	    if (d && !t.data('clicked') && getEnvironmentKeyword(d.environment) === env) {
	      t.css('background-color', environmentColors[env] || environmentColors['기타']);
	    }
	  });
	}, function () {
	  tileMap.forEach(t => {
	    const cube = t.data('cube');
	    if (!t.data('clicked')) {
	      t.css('background-color', isCenterTile(cube) ? centerTileColor : defaultTileColor);
	    }
	  });
	});

	tile.on('click', function () {
	  if (key(cube) !== key(centerCube)) {
          moveCenterTo(cube);}
	  const detail = $(this).data('detail');
	  if (!detail || $(this).data('clicked')) return;
	  $(this).data('clicked', true);
	  const env = getEnvironmentKeyword(detail.environment);
	  const color = environmentColors[env] || environmentColors['기타'];
	  
	  $(this).css({
		    backgroundColor: color,
		    color: 'black'
		  });

	if ($(this).find('.fungus-detail').length === 0) {
		    $(this).append(`
		    		<div class="fungus-detail">
		    	    <img class="fungus-icon" src="https://upload.wikimedia.org/wikipedia/commons/6/6b/Novosel_mushroom.svg" alt="버섯 아이콘">
		    	    <div class="fungus-name"> \${detail.name}</div>
		    	    <div class="fungus-score \${detail.score < 0 ? 'negative' : 'positive'}">
		    	      \${detail.score}
		    	    </div>
		    	  </div>
		    `);
	  };

	  updateEnvironmentBackground(env); 
	  renderToCardDeck(detail);
	});
  
  tileMap.set(keyStr, tile);
  $('#hex-grid').append(tile);
}

async function generateNeighborTiles(center) {
	  for (const dir of getCubeDirections()) {
	    const neighbor = {
	      x: center.x + dir.x,
	      y: center.y + dir.y,
	      z: center.z + dir.z
	    };
	    await createTile(neighbor);
	  }
	}


async function createInitialTile() {
  await createTile(centerCube, { label: 'M I S' });
  const tile = tileMap.get(key(centerCube));
  tile.css({ backgroundColor: centerTileColor, color: 'white', fontSize: '1.5rem' });
  
  tile.one('click', async() => {
    nickname = prompt("닉네임 입력") || "플레이어";
    const socket = new SockJS("/ws/turn");
    stompClient = Stomp.over(socket);
    stompClient.connect({}, () => {
    	
    
      stompClient.send("/app/join", {}, JSON.stringify({ nickname }));
      
      stompClient.subscribe("/topic/turn", (message) => {
    	  const turnData = JSON.parse(message.body);
    	  const current = turnData.currentPlayer;
    	  const players = turnData.players;  
        $('#turn-info').text(current === nickname ? "당신의 턴!" : `\${current}의 턴`);
        const opponent = players.find(p => p !== nickname);
        $('#opponent-name').text(opponent || '대기 중');        
        $('#end-turn').prop('disabled', current !== nickname);
      });
      
      stompClient.subscribe("/topic/score", (message) => {
      	  const { nickname: player, score } = JSON.parse(message.body);
      	  if (player === nickname) {
      	    $('#total-score-player').text(score);
      	  } else {
      	    $('#total-score-opponent').text(score);
      	  }
      	});
      
 	 stompClient.subscribe("/topic/gameover", (message) => {
      	  const { nickname: endedPlayer, message: gameMsg } = JSON.parse(message.body);
      	  const isMe = endedPlayer === nickname;

      	  alert(`${endedPlayer}님이 ${gameMsg}`);
      	  
      	  $('#turn-info').text(`게임 종료: ${endedPlayer} ${gameMsg}`);
      	  $('#end-turn').prop('disabled', true);
          $('.deck-area, .message-area').fadeOut();
      	  $('.hex-tile').off('click'); // 모든 타일 클릭 막기
      	  $('.hex-tile').off('mouseenter mouseleave');
      	});
    });
    
    $('#end-turn').on('click', () => {
      stompClient.send("/app/endTurn", {}, JSON.stringify({ nickname }));
      $('#end-turn').prop('disabled', true);
    });
     
    
    $('.deck-area').fadeIn();
    $('.message-area').fadeIn();
    $('#nickname-display').text(nickname);
   generateNeighborTiles(centerCube);
    
  });
  
}

async function moveCenterTo(newCenter) {
  const offset = cubeToPixel({ x: -newCenter.x, y: -newCenter.y, z: -newCenter.z });
  $('#hex-grid').css('transform', `translate(\${offset.x}px, \${offset.y}px)`);
  await generateNeighborTiles(newCenter);
}

// --- 카드 렌더링 ---
function renderToCardDeck(detail) {
  const envKey = getEnvironmentKeyword(detail.environment);
  const bgColor = environmentColors[envKey] || environmentColors['기타'];
  const canvasId = `canvas-\${detail.fngsPilbkNo}`;
  const html = `
    <div class="card" style="background-color: \${bgColor}; color: black;">
      <h3> \${detail.name}</h3>
      <div id="\${canvasId}" style="width:100%; height:200px;"></div>
      <p><strong>과:</strong> \${detail.familyKor} <span class="subtext">(\${detail.family})</span></p>
      <p><strong>속:</strong> \${detail.genusKor} <span class="subtext">(\${detail.genus})</span></p>
      <p><strong>발생:</strong> \${detail.environment}</p>
      <p><strong>생태:</strong> \${detail.ecology}</p>
      <p><strong>계절:</strong> \${detail.season}</p>
      <p><strong> \${detail.purpose}</strong></p>
      <div class="fungus-score \${detail.score < 0 ? 'negative' : 'positive'}" style="font-size:15px;">
      \${detail.score}점 </div>
    </div>
  `;
  $('#card-deck-player').append(html);
  renderMushroom(canvasId, detail);
  
  totalScore += detail.score;
  $('#total-score-player').text(totalScore);
  if (stompClient && stompClient.connected) {
	    stompClient.send("/app/updateScore", {}, JSON.stringify({ nickname, score: totalScore }));
	  }
}

function updateScore(purpose) {
  let score = 0;
  if (purpose.includes("식용")) score += 5;
  if (purpose.includes("약용")) score += 1;
  if (purpose.includes("독버섯")) score -= 3;
  return score;
}

// --- 유틸 함수 ---
function key(cube) {
  return `\${cube.x},\${cube.y},\${cube.z}`;
}

function isCenterTile(cube) {
  return key(cube) === key(centerCube);
}

function cubeToPixel(cube) {
  return {
    x: size * Math.sqrt(3) * (cube.x + cube.z / 2),
    y: size * 3 / 2 * cube.z
  };
}

function getCubeDirections() {
  return [
    { x: +1, y: -1, z: 0 }, { x: +1, y: 0, z: -1 }, { x: 0, y: +1, z: -1 },
    { x: -1, y: +1, z: 0 }, { x: -1, y: 0, z: +1 }, { x: 0, y: -1, z: +1 }
  ];
}

function getEnvironmentKeyword(envText) {
  if (envText.includes("낙엽") || envText.includes("이끼")) return "leaves";
  if (envText.includes("활엽수") || envText.includes("침엽수")) return "tree";
  if (envText.includes("곤충") || envText.includes("썩은나무")) return "rotting";
  if (envText.includes("땅") || envText.includes("흙")) return "soil"
  return "else";
}

function updateEnvironmentBackground(envKey) {
	  const color = environmentColors[envKey] || environmentColors['기타'];

	  tileMap.forEach(tile => {
	    const detail = tile.data('detail');
	    const cube = tile.data('cube');

	    // clicked된 타일은 유지
	    if (tile.data('clicked')) {
	      return; // 아무 작업도 하지 않음 (이미 선택된 타일은 유지)
	    }

	    if (detail && getEnvironmentKeyword(detail.environment) === envKey) {
	      tile.css({
	        backgroundColor: color,
	        color: 'black'
	      });
	    } else {
	      tile.css('background-color', isCenterTile(cube) ? centerTileColor : defaultTileColor);
	    }
	  })
	}
//--- three.js 함수 ---	
function renderMushroom(canvasId, detail) {
	  const shapeText = detail.shape || "";
	  const colorText = detail.color || "";
	  const capSizeMatch = shapeText.match(/갓의?\s*크기는?\s*(\d+(?:\.\d+)?)~(\d+(?:\.\d+)?)cm/);
	  const capSize = capSizeMatch ? (parseFloat(capSizeMatch[1]) + parseFloat(capSizeMatch[2])) / 2 : 6;
	  const stemSizeMatch = shapeText.match(/자루의?\s*크기는?\s*(\d+(?:\.\d+)?)~(\d+(?:\.\d+)?)/);
	  const stemLength = stemSizeMatch ? parseFloat(stemSizeMatch[1]) : 7;
	  const capColor = getMushroomColor(shapeText, colorText, 'cap');
	  const stemColor = getMushroomColor(shapeText, colorText, 'stem');
	    
	  const $container = $('#' + canvasId); // jQuery 객체
	  if ($container.length === 0) return;  // 안전성 체크
	  const container = $container[0];      // DOM element

	  const scene = new THREE.Scene();
	  const camera = new THREE.PerspectiveCamera(45, 1, 0.1, 1000);
	  camera.position.set(0, 1, 3);

	  const renderer = new THREE.WebGLRenderer({ alpha: true });
	  renderer.setSize($container.width(), 200);
	  renderer.shadowMap.enabled = true;
	  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
	  $container.empty();
	  $container.append(renderer.domElement);

	  const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
	  directionalLight.position.set(5, 10, 7);
	  directionalLight.castShadow = true;
	  directionalLight.shadow.mapSize.width = 2048;
	  directionalLight.shadow.mapSize.height = 2048;
	  scene.add(directionalLight);
	  
	  const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
	  scene.add(ambientLight);

	  // 배경 텍스처
	  applyEnvironmentTexture(scene, detail.environment);

	  // 자루
	const stemHeight = stemLength * 0.15;
    const stemGeometry = new THREE.CylinderGeometry(
        capSize * 0.02, // 윗부분 반지름
        capSize * 0.025, // 아랫부분 반지름  
        stemHeight, // 높이
        16
    );
	  const stemMaterial = new THREE.MeshStandardMaterial({ 
        color: stemColor,
        roughness: 0.8,
        metalness: 0.1
  	  });
	  const stem = new THREE.Mesh(stemGeometry, stemMaterial);
	    stem.position.y = stemHeight / 2;;
	    stem.castShadow = true;
	    stem.receiveShadow = true;
	    scene.add(stem);
	    
	    // 갓
	   const capRadius = Math.max(capSize * 0.06, 0.3);
	    
	   let capGeometry;

	   if (shapeText.includes("편평형")) {
	     capGeometry = new THREE.CylinderGeometry(
	       capRadius * 1.2, capRadius, capRadius * 0.2, 32
	     );

	   } else if (shapeText.includes("종형")) {
	     capGeometry = new THREE.ConeGeometry(
	       capRadius * 0.8, capRadius * 2.2, 32
	     );

	   } else if (shapeText.includes("원뿔형")) {
	     capGeometry = new THREE.ConeGeometry(
	       capRadius, capRadius * 1.8, 32
	     );

	   } else if (shapeText.includes("깔때기형")) {
	     capGeometry = new THREE.ConeGeometry(
	       capRadius, capRadius * 0.8, 32
	     );
	     capGeometry.scale(1, -1, 1); // 아래로 뒤집기

	   } else if (shapeText.includes("중앙오목형")) {
	     capGeometry = new THREE.TorusGeometry(
	       capRadius * 0.7, capRadius * 0.3, 16, 32
	     );
	     capGeometry.rotateX(Math.PI / 2);

	   } else if (shapeText.includes("중앙볼록형")) {
	     capGeometry = new THREE.SphereGeometry(
	       capRadius, 32, 16
	     );
	     capGeometry.scale(1, 1.5, 1); // 볼록하게

	   } else {
	     // 기본: 반구형
	     capGeometry = new THREE.SphereGeometry(
	       capRadius, 32, 16,
	       0, Math.PI * 2,
	       0, Math.PI / 1.6
	     );
	   }
        
        const capMaterial = new THREE.MeshStandardMaterial({
            color: capColor,
            roughness: 0.6,
            metalness: 0.05
        });
        
        const cap = new THREE.Mesh(capGeometry, capMaterial);
        
        const capYOffset = (() => {
        	  if (shapeText.includes("중앙오목형")) return 0.2;
        	  if (shapeText.includes("깔때기형")) return 0.1;
        	  if (shapeText.includes("편평형")) return 0.15;
        	  return 0.3;
        	})();
        	cap.position.y = stemHeight + capYOffset;
        cap.scale.y = 0.6;
        cap.castShadow = true;
        cap.receiveShadow = true;
        scene.add(cap);
	

    const groundGeometry = new THREE.PlaneGeometry(20, 20);
    const groundMaterial = new THREE.MeshStandardMaterial({ 
        color: 0x8B7355, 
        transparent: true, 
        opacity: 0.3 
    });
    const ground = new THREE.Mesh(groundGeometry, groundMaterial);
    ground.rotation.x = -Math.PI / 2;
    ground.receiveShadow = true;
    scene.add(ground);
    
	  // 애니메이션
    let time = 0;
    const initialCapY = stemHeight + capRadius * 0.1;
    function animate() {
        requestAnimationFrame(animate);
        time += 0.01;
        
        // Gentle rotation and slight bobbing
        cap.rotation.y += 0.005;
        cap.position.y = initialCapY + Math.sin(time) * 0.02;
        stem.rotation.z = Math.sin(time) * 0.02;
        renderer.render(scene, camera);
    }
    animate();

	}
function getMushroomColor(shapeText, colorText, part) {
    const text = (shapeText + " " + colorText).toLowerCase();
    
    // Color mapping for different mushroom parts
    const colorMap = {
        // Browns and earth tones
        '갈색': '#8B4513',
        '회갈색': '#8B7355',
        '연갈색': '#CD853F',
        '진갈색': '#654321',
        '황갈색': '#B8860B',
        
        // Grays
        '회색': '#808080',
        '연회색': '#C0C0C0',
        '진회색': '#555555',
        '회백색': '#F5F5F5',
        
        // Other colors
        '흰색': '#FFFFFF',
        '백색': '#FFFFFF',
        '검정색': '#2F2F2F',
        '검은색': '#2F2F2F',
        '황색': '#FFD700',
        '노란색': '#FFDD00',
        '주황색': '#FF8C00',
        '붉은색': '#CD5C5C',
        '적색': '#CD5C5C'
    };
    
    // Check for color matches
    for (const [korean, hex] of Object.entries(colorMap)) {
        if (text.includes(korean)) {
            return hex;
        }
    }
    
    // Default colors based on part
    if (part === 'stem') {
        return '#F0E68C'; // Light khaki for stem
    } else {
        return '#A0522D'; // Sienna for cap
    }
}

	function applyEnvironmentTexture(scene, environmentText) {
	  const loader = new THREE.TextureLoader();

	 if (environmentText.includes("활엽수")|| environmentText.includes("침엽수")) {
	    loader.load('/images/tree.jpg', texture => {
	      scene.background = texture;
	    });
	  } else if (environmentText.includes("땅") || environmentText.includes("흙")) {
	    loader.load('/images/soil.jpg', texture => {
	      scene.background = texture;
	  		  });
	  } else if (environmentText.includes("낙엽") || environmentText.includes("이끼")) {
		    loader.load('/images/leaves.jpg', texture => {
			      scene.background = texture;
			  });
	  } else if (environmentText.includes("썩은나무") || environmentText.includes("곤충")) {
		   loader.load('/images/rotting.jpg', texture => {
					scene.background = texture;
			   });
	  } else {
	    scene.background = new THREE.Color(0xe0e0e0);
	  }
	}	
	
</script>

<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>