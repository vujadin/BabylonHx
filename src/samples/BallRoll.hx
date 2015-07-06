package samples;

import com.babylonhx.animations.Animation;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.Engine;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.plugins.OimoPlugin;
import com.babylonhx.postprocess.BlackAndWhitePostProcess;
import com.babylonhx.Scene;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.plugins.BabylonLiteFileLoader;


#if !js
import haxe.Json;
import org.msgpack.Encoder;
import org.msgpack.MsgPack;
import sys.io.FileOutput;
import sys.io.FileOutput;
import sys.io.File;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */
class BallRoll {
	
	var lastKey:Int = 0;

	public function new(scene:Scene) {
		#if !js
		//var level = Json.parse(Assets.getText("scenes/HillValley/HillValley.babylon"));
		//var f = MsgPack.encode(level);
		//var fout = File.write("scenes/HillValley/HillValley.bbin", true);
		//fout.writeBytes(f, 0, f.length - 1);
		//return;
		#end
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		/*SceneLoader.Load("assets/scenes/Train/", "Train_lite.babylon", scene.getEngine(), function(s:Scene) {
			scene = s;
			trace(scene.cameras.length);
			scene.collisionsEnabled = false;
			for (index in 0...scene.cameras.length) {
				scene.cameras[index].minZ = 10;
			}
			
			for (index in 0...scene.meshes.length) {
				var mesh = scene.meshes[index];
				
				mesh.isBlocker = mesh.checkCollisions;
			}
			
			scene.activeCamera = scene.cameras[8];
			scene.activeCamera.attachControl(this);
			cast(scene.getMaterialByName("terrain_eau"), StandardMaterial).bumpTexture = null;
			
			// Postprocesses
			var bwPostProcess = new BlackAndWhitePostProcess("Black and White", 1.0, scene.cameras[2]);
			scene.cameras[2].name = "B&W";
				
			s.getEngine().runRenderLoop(function () {
				s.render();
			});
		});*/	
		SceneLoader.Load("assets/scenes/ballroll/", "ballroll.babylon", scene.getEngine(), function(s:Scene) {
			scene = s;
			
			scene.enablePhysics(new Vector3(0, -0.3, 0), new OimoPlugin());
						
			var physOpt = new PhysicsBodyCreationOptions();
			physOpt.mass = 0;			
		
			for (mesh in scene.meshes) {
				if (StringTools.startsWith(mesh.name, "Cube")) {
					mesh.scaling.scale(20);
					mesh.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
				}
			}
			
			physOpt.mass = 1;
			physOpt.friction = 0.4;
			physOpt.restitution = 0.2;
			
			var ball:Mesh = cast scene.getMeshByName("Ball");
			ball.setPhysicsState(PhysicsEngine.SphereImpostor, physOpt);
			/*ball.rigidBody.mass = 1;
			ball.rigidBody.friction = 0.4;
			ball.rigidBody.restitution = 0.2;*/
			
			function moveBall(key:Int) {
				switch(key) {
					case 119:	// w
						if(lastKey != key) {
							lastKey = key;
							ball.rigidBody.angularVelocity.scaleEqual(0.9);
						}
						ball.applyImpulse(new Vector3(0.1, 0, 0), ball.position);
						
					case 100: 	// d
						if(lastKey != key) {						
							lastKey = key;
							ball.rigidBody.angularVelocity.scaleEqual(0.9);
						}
						ball.applyImpulse(new Vector3(0, 0, -0.1), ball.position);
						
					case 115:	// s
						if(lastKey != key) {						
							lastKey = key;
							ball.rigidBody.angularVelocity.scaleEqual(0.9);
						}
						ball.applyImpulse(new Vector3(-0.1, 0, 0), ball.position);
						
					case 97:	// a
						if(lastKey != key) {						
							lastKey = key;
							ball.rigidBody.angularVelocity.scaleEqual(0.9);
						}
						ball.applyImpulse(new Vector3(0, 0, 0.1), ball.position);
						
				}
			}
			
			Engine.keyDown.push(moveBall);
			
			//scene.removeLight(scene.lights[0]);
			//var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
			
			//scene.collisionsEnabled = false;
			
			var skybox = Mesh.CreateBox("skyBox", 3000.0, scene);
			var skyboxMaterial = new StandardMaterial("skyBox", scene);
			skyboxMaterial.backFaceCulling = false;
			skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/Sky_FantasySky_Fire_Cam", scene);
			skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
			skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
			skyboxMaterial.specularColor = new Color3(0, 0, 0);
			skybox.material = skyboxMaterial;
			skybox.infiniteDistance = true;
			
			if (s.activeCamera != null) {
				s.activeCamera = new ArcRotateCamera("cam", Math.PI, 1.1, 20, ball, scene);
				cast(s.activeCamera, ArcRotateCamera).target = ball;
				//s.activeCamera.position.y + 2000;
				scene.activeCamera.maxZ =  5000;
				s.activeCamera.attachControl(this);					
			} 
			
			/*// Shadows
			var shadowGenerator = new ShadowGenerator(1024, cast s.lights[0]);			
			shadowGenerator.useVarianceShadowMap = true;
			
			for (i in 0...10) {
				cast(s.getMeshByName("plastik_c1.00" + i), Mesh).convertToFlatShadedMesh();
				shadowGenerator.getShadowMap().renderList.push(s.getMeshByName("plastik_c1.00" + i));
			}
			
			//When pointer down event is raised
			scene.onPointerDown = function (x:Float, y:Float, button:Int, pickResult:PickingInfo) {
				// if the click hits the ground object, we change the impact position
				if (pickResult.hit) {
					//Create a rotation animation at 30 FPS
					var animationBox = new Animation("tutoAnimation", "rotation.x", 30, Animation.ANIMATIONTYPE_FLOAT,
																					Animation.ANIMATIONLOOPMODE_CONSTANT);
					// Here we have chosen a loop mode, but you can change to :
					//  Use previous values and increment it (Animation.ANIMATIONLOOPMODE_RELATIVE)
					//  Restart from initial value (Animation.ANIMATIONLOOPMODE_CYCLE)
					//  Keep the final value (Animation.ANIMATIONLOOPMODE_CONSTANT)
					
					// Animation keys
					var keys:Array<BabylonFrame> = [];
					keys.push({
						frame: 0,
						value: pickResult.pickedMesh.rotation.x
					});
										
					//At the animation key 100, the value of scaling is "1"
					keys.push({
						frame: 30,
						value: pickResult.pickedMesh.rotation.x + Math.PI
					});
					
					//Adding keys to the animation object
					animationBox.setKeys(keys);
					
					//Then add the animation object to box1
					pickResult.pickedMesh.animations.push(animationBox);
					
					//Finally, launch animations on box1, from key 0 to key 100 with loop activated
					scene.beginAnimation(pickResult.pickedMesh, 0, 30, false);
				}
			};*/
							
			s.getEngine().runRenderLoop(function () {
				s.render();
			});
		});	
		
	}
	
}
