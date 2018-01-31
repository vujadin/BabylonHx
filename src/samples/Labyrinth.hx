package samples;

import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import com.babylonhx.Node;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.textures.procedurals.standard.Grass;
import com.babylonhx.materials.textures.procedurals.standard.Road;
import com.babylonhx.materials.textures.procedurals.standard.Marble;
import com.babylonhx.materials.textures.procedurals.standard.Brick;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.utils.Keycodes;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Labyrinth {
	
	var keysDown:Map<Int, Bool> = new Map();
	var meshes:Array<Mesh> = [];
	

	public function new(scene:Scene) {
		var bgcolor = Color3.FromInt(0x101230);
		scene.clearColor = Color4.FromColor3(bgcolor);
		scene.ambientColor = bgcolor;
		scene.fogMode = Scene.FOGMODE_LINEAR;
		scene.fogColor = bgcolor;
		scene.fogDensity = 0.03;
		scene.fogStart = 10.0;
		scene.fogEnd = 70.0;
		scene.gravity = new Vector3(0, -0.9, 0);
		scene.collisionsEnabled = true;
		
		var gameSize = 116;
		var wallsCount = 0;
		var cellSize = 4;
			
		// camera
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 4, 30, new Vector3(gameSize, 3, gameSize), scene);
		camera.radius = 120;
		scene.activeCamera = camera;
		//camera.attachControl(canvas);
		
		// lights
		
		var torch = new PointLight("light1", Vector3.Zero(), scene);
		torch.intensity = 0.7;
		torch.diffuse = Color3.FromInt(0xff9944);
			
		var sky = new HemisphericLight("sky", new Vector3(0, 1.0, 0), scene);
		sky.intensity = 0.5;
		sky.diffuse = bgcolor;
		
		// shadow
		
		var shadowGenerator = new ShadowGenerator(1024, torch);
		shadowGenerator.setDarkness(0.2);
		//shadowGenerator.usePoissonSampling = true;
		shadowGenerator.useBlurVarianceShadowMap = true;
		shadowGenerator.blurBoxOffset = 1.0;
		shadowGenerator.blurScale = 20;
		//shadowGenerator.bias = 0.00001;
		
		// materials
		var name = "";
		var brickTexture = new Brick(name + "text", 512, scene);
		brickTexture.numberOfBricksHeight = 5;
		brickTexture.numberOfBricksWidth = 5;
		var wallMat = new StandardMaterial("wmat", scene);
		wallMat.diffuseTexture = brickTexture;
		
		var groundMat = new StandardMaterial("groundmat", scene);
		groundMat.diffuseTexture = new Road("groundtex", 512, scene);
		untyped groundMat.diffuseTexture.uScale = 10;
		untyped groundMat.diffuseTexture.vScale = 10;
		groundMat.specularPower = 5;
		
		var groundGrassMat = new StandardMaterial("grassmat", scene);
		groundGrassMat.diffuseTexture = new Grass("grasstex", 256, scene);
		untyped groundGrassMat.diffuseTexture.vScale = 10;
		groundGrassMat.specularColor = new Color3(0,0,0);
		
		var doorMat = new StandardMaterial("doormat", scene);    
		doorMat.diffuseTexture = new Marble("doortex", 256, scene);
		//doorMat.diffuseTexture.ampScale = 50.0;
		
		var player1Mat = new StandardMaterial("pmat", scene);
		player1Mat.emissiveColor = Color3.FromInt(0xff9900);
		player1Mat.specularPower = 128;
		
		var playereMat = new StandardMaterial("pemat", scene);
		playereMat.emissiveColor = Color3.FromInt(0xffffff);
		playereMat.specularPower = 128;
		
		var playerbMat = new StandardMaterial("pbmat", scene);
		playerbMat.diffuseColor = Color3.Black();
			
		//player ----
		var player:Player = new Player();
		player.mesh = Mesh.CreateSphere("playerbody", 8, 1.8, scene);
		player.mesh.material = player1Mat;
		player.mesh.position = new Vector3(0.9, 0.9, cellSize);
		
		var playere1 = Mesh.CreateSphere("eye1", 8, 0.5, scene);
		playere1.material = playereMat;
		playere1.position.y = 0.5;
		playere1.position.z = 0.5;
		playere1.position.x = -0.3;
		playere1.parent = player.mesh;
		
		var playere2 = Mesh.CreateSphere("eye2", 8, 0.5, scene);
		playere2.material = playereMat;
		playere2.position.y = 0.5;
		playere2.position.z = 0.5;
		playere2.position.x = 0.3;
		playere2.parent = player.mesh;
		
		var playereb1 = Mesh.CreateSphere("eye1b", 8, 0.25, scene);
		playereb1.material = playerbMat;
		playereb1.position.y = 0.5;
		playereb1.position.z = 0.7;
		playereb1.position.x = -0.3;
		playereb1.parent = player.mesh;
		
		var playereb2 = Mesh.CreateSphere("eye2b", 8, 0.25, scene);
		playereb2.material = playerbMat;
		playereb2.position.y = 0.5;
		playereb2.position.z = 0.7;
		playereb2.position.x = 0.3;
		playereb2.parent = player.mesh;
		
		shadowGenerator.getShadowMap().renderList.push(player.mesh);
		player.mesh.checkCollisions = true;
		//player.mesh.applyGravity = true;
		player.mesh.ellipsoid = new Vector3(0.9, 0.45, 0.9);
		player.speed = new Vector3(0, 0, 0.08);
		player.nextspeed = new Vector3(0, 0, 0);
		player.nexttorch = new Vector3(0, 0, 0);
		
		var lightImpostor = Mesh.CreateSphere("sphere1", 16, 0.1, scene);
		lightImpostor.isVisible = false;
		lightImpostor.position.y = 4.0;
		lightImpostor.position.z = 0.7;
		lightImpostor.position.x = 1.2;
		lightImpostor.parent = player.mesh;
		
		// ground
		 
		var ground = Mesh.CreatePlane("g", gameSize, scene);
		ground.position = new Vector3(gameSize / 2 - cellSize / 2, 0, gameSize / 2 - cellSize / 2);
		ground.rotation.x = Math.PI / 2;
		ground.material = groundMat;
		ground.receiveShadows = true;
		ground.checkCollisions = true;
		
		var groundGrass = Mesh.CreatePlane("g", gameSize, scene);
		groundGrass.scaling.x = 1 - (12 / 14);
		groundGrass.position = new Vector3(gameSize - (gameSize * groundGrass.scaling.x) + cellSize * 1.7, 0.025, gameSize / 2 - cellSize / 2);
		groundGrass.rotation.x = Math.PI / 2;
		groundGrass.material = groundGrassMat;
		groundGrass.receiveShadows = true;
		
		function createMaze(x:Int, y:Int):Dynamic {
			var n:Int = x * y - 1;
		 
			var horiz:Array<Map<Int, Bool>> = []; 
			for (j in 0...x + 1) {
				horiz[j] = [];
			}
			
			var verti:Array<Map<Int, Bool>> = []; 
			for (j in 0...x + 1) {
				verti[j] = [];
			}
				
			var here = [Math.floor(Math.random() * x), Math.floor(Math.random() * y)];
			var path:Array<Array<Int>> = [here];
			var unvisited:Array<Bool> = [];
			
			for (j in 0...x + 2) {
				unvisited[j] = [];
				for (k in 0...k < y + 1) {
					unvisited[j].push(j > 0 && j< x + 1 && k > 0 && (j != here[0] + 1 || k != here[1] + 1));
				}
			}
			while (0 < n) {
				var potential:Array<Array<Int>> = [[here[0] + 1, here[1]], [here[0], here[1] + 1], [here[0] - 1, here[1]], [here[0], here[1] - 1]];
				var neighbors:Array<Array<Int>> = [];
				for (j in 0...4) {
					if (unvisited[potential[j][0] + 1][potential[j][1] + 1]) {
						neighbors.push(potential[j]);
					}
				}
				if (neighbors.length > 0) {
					n = n - 1;
					var next = neighbors[Math.floor(Math.random()*neighbors.length)];
					unvisited[next[0] + 1][next[1] + 1] = false;
					if (next[0] == here[0]) {
						horiz[next[0]][(next[1] + here[1] - 1) / 2] = true;
					}
					else {
						verti[(next[0] + here[0] - 1) / 2][next[1]] = true;
					}
					path.push(here = next);
				} 
				else {
					here = path.pop();
				}
			}
			return { x: x, y: y, horiz: horiz, verti: verti };
		}
		
		function createOneWall(x, z, wallType) {
			wallsCount++;
			var scaleX = 1, scaleY = 0.8, scaleZ = 1;
			switch (wallType) {
				case 0:
					scaleY = 0.81;
					
				case 1:
					scaleX = 0.5;				
					scaleZ = 0.5;
					
				case 2:
					scaleX = 1.5;
					scaleZ = 0.5;
					
				case 3:
					scaleX = 0.5;
					scaleZ = 1.5;
					
			}
			var wallSize = cellSize;
			var wall = Mesh.CreateBox("w" + wallsCount, cellSize, scene);
			wall.scaling.x = scaleX;
			wall.scaling.y = scaleY;
			wall.scaling.z = scaleZ;
			wall.position = new Vector3(x * cellSize, cellSize * wall.scaling.y / 2, z * cellSize);
			if (wallType == 4) {
				wall.material = doorMat;
				wall.scaling.x = 0.2;
				wall.scaling.z = 1;
				wall.position.x -= cellSize / 3;
			} 
			else { 
				wall.material = wallMat;
			}
			shadowGenerator.getShadowMap().renderList.push(wall);
			wall.checkCollisions = true;
		}
		
		function createWalls(m) {
			for (j in 0...m.x * 2 + 1) {
				if (j == 0) {
					for (k in 0...m.y * 2 + 1) {
						if (k == 1) {
							createOneWall(j, k, 4);
						} 
						else if (k != 1) {
							createOneWall(j, k, 0);
						}
					}
				} 
				else if (j == m.x * 2) {
					for (k in 0...m.y * 2 + 1) {
						if (k != m.y * 2 - 1) {						
							createOneWall(j, k, 0);
						}
					}
				} 
				else if (j % 2 == 0) {
					for (k in 0...m.y * 2 + 1) {					
						if (k == 0 || k == m.y * 2) {					
							createOneWall(j, k, 0);
						} 
						else if (k % 2 == 0) {
							createOneWall(j, k, 1);
						} 
						else {
							if (!(m.verti[j / 2 - 1][Math.floor(k / 2)])) {
								createOneWall(j, k, 3);
							}
						}
					}
				} 
				else {
					for (k in 0...m.y * 2 + 1) {					
						if (k == 0 || k == m.y * 2) {					
							createOneWall(j, k, 0);
						} 
						else if (k % 2 == 0) {
							//console.log(" la ", j, k, Math.floor(j / 2), Math.floor(k / 2)-1);
							if (!(m.horiz[Math.floor(j / 2)][Math.floor(k / 2)-1])) { 
								createOneWall(j, k, 2);
							}
						}
					}
				}
			}
		}

		/*function createTextVersion(m) {
			var text= [];
			for (var j= 0; j<m.x*2+1; j++) {
				var line= [];
				if (0 == j%2)
					for (var k=0; k<m.y*4+1; k++)
						if (0 == k%4) 
							line[k]= '+';
						else
							if (j>0 && m.verti[j/2-1][Math.floor(k/4)])
								line[k]= ' ';
							else
								line[k]= '-';
				else
					for (var k=0; k<m.y*4+1; k++)
						if (0 == k%4)
							if (k>0 && m.horiz[(j-1)/2][k/4-1])
								line[k]= ' ';
							else
								line[k]= '|';
						else
							line[k]= ' ';
				if (0 == j) line[1]= line[2]= line[3]= ' ';
				if (m.x*2-1 == j) line[4*m.y]= ' ';
				text.push(line.join('')+'\r\n');
			}
			return text.join('');
		}*/
		 
		//keypress events
		Engine.keyDown.push(function(keyCode:Int) {
			if (keyCode == Keycodes.left) {
				keysDown[Keycodes.left] = true;
			}
			if (keyCode == Keycodes.right) {
				keysDown[Keycodes.right] = true;
			}
			if (keyCode == Keycodes.up) {
				keysDown[Keycodes.up] = true;
			}
			if (keyCode == Keycodes.down) {
				keysDown[Keycodes.down] = true;
			}
		});
		Engine.keyUp.push(function(keyCode:Int) {
			if (keyCode == Keycodes.left) {
				keysDown[Keycodes.left] = false;
			}
			if (keyCode == Keycodes.right) {
				keysDown[Keycodes.right] = false;
			}
			if (keyCode == Keycodes.up) {
				keysDown[Keycodes.up] = false;
			}
			if (keyCode == Keycodes.down) {
				keysDown[Keycodes.down] = false;
			}
		});
		
		var tempv = new Vector3(0, 0, 0);		 
		var theMaze = createMaze(12, 14);
		trace(theMaze);
		createWalls(theMaze);	
		
		var singleMesh = Mesh.MergeMeshes(meshes, true, true);
		shadowGenerator.getShadowMap().renderList.push(singleMesh);
		singleMesh.checkCollisions = true;
		singleMesh.receiveShadows = true;
		
		var v = 0.5;
		scene.registerBeforeRender(function () {			
			//player speed
			player.nextspeed.x = 0.0;
			player.nextspeed.z = 0.00001;
			if (keysDown[Keycodes.left]) { player.nextspeed.x = -v;}
			if (keysDown[Keycodes.right]) { player.nextspeed.x = v;}
			if (keysDown[Keycodes.up]) { player.nextspeed.z = v;}
			if (keysDown[Keycodes.down]) { player.nextspeed.z = -v; }
			player.speed = Vector3.Lerp(player.speed, player.nextspeed, 0.1);
			
			//turn to dir
			if (player.speed.length() > 0.01) {
				tempv.copyFrom(player.speed); 
				var dot = Vector3.Dot(tempv.normalize(), Axis.Z );
				var al = Math.acos(dot);
				if (tempv.x < 0.0) { 
					al = Math.PI * 2.0 - al;
				}
				var t:Float = 0;
				if (al > player.mesh.rotation.y) {
					t = Math.PI / 30;
				} 
				else {
					t = -Math.PI / 30;
				}
				var ad = Math.abs(player.mesh.rotation.y - al); 
				if (ad > Math.PI) {
					t = -t;
				}
				if (ad < Math.PI / 15) {
					t = 0;
				}
				player.mesh.rotation.y += t;
				if (player.mesh.rotation.y > Math.PI * 2) { 
					player.mesh.rotation.y -= Math.PI * 2; 
				}
				if (player.mesh.rotation.y < 0 ) { 
					player.mesh.rotation.y += Math.PI * 2; 
				}
			}
			
			player.mesh.moveWithCollisions(player.speed);
			
			if (player.mesh.position.x > 60.0) { player.mesh.position.x = 60.0; }
			if (player.mesh.position.x < -60.0) { player.mesh.position.x = -60.0; }
			if (player.mesh.position.z > 60.0) { player.mesh.position.z = 60.0; }
			if (player.mesh.position.z < -60.0) { player.mesh.position.z = -60.0; }
			
			player.nexttorch = lightImpostor.getAbsolutePosition(); 
			torch.position.copyFrom(player.nexttorch);
			torch.intensity = 0.7 + Math.random() * 0.1;
			torch.position.x += Math.random() * 0.125 - 0.0625;
			torch.position.z += Math.random() * 0.125 - 0.0625;
			camera.target = Vector3.Lerp(camera.target, player.mesh.position.add(player.speed.scale(15.0)), 0.05);
			camera.radius = camera.radius * 0.95 + (25.0 + player.speed.length() * 25.0) * 0.05;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}

class Player {
	
	public var mesh:Mesh;
	public var speed:Vector3;
	public var nextspeed:Vector3;
	public var nexttorch:Vector3;
	
	public function new() {
		
	}
	
}