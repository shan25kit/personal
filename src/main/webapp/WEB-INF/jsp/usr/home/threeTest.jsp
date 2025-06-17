<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Three.js Example</title>
</head>
<body>
</body>
<style>
body {
	margin: 0;
}

canvas {
	display: block;
}
</style>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script>
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(50, window.innerWidth/window.innerHeight, 0.1, 1000);
camera.position.set(0, 5, 15);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// 조명
const light = new THREE.DirectionalLight(0xffffff, 1);
light.position.set(5, 10, 7);
scene.add(light);
scene.add(new THREE.AmbientLight(0x404040));

// 버섯 생성 함수
function createMushroom() {
  const group = new THREE.Group();

  // 1. 자루 (Stem)
  const stemGeometry = new THREE.CylinderGeometry(
    0.5 * 0.6,   // 윗쪽
    0.5,         // 아랫쪽
    0.5,
    16
  );
  const stemMaterial = new THREE.MeshStandardMaterial('#EEC1C1');
  const stem = new THREE.Mesh(stemGeometry, stemMaterial);
  stem.position.y = 6 / 2;
  group.add(stem);

  // 2. 갓 (Cap)
  const capGeometry = new THREE.SphereGeometry(4, 32, 16, 0, Math.PI * 2, 0, Math.PI / 2);
  const capMaterial = new THREE.MeshStandardMaterial('#8B6B4F');
  const cap = new THREE.Mesh(capGeometry, capMaterial);
  cap.position.y = 6 + 2 / 2;
  cap.scale.y = 0.5; // 납작하게
  group.add(cap);

  return group;
}

const mushroom = createMushroom();
scene.add(mushroom);

/* const controls = new OrbitControls(camera, renderer.domElement); */

function animate() {
  requestAnimationFrame(animate);
  renderer.render(scene, camera);
}
animate();



</script>
</html>