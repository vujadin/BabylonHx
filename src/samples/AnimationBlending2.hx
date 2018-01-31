package samples;

import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Space;
import com.babylonhx.math.Axis;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.animations.Animation;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AnimationBlending2 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 10, Vector3.Zero(), scene);
		camera.attachControl();

		//Adding a light
		var light = new DirectionalLight("Dir0", new Vector3(0.5, -1, 0), scene);

		//Load scene
		SceneLoader.Load("assets/models/", "main.babylon", scene.getEngine(), function (scene) {
			scene.executeWhenReady(function (scene:Scene, es:EventState = null) {
				var avatar = scene.meshes[0];
				var running = false;
				
				scene.activeCamera = camera;	
				
				camera.position.x = avatar.position.x;
				camera.position.y = avatar.position.y+2;
				camera.position.z = avatar.position.z;
				camera.position.x -= Math.sin(avatar.rotation.z-1.5708) * -5;
				camera.position.z -= Math.cos(avatar.rotation.z-1.5708) * -5;
				camera.setTarget(avatar.position);
				
				//Set up avatar
				avatar.rotate(Axis.X, -Math.PI / 2, Space.LOCAL);
				avatar.translate(Axis.Y, 0.1, Space.LOCAL);
				untyped avatar.material.emissiveColor = new Color3(0.6, 0.6, 0.6);
				avatar.position = new Vector3(0, 0, 0);
				
				//Turn up blending
				avatar.skeleton.enableBlending(0.05);
				
				//Cycle through animations
				avatar.skeleton.beginAnimation("Idle", true, 1);								
				
				Engine.mouseDown.push(function (btn:Int) {
					if (running) {
						avatar.skeleton.beginAnimation("Idle", true, 1);														
						running = false;
					} 
					else {					
						avatar.skeleton.beginAnimation("Run", true, 1);														
						running = true;
					}
				});						
				
				scene.getEngine().runRenderLoop(function () {
					scene.render();
				});
			});
		});
	}
	
}
