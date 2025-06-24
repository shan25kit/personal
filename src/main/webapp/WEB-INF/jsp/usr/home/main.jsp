<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="pageTitle" value="메인" />
<%@ include file="/WEB-INF/jsp/common/header.jsp"%>



  <div id="mode-select-modal" class="modal">
    <div class="modal-box">
      <h2>Mushroom Information System에 오신 것을 환영합니다.</h2>
      <div class="form-control">
        <label for="nickname-input">코드명:</label>
        <input type="text" id="nickname-input" placeholder="닉네임을 입력하세요" />
      </div>

      <div class="radio-group">
        <div class="custom-radio">
          <input type="radio" name="mode" value="single" checked />
          <label>싱글 플레이</label>
        </div>
        <div class="custom-radio">
          <input type="radio" name="mode" value="multi" />
          <label>멀티 플레이 (테스트)</label>
        </div>
      </div>

      <div class="modal-action">
        <button class="btn" id="start-game-btn">시작</button>
      </div>
    </div>
  </div>

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
		<h2>MUSHROOM CARD</h2>
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
let nickname = "";
let isSingle = true;
let isMyTurn = false;
let totalScore = 0;

$(document).ready(async function () {
	  try {
	    await initializeGame();
	  } catch (error) {
	    console.error("게임 초기화 실패:", error);
	    showErrorMessage("게임을 시작할 수 없습니다.");
	  }
	});
async function initializeGame() {
	  $('#mode-select-modal').hide();
	  
	  // 버섯 데이터 초기화
	  await initializeFungusData();
	  
	  // 중앙 타일 생성
	  await createInitialTile();
	  
	  console.log("게임 초기화 완료");
	}
	
//--- 데이터 API 요청 (async/await 변환) ---
async function initializeFungusData() {
  try {
    await api1();
    console.log("버섯 데이터 초기화 완료");
  } catch (error) {
    console.error("버섯 데이터 초기화 실패:", error);
    throw error;
  }
}
// --- 데이터 API 요청 ---
async function api1() {
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
		dataType: 'json',
        data: JSON.stringify(itemList)
      });
    }
  });
}

