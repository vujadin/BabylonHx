package samples;

import lime.Assets;
import lime.media.AudioSource;

import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;
import box2D.common.math.B2Vec2;

import motion.Actuate;
import motion.easing.Elastic;

import com.babylonhx.Scene;
import com.babylonhx.Node;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.tools.Tools;
import com.babylonhx.utils.Image;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Space;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.loading.SceneLoader;

/*import org.ascrypt.AES;
import org.ascrypt.Base16;
import org.ascrypt.padding.PKCS7;
import org.ascrypt.common.OperationMode;
import org.ascrypt.encoding.UTF8;*/


/**
 * ...
 * @author Krtolica Vujadin
 */

class MemoryGame {
	
	var radToDeg:Float = 57.2957795;
	var boxWidth:Int = 76;
	var world:B2World = new B2World(new B2Vec2(0, 10), true);
	var worldScale:Int = 30;
	var pickedboxes:Int = 0;
	var boxes:Array<Int> = [2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21];
	var pickedBodies:Array<B2Body> = [];
	//var idle:Timer;
	var totalClicks:Int = 0;
	var boxesRemoved:Int = 0;
	
	var ambience:AudioSource;
	var sound:AudioSource;

	var boxMeshes:Map<String, InstancedMesh> = new Map();
	var boxMesh:Mesh;
	
	var insideBoxMeshTemplates:Map<Int, Mesh> = new Map();
	
	var insideBoxMeshes:Map<String, InstancedMesh> = new Map();
	
	// crucarp
	// powerups vol 1 free
	// hand painted forest lite
	
	var fishMesh:Mesh;
	var frogMesh:Mesh;
	var chickenMesh:Mesh;
	var heartMesh:Mesh;
	var keyMesh:Mesh;
	var starMesh:Mesh;
	var padlockMesh:Mesh;
	var barrelMesh:Mesh;
	var axeMesh:Mesh;
	var trapMesh:Mesh;
	var mushroomMesh:Mesh;
	var mugMesh:Mesh;
	var bookMesh:Mesh;
	var shieldMesh:Mesh;
	var swordMesh:Mesh;
	var swordMesh2:Mesh;
	var quiverMesh:Mesh;
	var bowMesh:Mesh;
	var bombMesh:Mesh;
	var diamondMesh:Mesh;
	var magnetMesh:Mesh;
	
	var frozenBoxMat:StandardMaterial;
	var unfrozenBoxMats:Array<StandardMaterial> = [];
	
	var mesh1:Mesh;
	var mesh2:Mesh;
	
	var width:Int = 450;
	var height:Int = 800;
	var dimDiff:Float;
	
	var scene:Scene;
	var camera:FreeCamera;
	
	var canPick:Bool = true;	// if box picking is enabled (protecting us from assigning wrong material to some boxes - BUG)
	
	
	public function new(scene:Scene) {				
		// alpha: 7.87227410800976, beta: 1.40459010795579, x: 363.376281410498, y: -17.1086235957562, z: 1338.7543956973
		/*camera = new ArcRotateCamera("Camera", 7.8422, 1.4872, 50, new Vector3(-223, -327, 1437), scene);
		camera.attachControl();*/
		
		camera = new FreeCamera("camera1", new Vector3(-150, -335, 959), scene);
		camera.rotation.set(0.051, -3.348, 0);
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(1, 1, 0), scene);
		
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		skybox.isPickable = false;
		
		/*ambience = new AudioSource(Assets.getAudioBuffer("assets/audio/honey-bear-loop.ogg"));
		ambience.loops = 99999;
		ambience.play();*/
		
