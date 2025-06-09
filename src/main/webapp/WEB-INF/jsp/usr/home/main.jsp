<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="pageTitle" value="메인" />
<%@ include file="/WEB-INF/jsp/common/header.jsp"%>

<div id="grid" data-q="0" data-r="0"></div>

<script>
	
const tileSize = 100;
const tileWidth = tileSize + 10;
const tileHeight = tileSize * 0.866;

const directions = [
  { q: 0, r: -1 },
  { q: 1, r: -1 },
  { q: 1, r: 0 },
  { q: 0, r: 1 },
  { q: -1, r: 1 },
  { q: -1, r: 0 }
];

const created = new Set();

function axialToPixel(q, r) {
  const x = tileWidth * (q + r / 2);
  const y = tileHeight * r;
  return { x, y };
}

function key(q, r) {
  return `${q},${r}`;
}

function createTile(q, r, isCenter = false) {
  const k = key(q, r);
  if (created.has(k)) return;

  const { x, y } = axialToPixel(q, r);
  const offsetX = window.innerWidth / 2 - 10;
  const offsetY = window.innerHeight / 2;

  const $tile = $('<div class="hex-tile"></div>');
  $tile.css({
    left: `${x + offsetX}px`,
    top: `${y + offsetY}px`
  });
  $tile.text(isCenter ? `중앙\n(${q},${r})` : `(${q},${r})`);
  if (isCenter) $tile.addClass('center');

  $tile.on('click', () => {
    generateTiles(q, r);
  });

  $('#grid').append($tile);
  created.add(k);
}

function generateTiles(q, r) {
  createTile(q, r, true); // 중심 타일 생성
  directions.forEach(dir => {
    createTile(q + dir.q, r + dir.r);
  });
}

$(document).ready(() => {
  // 페이지 로드시 바로 중심과 주변 타일 생성
  generateTiles(0, 0);
});
  </script>
<%@ include file="/WEB-INF/jsp/common/footer.jsp"%>