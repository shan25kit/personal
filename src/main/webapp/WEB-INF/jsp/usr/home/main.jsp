<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="pageTitle" value="메인" />
<%@ include file="/WEB-INF/jsp/common/header.jsp"%>

<div class="main-container">
	<div id="center-tile" class="hex-tile center">
		<div class="logo">MIS</div>
		<%-- <div class="score">
			최고 점수: <span id="highScore">${highScore}</span>
		</div> --%>
	</div>
	<div id="hex-grid" class="hex-grid"></div>
	<div id="card-deck" class="card-deck"></div>
<!-- 	<div class="scoreboard">
		점수: <span id="Score">0</span>
	</div> -->
</div>

<script>

$(document).ready(function () {
	api1();
})

const api1 = function () {
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
                const fngsGnrlNm = $(this).find('fngsGnrlNm').text();
                const fngsPilbkNo = $(this).find('fngsPilbkNo').text();

                itemList.push({
                    fngsGnrlNm: fngsGnrlNm,
                    fngsPilbkNo: fngsPilbkNo
                });
            });

            $.ajax({
                url: '/api/postFngsData', 
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
/* const tileMap = new Map(); 

function key(cube) {
    return `${cube.x},${cube.y},${cube.z}`;
}

function cubeToPixel(cube) {
    const size = 50;
    const x = size * Math.sqrt(3) * (cube.x + cube.z / 2);
    const y = size * 1.5 * cube.z;
    return { x, y };
}
 */
 
 /*    const center = { x: 0, y: 0, z: 0 };
    const cubeDirections = [
        { x: +1, y: -1, z: 0 },
        { x: +1, y: 0,  z: -1 },
        { x: 0,  y: +1, z: -1 },
        { x: -1, y: +1, z: 0 },
        { x: -1, y: 0,  z: +1 },
        { x: 0,  y: -1, z: +1 }
    ];
    
    $.get('/fungus/random', function (data) {
        createTile(center, data);
        expandFrom(center); 
	});


function createTile(cube, tileData) {
    if (tileMap.has(key(cube))) return;

    const { x, y } = cubeToPixel(cube);
    const $tile = $('<div class="hex-tile"></div>');
    $tile.css({
        left: `${x}px`,
        top: `${y}px`,
        backgroundColor: tileData.color
    });

    $tile.text(tileData.category);
    $tile.attr('data-key', key(cube));

    $tile.on('click', () => {
        handleTileClick(tileData);
        expandFrom(cube);
    });

    $('#hex-grid').append($tile);
    tileMap.set(key(cube), tileData);
}

function expandFrom(cube) {
    for (let dir of cubeDirections) {
        const neighbor = {
            x: cube.x + dir.x,
            y: cube.y + dir.y,
            z: cube.z + dir.z
        };

        if (tileMap.has(key(neighbor))) continue;

        $.get('/tile/random', function (data) {
            createTile(neighbor, data);
        });
    }
}

// === 타일 클릭 핸들러 ===
function handleTileClick(tileData) {
    const $card = $('<div class="card"></div>');
    $card.html(`
        <h4>${tileData.category}</h4>
        <p>${tileData.detail}</p>
        <p>점수: ${tileData.score}</p>
    `);
    $('#card-deck').append($card);

    // 점수 갱신
    let score = parseInt($('#highScore').text());
    $('#highScore').text(score + tileData.score);
} */
</script>

<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>