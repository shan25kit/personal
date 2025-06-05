<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Insert title here</title>
<style>
body {
	background: #f0f0f0;
	font-family: sans-serif;
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 20px;
}

.hex-grid {
	display: grid;
	grid-template-columns: repeat(3, 120px);
	grid-auto-rows: 100px; 
	gap: 1px;
	transform: rotate(30deg);
	position: relative;
	border: 3px solid red;
}

.hex-tile {
	width: 100px;
	height: 100px;
	background: #ddd;
	clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
	display: flex;
	align-items: center;
	justify-content: center;
	font-weight: bold;
	transform: rotate(-30deg);
	color: #333;
	cursor: pointer;
	transition: background 0.2s;
}

/* .hex-tile:nth-child(odd) {
	transform: translateY(43.3px);
} */

.player1 {
	background-color: #3498db;
	color: white;
}

.player2 {
	background-color: #e74c3c;
	color: white;
}

h2 {
	margin-bottom: 10px;
}
</style>
</head>
<body>
	<!-- <p>
		현재 차례: <span id="turn">Player 1</span>
	</p> -->
	<div class="hex-grid" id="grid"></div>

	<script>
    const grid = document.getElementById('grid');
 /*    const turnDisplay = document.getElementById('turn');
    let currentPlayer = 1;
 */
    // 5x5 격자 생성
    for (let i = 0; i < 7; i++) {
      const hex = document.createElement('div');
      hex.classList.add('hex-tile');
     /*  hex.dataset.owner = '0';
      hex.addEventListener('click', () => {
        if (hex.dataset.owner === '0') {
          hex.classList.add(currentPlayer === 1 ? 'player1' : 'player2');
          hex.dataset.owner = currentPlayer;
          currentPlayer = currentPlayer === 1 ? 2 : 1;
          turnDisplay.textContent = `Player ${currentPlayer}`;
        }
      }); */
      grid.appendChild(hex);
    }
  </script>
</body>
</html>