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
		<h1 style="color: white">Mushroom Card</h1>
		<div id="score-area-player">
			<span>Score: <strong id="total-score-player">0</strong></span>
		</div>
	</div>
	<div id="card-deck-opponent" class="card-deck">
		<div id="score-area-opponent">
			<span>Score: <strong id="total-score-opponent">0</strong></span>
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
  '낙엽': '#f5debf',
  '활엽수': '#dcf5ec',
  '곤충': '#d3d3de',
  '기타': '#f5f5f5'
};

let stompClient = null;
let nickname = null;
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
		        <img src="https://e1.pngegg.com/pngimages/317/581/png-clipart-super-mario-icons-1up-mushroom-thumbnail.png"
		          style="width:20px; height:auto; margin-left:5px;">
		        <span>\${detail.name} (\${detail.score})</span>
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
        const current = JSON.parse(message.body).currentPlayer;
        $('#turn-info').text(current === nickname ? "당신의 턴!" : current + "의 턴");
        $('#end-turn').prop('disabled', current !== nickname);
      });
      stompClient.subscribe("/topic/score", (message) => {
      	  const { nickname: player, score } = JSON.parse(message.body);
      	  if (player !== nickname) {
      	    $('#total-score-opponent').text(score);
      	  }
      	});
    });
    $('#end-turn').on('click', () => {
      stompClient.send("/app/endTurn", {}, JSON.stringify({ nickname }));
      $('#end-turn').prop('disabled', true);
    });
    
    $('.deck-area').fadeIn();
    $('.message-area').fadeIn();
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
  const html = `
    <div class="card" style="background-color: \${bgColor}; color: black;">
      <h3> \${detail.name}</h3>
      <p><strong>과:</strong> \${detail.familyKor}</p>
      <p><strong> \${detail.family}</strong></p>
      <p><strong>속:</strong> \${detail.genusKor}</p>
      <p><strong> \${detail.genus}</strong></p>
   
      <p><strong>발생:</strong> \${detail.environment}</p>
      <p><strong>생태:</strong> \${detail.ecology}</p>
      <p><strong>계절:</strong> \${detail.season}</p>
      <p><strong> \${detail.purpose}</strong></p>
      <p><strong>점수:</strong> \${detail.score}점</p>
    </div>
  `;
  $('#card-deck-player').append(html);
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
  if (envText.includes("낙엽")) return "낙엽";
  if (envText.includes("활엽수")) return "활엽수";
  if (envText.includes("곤충")) return "곤충";
  return "기타";
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
	
	
	
</script>

<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>