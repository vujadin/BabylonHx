package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.Node;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.textures.procedurals.standard.BrickProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.RoadProceduralTexture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.utils.Keycodes;


/**
 * ...
 * @author Krtolica Vujadin
 */
class PointLightShadows {
	
	var keysDown:Map<Int, Bool> = new Map();
	
	
	public function new(scene:Scene) {
		var bgcolor = Color3.FromHexString('#101230');
		scene.clearColor = bgcolor;
		scene.ambientColor = bgcolor;
		scene.fogMode = Scene.FOGMODE_LINEAR;
		scene.fogColor = bgcolor;
		scene.fogDensity = 0.03;
		scene.fogStart = 10.0;
		scene.fogEnd = 70.0;
		scene.gravity = new Vector3(0, -0.9, 0);
		scene.collisionsEnabled = true;

		// camera
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 4, 30, new Vector3(0, 3, 0), scene);

		// lights
		var torch = new PointLight("light1", Vector3.Zero(), scene);
		torch.intensity = 0.7;
		torch.diffuse = new Color3(1, 153 / 255, 68 / 255);
			
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
		var brickTexture = new BrickProceduralTexture("text", 512, scene);
		brickTexture.numberOfBricksHeight = 5;
		brickTexture.numberOfBricksWidth = 5;
		var wallMat = new StandardMaterial("wmat", scene);
		wallMat.diffuseTexture = brickTexture;

		var customProcTextmacadam = new RoadProceduralTexture("customtext", 512, scene);
		var groundMat = new StandardMaterial("gmat", scene);
		groundMat.diffuseTexture = customProcTextmacadam;
		untyped groundMat.diffuseTexture.uScale = 10;
		untyped groundMat.diffuseTexture.vScale = 10;
		groundMat.specularPower = 5;

		var player1Mat = new StandardMaterial("pmat", scene);
		player1Mat.emissiveColor = Color3.Yellow();
		player1Mat.specularPower = 128;

		var playereMat = new StandardMaterial("pemat", scene);
		playereMat.emissiveColor = Color3.White();
		playereMat.specularPower = 128;

		var playerbMat = new StandardMaterial("pbmat", scene);
		playerbMat.diffuseColor = Color3.Black();
			
		//player ----
		var player:Player = new Player();
		player.mesh = Mesh.CreateSphere("playerbody", { segments: 8, diameterX: 1.8, diameterY: 1.8, diameterZ: 1.8 }, scene);
		player.mesh.material = player1Mat;
		player.mesh.position.y = 0.9;
	
		var playere1 = Mesh.CreateSphere("eye1", { segments: 8, diameterX: 0.5, diameterY: 0.5, diameterZ: 0.5 }, scene);
		playere1.material = playereMat;
		playere1.position.y = 0.5;
		playere1.position.z = 0.5;
		playere1.position.x = -0.3;
		playere1.parent = player.mesh;
	
		var playere2 = Mesh.CreateSphere("eye2", { segments: 8, diameterX: 0.5, diameterY: 0.5, diameterZ: 0.5 }, scene);
		playere2.material = playereMat;
		playere2.position.y = 0.5;
		playere2.position.z = 0.5;
		playere2.position.x = 0.3;
		playere2.parent = player.mesh;
	
		var playereb1 = Mesh.CreateSphere("eye1b", { segments: 8, diameterX: 0.25, diameterY: 0.25, diameterZ: 0.25 }, scene);
		playereb1.material = playerbMat;
		playereb1.position.y = 0.5;
		playereb1.position.z = 0.7;
		playereb1.position.x = -0.3;
		playereb1.parent = player.mesh;
	
		var playereb2 = Mesh.CreateSphere("eye2b", { segments: 8, diameterX: 0.25, diameterY: 0.25, diameterZ: 0.25 }, scene);
		playereb2.material = playerbMat;
		playereb2.position.y = 0.5;
		playereb2.position.z = 0.7;
		playereb2.position.x = 0.3;
		playereb2.parent = player.mesh;
	
		shadowGenerator.getShadowMap().renderList.push(player.mesh);
		player.mesh.checkCollisions = true;
		player.mesh.ellipsoid = new Vector3(0.9, 0.45, 0.9);
		player.speed = new Vector3(0, 0, 0.08);
		player.nextspeed = Vector3.Zero();
		player.nexttorch = Vector3.Zero();

		var lightImpostor = Mesh.CreateSphere("sphere1", { segments: 16, diameterX: 0.1, diameterY: 0.1, diameterZ: 0.1 }, scene);
		var lightImpostorMat = new StandardMaterial("mat", scene);
		lightImpostor.material = lightImpostorMat;
		lightImpostorMat.emissiveColor = Color3.Yellow();
		lightImpostorMat.linkEmissiveWithDiffuse = true;
		lightImpostor.position.y = 4.0;
		lightImpostor.position.z = 0.7;
		lightImpostor.position.x = 1.2;
		lightImpostor.parent = player.mesh;

		// ground
		 
		var ground = Mesh.CreatePlane("g", { width: 120, height: 120 }, scene);
		ground.position = new Vector3(0, 0, 0);
		ground.rotation.x = Math.PI / 2;
		ground.material = groundMat;
		ground.receiveShadows = true;
		ground.checkCollisions = true;

		for (i in 0...100) {
			var px = Math.random() * 100 - 50;
			var pz = Math.random() * 100 - 50;
			if ((px > 4 || px < -4) && (pz > 4 || pz < -4)) {
				var wall = Mesh.CreateBox("w" + i, { width: 3, height: 3, depth: 3 }, scene);
				wall.position = new Vector3(px, 1.5, pz);
				if (Math.random() > 0.5) {
					wall.scaling.x = 3;
				} 
				else {
					wall.scaling.z = 3;
				}
				wall.material = wallMat;
				shadowGenerator.getShadowMap().renderList.push(wall);
				wall.receiveShadows = true;
				wall.checkCollisions = true;
			}
		}

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
		
		var tempv = Vector3.Zero();
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
				/*if (window.keyisdown[9]) {
					console.log("dot,al:",dot,al);			
				}*/
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