async function api2(fungus, tile) {
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
	
//---닉네임 세팅 플레이 모드 세팅 ---	
$(document).on('click', '#start-game-btn', async() => {
  nickname = $('#nickname-input').val() || '플레이어';
  console.log(nickname);
  isSingle = $('input[name="mode"]:checked').val() === 'single';
  console.log(isSingle);
  $('#nickname-display').text(nickname);
  $('#mode-select-modal').hide();
  $('#game-screen').show();
  $('.deck-area').fadeIn();
  $('.message-area').fadeIn();

  if (isSingle) {
	     startSinglePlayerMode();
	  } else {
	     startMultiPlayerMode();
	  }
});
async function startSinglePlayerMode() {
	  console.log("싱글플레이 모드 시작");
	  await generateNeighborTiles(centerCube);
	}
async function startMultiPlayerMode() {
	  console.log("멀티플레이 모드 시작");
	  await setupMultiplayer();
	}	
async function setupMultiplayer() {
	  return new Promise((resolve, reject) => {
	    const socket = new SockJS("/ws/turn");
	    stompClient = Stomp.over(socket);

	    stompClient.connect({}, async () => {
	      try {
	        // 게임 참가
	        await sendWebSocketMessage("/app/join", { nickname });
	        
	        // 구독 설정
	        setupWebSocketSubscriptions();
	        
	        // UI 설정
	        setupMultiplayerUI();
	        
	        resolve();
	      } catch (error) {
	        reject(error);
	      }
	    }, reject);
	  });
	}

	function setupWebSocketSubscriptions() {
	  // 대기실 상태
	  stompClient.subscribe("/topic/waiting", (message) => {
	    const { count } = JSON.parse(message.body);
	    $('#turn-info').text(`다른 플레이어 대기 중... (${count}/4)`);
	  });
	  
	  // 게임 시작
	  stompClient.subscribe("/topic/start", async () => {
	    await generateNeighborTiles(centerCube);
	  });

	  // 턴 관리
	  stompClient.subscribe("/topic/turn", (message) => {
	    const { currentPlayer, players } = JSON.parse(message.body);
	    isMyTurn = currentPlayer === nickname;
	    $('#turn-info').text(isMyTurn ? '당신의 턴!' : `${currentPlayer}의 턴`);
	    $('#end-turn').prop('disabled', !isMyTurn);

	    const opponent = players.find(p => p !== nickname);
	    $('#opponent-name').text(opponent || '대기 중');
	  });

	  // 점수 업데이트
	  stompClient.subscribe("/topic/score", (message) => {
	    const { nickname: who, score } = JSON.parse(message.body);
	    if (who === nickname) {
	      $('#total-score-player').text(score);
	    } else {
	      $('#total-score-opponent').text(score);
	    }
	  });

	  // 게임 종료
	  stompClient.subscribe("/topic/gameover", (message) => {
	    const { nickname: who, message: result } = JSON.parse(message.body);
	    alert(`${who}님이 ${result}`);
	    
	    $('#turn-info').text(`게임 종료: ${who} ${result}`);
	    $('#end-turn').prop('disabled', true);
	    $('.hex-tile').off('click mouseenter mouseleave');
	  });
	}

	function setupMultiplayerUI() {
	  $('#end-turn').off('click').on('click', async () => {
	    try {
	      await sendWebSocketMessage("/app/endTurn", { nickname });
	      $('#end-turn').prop('disabled', true);
	    } catch (error) {
	      console.error("턴 종료 실패:", error);
	    }
	  });
	}

	async function sendWebSocketMessage(destination, data) {
	  return new Promise((resolve, reject) => {
	    if (!stompClient || !stompClient.connected) {
	      reject(new Error("WebSocket이 연결되지 않았습니다."));
	      return;
	    }
	    
	    try {
	      stompClient.send(destination, {}, JSON.stringify(data));
	      resolve();
	    } catch (error) {
	      reject(error);
	    }
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
  
  try {
    const fungus = await $.ajax({ url: '/fungus/random' });
    await api2(fungus, tile); // detail이 세팅될 때까지 대기
  } catch (error) {
    console.error('버섯 데이터 로딩 실패:', error);
    return;
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

	tile.on('click', async function () {
	  const detail = $(this).data('detail');
	  if (!detail || $(this).data('clicked')) return;
	  
	  if (key(cube) !== key(centerCube)) {
          await moveCenterTo(cube);}
		  
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
	  console.log("주변 타일 생성 시작...");
	  const promises = [];
	  
	  for (const dir of getCubeDirections()) {
	    const neighbor = {
	      x: center.x + dir.x,
	      y: center.y + dir.y,
	      z: center.z + dir.z
	    };
	    promises.push(createTile(neighbor));
	  
	  }}

async function createInitialTile() {
  await createTile(centerCube, { label: 'M I S' });
  const tile = tileMap.get(key(centerCube));
  tile.css({ backgroundColor: centerTileColor, color: 'white', fontSize: '1.5rem' });
  tile.one('click', async () => {
	  $('#mode-select-modal').css('display', 'flex');
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
      <div id="\${canvasId}" class="fungus-canvas"></div>
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
	  const isPoisonous = detail.purpose === '독버섯'; 
	  
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
	
        // 눈 생성
         const eyeSize = capRadius * 1.2;
        
         
      // 텍스처 생성
         const createLeftEyeTexture = (capRadius, isPoisonous) => {
        	 const canvas = document.createElement('canvas');
             const size = 256;
             canvas.width = size;
             canvas.height = size;
             const ctx = canvas.getContext('2d');
           
             ctx.clearRect(0, 0, size, size);   // 배경을 투명하게
             
             const eyeColor = isPoisonous ? '#FF0000' : '#000000';
             
             ctx.strokeStyle = eyeColor;
             ctx.lineWidth = 25;
             ctx.lineCap = 'round';
             ctx.beginPath();
             
             if (isPoisonous) {
                 // 화난 눈썹 (왼쪽 눈용 - 역슬래시 모양)
                  ctx.moveTo(size/2 , size/2 - 100);  // 중앙에서 시작 (더 화나게)
       			 ctx.lineTo(size/2 + 30, size/2 - 60);  // 오른쪽 위로
                 
             } else {
                 // 부드러운 눈썹 (왼쪽 눈용 아치 모양)
                 ctx.moveTo(size/2 - 50, size/2 - 60);
                 ctx.quadraticCurveTo(size/2 - 25, size/2 - 75, size/2, size/2 - 65);
             }
             ctx.stroke();
             
          // 왼쪽 눈 - 흰자위
             ctx.fillStyle = 'white';
             ctx.beginPath();
             ctx.arc(size/2 - 15, size/2 + 10, size/5, 0, Math.PI * 2);
             ctx.fill();
             
             // 왼쪽 눈 - 눈동자
             ctx.fillStyle = eyeColor;
             ctx.beginPath();
             ctx.arc(size/2 - 10, size/2 + 15, size/14, 0, Math.PI * 2);
             ctx.fill();
             
             return canvas;
      };
      const createRightEyeTexture = (capRadius, isPoisonous) => {
        	 const canvas = document.createElement('canvas');
             const size = 256;
             canvas.width = size;
             canvas.height = size;
             const ctx = canvas.getContext('2d');
             
             ctx.clearRect(0, 0, size, size);
             
             const eyeColor = isPoisonous ? '#FF0000' : '#000000';
             
             // 오른쪽 눈썹 (대칭)
             ctx.strokeStyle = eyeColor;
             ctx.lineWidth = 25;
             ctx.lineCap = 'round';
             ctx.beginPath();
             
             if (isPoisonous) {
                 // 화난 눈썹 (V자 모양)
            	ctx.moveTo(size/2 - 30, size/2 - 60);  // 왼쪽 위에서 시작
                 ctx.lineTo(size/2 , size/2 - 100);  // 중앙 아래로 (더 화나게)
             } else {
                 // 부드러운 눈썹 (아치 모양)
            	 ctx.moveTo(size/2 - 25, size/2 - 75);
                 ctx.quadraticCurveTo(size/2 + 10, size/2 - 85, size/2 + 45, size/2 - 70);
             }
             ctx.stroke();
             
             // 오른쪽 눈 - 흰자위
             ctx.fillStyle = 'white';
             ctx.beginPath();
             ctx.arc(size/2 + 15, size/2 + 10, size/5, 0, Math.PI * 2);
             ctx.fill();
             
             // 오른쪽 눈 - 눈동자
             ctx.fillStyle = eyeColor;
             ctx.beginPath();
             ctx.arc(size/2 + 10, size/2 + 15, size/14, 0, Math.PI * 2);
             ctx.fill();
             return canvas;
         };
         const leftEyeCanvas = createLeftEyeTexture(capRadius, isPoisonous);
         const rightEyeCanvas = createRightEyeTexture(capRadius, isPoisonous);
         const leftEyeTexture = new THREE.CanvasTexture(leftEyeCanvas);
         const rightEyeTexture = new THREE.CanvasTexture(rightEyeCanvas);
         
         leftEyeTexture.needsUpdate = true;
         rightEyeTexture.needsUpdate = true;
         const eyeGeometry = new THREE.PlaneGeometry(eyeSize, eyeSize);
         
         const leftEyeMaterial = new THREE.MeshBasicMaterial({ 
             map: leftEyeTexture,
             transparent: true,
             alphaTest: 0.5,
             side: THREE.DoubleSide
         });
         
         const rightEyeMaterial = new THREE.MeshBasicMaterial({ 
             map: rightEyeTexture,
             transparent: true,
             alphaTest: 0.5,
             side: THREE.DoubleSide
         });
         
         // 메시 생성
         const leftEye = new THREE.Mesh(eyeGeometry, leftEyeMaterial);
         const rightEye = new THREE.Mesh(eyeGeometry, rightEyeMaterial);
      
         const eyeYPosition = stemHeight * 0.9 + capYOffset * 0.3;
         const eyeZPosition = capRadius * 1.2;
         
         leftEye.position.set(-capRadius * 0.25, eyeYPosition, eyeZPosition);
         rightEye.position.set(capRadius * 0.25, eyeYPosition, eyeZPosition);
         
         scene.add(leftEye);
         scene.add(rightEye);
         
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
   
    let blinkTimer = 0;
    let isBlinking = false;
    
    const initialCapY = stemHeight + capRadius * 0.1;
    function animate() {
        requestAnimationFrame(animate);
        time += 0.01;
        blinkTimer += 0.01;
        
        // Gentle rotation and slight bobbing
        cap.rotation.y += 0.005;
        cap.position.y = initialCapY + Math.sin(time) * 0.02;
        stem.rotation.z = Math.sin(time) * 0.02;
        
        
 /*        const currentEyeY = stemHeight + capYOffset - 0.1;
        leftEye.position.y = currentEyeY;
        rightEye.position.y = currentEyeY; */
        
        // 깜빡임 애니메이션
        if (blinkTimer > 2 + Math.random() * 3) {
            isBlinking = true;
            blinkTimer = 0;
        }
        
        if (isBlinking) {
            const blinkProgress = Math.min(blinkTimer * 10, 1);
            const scaleY = blinkProgress < 0.5 ? 
                1 - (blinkProgress * 2) * 0.9 : 
                0.1 + ((blinkProgress - 0.5) * 2) * 0.9;
            
            leftEye.scale.y = scaleY;
            rightEye.scale.y = scaleY;
            
            if (blinkProgress >= 1) {
                isBlinking = false;
                leftEye.scale.y = 1;
                rightEye.scale.y = 1;
            }
        }
        
       /*  // 독버섯일 때 무서운 애니메이션
        if (isPoisonous) {
            const scary = Math.sin(time * 2) * 0.1;
            leftEye.rotation.z = scary;
            rightEye.rotation.z = -scary;
        }
         */
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