		SceneLoader.ImportMesh("", "assets/memory/", "fish.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			fishMesh = cast newMeshes[0];
			fishMesh.isVisible = false;
			fishMesh.material.freeze();
			fishMesh.setEnabled(false);
			insideBoxMeshTemplates[2] = (fishMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "frog.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			frogMesh = cast newMeshes[0];
			frogMesh.isVisible = false;
			frogMesh.material.freeze();
			frogMesh.setEnabled(false);
			insideBoxMeshTemplates[3] = (frogMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "chicken.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			chickenMesh = cast newMeshes[0];
			chickenMesh.isVisible = false;
			chickenMesh.material.freeze();
			chickenMesh.setEnabled(false);
			insideBoxMeshTemplates[4] = (chickenMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "heart.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			heartMesh = cast newMeshes[0];
			heartMesh.isVisible = false;
			heartMesh.material.freeze();
			heartMesh.setEnabled(false);
			insideBoxMeshTemplates[5] = (heartMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "key.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			keyMesh = cast newMeshes[0];
			keyMesh.isVisible = false;
			keyMesh.material.freeze();
			keyMesh.setEnabled(false);
			insideBoxMeshTemplates[6] = (keyMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "star.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			starMesh = cast newMeshes[0];
			starMesh.isVisible = false;
			starMesh.material.freeze();
			starMesh.setEnabled(false);
			insideBoxMeshTemplates[7] = (starMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "padlock.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			padlockMesh = cast newMeshes[0];
			padlockMesh.isVisible = false;
			padlockMesh.material.freeze();
			padlockMesh.setEnabled(false);
			insideBoxMeshTemplates[8] = (padlockMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "barrel.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			barrelMesh = cast newMeshes[0];
			barrelMesh.isVisible = false;
			barrelMesh.material.freeze();
			barrelMesh.setEnabled(false);
			insideBoxMeshTemplates[9] = (barrelMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "axe.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			axeMesh = cast newMeshes[0];
			axeMesh.isVisible = false;
			axeMesh.material.freeze();
			axeMesh.setEnabled(false);
			insideBoxMeshTemplates[10] = (axeMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "trap.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			trapMesh = Mesh.MergeMeshes(cast newMeshes, true);			
			trapMesh.isVisible = false;
			trapMesh.material.freeze();
			trapMesh.setEnabled(false);
			insideBoxMeshTemplates[11] = (trapMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "mushroom.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			mushroomMesh = Mesh.MergeMeshes(cast newMeshes, true);			
			mushroomMesh.isVisible = false;
			mushroomMesh.material.freeze();
			mushroomMesh.setEnabled(false);
			insideBoxMeshTemplates[12] = ( mushroomMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "mug.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			mugMesh = cast newMeshes[0];
			for (i in 1...newMeshes.length) {
				newMeshes[1].parent = mugMesh;
			}
			mugMesh.isVisible = false;
			mugMesh.material.freeze();
			mugMesh.setEnabled(false);
			insideBoxMeshTemplates[13] = (mugMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "book.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			bookMesh = cast newMeshes[0];
			bookMesh.isVisible = false;
			bookMesh.material.freeze();
			bookMesh.setEnabled(false);
			insideBoxMeshTemplates[14] = (bookMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "shield.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			shieldMesh = cast newMeshes[0];
			shieldMesh.isVisible = false;
			shieldMesh.material.freeze();
			shieldMesh.setEnabled(false);
			insideBoxMeshTemplates[15] = (shieldMesh);
		});
		
		//SceneLoader.ImportMesh("", "assets/memory/", "sword.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			//swordMesh = cast newMeshes[0];
			//swordMesh.isVisible = false;
			//swordMesh.material.freeze();
			//insideBoxMeshTemplates.set(16, swordMesh);
		//});
		
		SceneLoader.ImportMesh("", "assets/memory/", "sword2.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			swordMesh2 = cast newMeshes[0];
			swordMesh2.isVisible = false;
			swordMesh2.material.freeze();
			swordMesh2.setEnabled(false);
			insideBoxMeshTemplates[16] = (swordMesh2);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "quiver.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			quiverMesh = cast newMeshes[0];
			quiverMesh.isVisible = false;
			quiverMesh.setEnabled(false);
			quiverMesh.material.freeze();
			insideBoxMeshTemplates[17] = (quiverMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "bow.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			bowMesh = cast newMeshes[0];
			bowMesh.isVisible = false;
			bowMesh.setEnabled(false);
			bowMesh.material.freeze();
			insideBoxMeshTemplates[18] = (bowMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "bomb.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			bombMesh = cast newMeshes[0];
			bombMesh.isVisible = false;
			bombMesh.material.freeze();
			bombMesh.setEnabled(false);
			insideBoxMeshTemplates[19] = (bombMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "diamond.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			diamondMesh = cast newMeshes[0];
			//diamondMesh.convertToFlatShadedMesh();
			diamondMesh.isVisible = false;
			diamondMesh.material.freeze();
			diamondMesh.setEnabled(false);
			insideBoxMeshTemplates[20] = (diamondMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "magnet.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			magnetMesh = cast newMeshes[0];
			magnetMesh.isVisible = false;
			magnetMesh.material.freeze();
			magnetMesh.setEnabled(false);
			insideBoxMeshTemplates[21] = (magnetMesh);
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "pinetree.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			var pineTreeMesh:Mesh = cast newMeshes[0];
			pineTreeMesh.material.backFaceCulling = false;
			pineTreeMesh.material.freeze();
			pineTreeMesh.position.y += 200;
			pineTreeMesh.isPickable = false;
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "gate.babylon", scene, function (newMeshes, _, _) {
			newMeshes[0].isPickable = false;
			//var pineTreeMesh = cast newMeshes[0];
			//pineTreeMesh.material.freeze();
			//pineTreeMesh.position.y += 200;
		});
		
		SceneLoader.ImportMesh("", "assets/memory/", "box.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			boxMesh = cast newMeshes[0];
			boxMesh.isVisible = false;
			
			frozenBoxMat = cast boxMesh.material;
			unfrozenBoxMats.push(frozenBoxMat.clone("unfrozenBoxMat1"));
			unfrozenBoxMats.push(frozenBoxMat.clone("unfrozenBoxMat2"));
			frozenBoxMat.freeze();
			
			mesh1 = boxMesh.clone("mesh1");
			mesh2 = boxMesh.clone("mesh2");
			
			mesh1.material = unfrozenBoxMats[0];
			mesh2.material = unfrozenBoxMats[1];
			
			mesh1.scaling.set(25.4, 25.4, 25.4);
			mesh2.scaling.set(25.4, 25.4, 25.4);
			
			mesh1.isVisible = (false);
			mesh2.isVisible = (false);
			
			startScreen();	
			
			scene.onPointerDown = function(_, pinfo) {
				if (pinfo.hit) {
					destoryBox2(untyped pinfo.pickedMesh.extraData);
				}
			};
		});
		
		scene.getEngine().runRenderLoop(function () {
			update();
			scene.render();
		});
		
		/*scene.stage2D.addEventListener(MouseEvent.CLICK, function(_) {
			trace('position - x: ${camera.position.x}, y: ${camera.position.y}, z: ${camera.position.z}');
			trace('rotation - x: ${camera.rotation.x}, y: ${camera.rotation.y}, z: ${camera.rotation.z}');
		});*/
	}
	
	function startScreen() {		
		wall(0, -20, 1000, 0);
		wall(0, 722, 1000, 0); 
		wall(0, 240, 0, 1000);
		wall(450, 240, 0, 1000);
		
		Tools.delay(gameGenerate, 100);
	}
	
	private function gameGenerate() {
		totalClicks = 0;
		boxesRemoved = 0;
		pickedBodies = [];
		pickedboxes = 0;
		
		var i = 1;
		while (i <= boxes.length * 4) {
			var from = Math.floor(Math.random() * boxes.length);
			var to = Math.floor(Math.random() * boxes.length);
			var temp = boxes[from];
			boxes[from] = boxes[to];
			boxes[to] = temp;
			i++;
		}	
		/*boxes = Random.shuffle(boxes);
		boxes = Random.shuffle(boxes);
		boxes = Random.shuffle(boxes);*/
		
		var cnt:Int = 0;
		for (i in 0...5) {
			for (j in 0...8) {
				crate(72 + boxWidth * i, 50 + boxWidth * j, boxWidth, boxWidth, j * 5 + i, cnt++);
			}
		}
	}
	
	private function wall(pX:Float ,pY:Float, w:Float, h:Float) {
		var bodyDef:B2BodyDef = new B2BodyDef();
		bodyDef.position.set(pX / worldScale, pY / worldScale);
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsBox(w / 2 / worldScale, h / 2 / worldScale);
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = polygonShape;
		fixtureDef.density = 2;
		fixtureDef.restitution = 0.4;
		fixtureDef.friction = 0.5;
		var theWall:B2Body = world.createBody(bodyDef);
		theWall.createFixture(fixtureDef);
	}
	
	private function crate(pX:Float, pY:Float, w:Float, h:Float, val:Int, cnt:Int) {
		var bodyDef:B2BodyDef = new B2BodyDef();
		bodyDef.position.set(pX / worldScale, pY / worldScale);
		bodyDef.type = B2Body.b2_dynamicBody;
		bodyDef.userData = { };
		bodyDef.userData.name = "box_" + cnt;
		
		var box = boxMesh.createInstance("box_" + cnt);
		box.name = "box_" + cnt;
		box.isVisible = true;
		box.isPickable = true;
		box.scaling.set(25.4, 25.4, 25.4);
		boxMeshes.set("box_" + cnt, box);
		
		insideBoxMeshes.set("box_" + cnt, insideBoxMeshTemplates[boxes[val]].createInstance("inst_" + cnt));
		insideBoxMeshes["box_" + cnt].isPickable = false;
		//insideBoxMeshes["box_" + cnt].isVisible = (false);
		
		bodyDef.userData.picked = false;
		bodyDef.userData.boxValue = val;
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsBox(w / 2 / worldScale, h / 2 / worldScale);
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = polygonShape;
		fixtureDef.density = 2;
		fixtureDef.restitution = 0.4;
		fixtureDef.friction = 0.5;
		var crateBody:B2Body = world.createBody(bodyDef);
		crateBody.createFixture(fixtureDef);
		
		box.extraData = crateBody;
	}
	
	private function destoryBox2(body:B2Body) {
		if (canPick) {
			if (pickedboxes < 2) {
				queryCallback2(body);
				totalClicks++;
			}
			
			if (pickedboxes == 2 && boxes[pickedBodies[0].getUserData().boxValue] != boxes[pickedBodies[1].getUserData().boxValue]) {	
				var force = new B2Vec2(0, -15);
				pickedBodies[0].applyImpulse(force, pickedBodies[0].getWorldCenter());
				pickedBodies[0].setAwake(true);
				pickedBodies[0].setLinearVelocity(force);
				pickedBodies[1].applyImpulse(force, pickedBodies[1].getWorldCenter());
				pickedBodies[1].setAwake(true);
				pickedBodies[1].setLinearVelocity(force);	
			}
		}
	}
	
	var boxSelected:Int = 0;	
	private function queryCallback2(touchedBody:B2Body):Bool {
		if (canPick) {
			if (touchedBody.getUserData() != null && !touchedBody.getUserData().picked) {
				pickedBodies.push(touchedBody);
				pickedboxes++;
				touchedBody.getUserData().picked = true;
				
				var _name = touchedBody.getUserData().name;
				
				insideBoxMeshes[_name].isVisible = (true);
				
				var bs = boxSelected++ % 2;
				if (bs == 0) {
					mesh1.extraData = boxMeshes.get(_name);					
					mesh1.extraData.isVisible = false;
					mesh1.isVisible = (true);
					mesh1.position.copyFrom(mesh1.extraData.position);
					insideBoxMeshes[_name].position.copyFrom(mesh1.position);
					var mat = mesh1.material;
					Actuate.tween(mat, 0.9, { alpha: 0.05 });
				}
				else {
					mesh2.extraData = boxMeshes.get(_name);
					mesh2.extraData.isVisible = false;
					mesh2.isVisible = (true);
					mesh2.position.copyFrom(mesh2.extraData.position);
					insideBoxMeshes[_name].position.copyFrom(mesh2.position);
					var mat = mesh2.material;
					Actuate.tween(mat, 0.9, { alpha: 0.05 });
				}
			}
			
			if (pickedboxes == 2) {
				canPick = false;
				Tools.delay(process, 800);
			}
		}
		
		return false;
	}
	
	private function process() {
		var name1 = pickedBodies[0].getUserData().name;
		var name2 = pickedBodies[1].getUserData().name;
		
		if (boxes[pickedBodies[0].getUserData().boxValue] == boxes[pickedBodies[1].getUserData().boxValue]) {
			world.destroyBody(pickedBodies[0]);
			world.destroyBody(pickedBodies[1]);
			boxesRemoved++;
			
			mesh1.isVisible = (false);
			mesh2.isVisible = (false);
			
			insideBoxMeshes.get(name1).dispose();
			insideBoxMeshes.get(name2).dispose();
			boxMeshes.get(name1).dispose();
			boxMeshes.get(name2).dispose();
			
			insideBoxMeshes.remove(name1);
			insideBoxMeshes.remove(name2);
			boxMeshes.remove(name1);
			boxMeshes.remove(name2);
			
			canPick = true;
			
			if (boxesRemoved == 20) {
				//scoreBoard();
			}			
		}
		else {			
			Actuate.tween(mesh1.material, 0.2, { alpha: 1 }).onComplete(function() { 
				mesh1.isVisible = (false);
				mesh1.extraData.isVisible = true;
				canPick = true; 
				insideBoxMeshes.get(name1).isVisible = (false);
			});
			
			Actuate.tween(mesh2.material, 0.2, { alpha: 1 }).onComplete(function() { 
				mesh2.isVisible = (false);
				mesh2.extraData.isVisible = true;
				canPick = true; 
				insideBoxMeshes.get(name2).isVisible = (false);
			});
			
			pickedBodies[0].getUserData().picked = false;
			pickedBodies[1].getUserData().picked = false;
		}
		
		pickedBodies = [];		
		pickedboxes = 0;
	}
	
	private function update() {
		world.step(1 / 30, 10, 10);
		var b = world.getBodyList();
		while(b != null) {
			if (b.getUserData() != null) {				
				var boxMesh = boxMeshes.get(b.getUserData().name);
				boxMesh.position.x = -(b.getPosition().x * worldScale);
				boxMesh.position.y = -(b.getPosition().y * worldScale);
				boxMesh.rotation.z = b.getAngle();
				
				var innerMesh = insideBoxMeshes.get(boxMesh.name);	
				if (innerMesh != null) {
					innerMesh.position.copyFrom(boxMesh.position);
					innerMesh.rotation.y += 0.1;
				}
				
				if (mesh1.extraData != null) {
					mesh1.position.copyFrom(cast(mesh1.extraData, InstancedMesh).position);
					mesh1.rotation.copyFrom(cast(mesh1.extraData, InstancedMesh).rotation);
				}
				
				if (mesh2.extraData != null) {
					mesh2.position.copyFrom(cast(mesh2.extraData, InstancedMesh).position);
					mesh2.rotation.copyFrom(cast(mesh2.extraData, InstancedMesh).rotation);
				}
			}
			
			b = b.getNext();
		}
		//world.drawDebugData();
	}
	
}
