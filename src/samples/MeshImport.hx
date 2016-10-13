package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.lights.PointLight;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.plugins.BabylonLiteFileLoader;
import com.babylonhx.layer.Layer;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MeshImport {
	
	public function new(scene:Scene) {
		//Adding a light
		var light = new PointLight("Omni", new Vector3(-20, 10, 50), scene);
		light.intensity = 1.8;
				
		//Adding an Arc Rotate Camera
		var camera = new ArcRotateCamera("Camera", -1.54, 1.45, 1500, Vector3.Zero(), scene);
		camera.attachControl(this, false);
		
		new Layer("background", "assets/img/bkg.jpg", scene, true);
						
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		
		var towerMesh:Mesh = null;
		var platformMesh:Mesh = null;
		
		SceneLoader.ImportMesh("", "assets/models/castle/", "tower.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			towerMesh = cast newMeshes[0];
			towerMesh.position.x -= 200;
			
			SceneLoader.ImportMesh("", "assets/models/castle/", "platform.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
				platformMesh = cast newMeshes[0];
				
				var ti1 = towerMesh.createInstance("towerInst1");
				ti1.position.y += 880;
				
				var pi1 = platformMesh.createInstance("platInst1");
				pi1.position.x -= 400;
				pi1.position.y += 200;
				
				var pi2 = platformMesh.createInstance("platInst2");
				pi2.position.y += 400;
			});			
		});
		
		SceneLoader.ImportMesh("", "assets/models/wizard/", "wizard.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {			
			//newMeshes[0].position.y -= 400;
			//newMeshes[0].position.x += 200;
			//camera.target = new Vector3(-200, 400, 0);
			
			camera.target = newMeshes[0].position;			
			//newMeshes[1].position = newMeshes[0].position.clone();
						
			scene.beginAnimation(newSkeletons[0], 14, 86, true, 0.8);
			//scene.beginAnimation(newSkeletons[1], 109, 60, true, 0.8);
								
			// Move the light with the camera
			scene.registerBeforeRender(function () {
				light.position = camera.position;
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
			
			/*scene.getEngine().mouseUp.push(function() {
				trace(camera.alpha, camera.beta);
			});*/
		});
			
	}
	
}
