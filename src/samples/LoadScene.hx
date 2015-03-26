package samples;

import com.babylonhx.animations.Animation;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
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
class LoadScene {

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
		SceneLoader.Load("assets/scenes/karte/", "karte.babylon", scene.getEngine(), function(s:Scene) {
			scene = s;			
			if (s.activeCamera != null) {
				s.activeCamera.attachControl(this);					
			} 
			
			// Shadows
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
					//Here we have chosen a loop mode, but you can change to :
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
			};
							
			s.getEngine().runRenderLoop(function () {
				s.render();
			});
		});	
		
	}
	
}
