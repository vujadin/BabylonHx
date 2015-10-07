package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.lights.PointLight;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.plugins.BabylonLiteFileLoader;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MeshImport {

	public function new(scene:Scene) {
		//Adding a light
		var light = new PointLight("Omni", new Vector3(20, 20, 100), scene);
				
		//Adding an Arc Rotate Camera
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 100, Vector3.Zero(), scene);
		camera.attachControl(this, false);
		
		var lines = Mesh.CreateLines("lines", [
			new Vector3(-.1, 0, camera.position.z + 20),
			new Vector3(.1, 0, camera.position.z + 20)
		], scene);		
		lines.alpha = 0.01;
		lines.parent = camera;
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);		
		SceneLoader.ImportMesh("", "assets/models/", "skull.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			newMeshes[0].position.x -= 20;
		});
		
		/*SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);		
		SceneLoader.ImportMesh("", "assets/models/", "skull.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			newMeshes[0].position.x += 20;
			camera.target = newMeshes[0];
			camera.target.position.x -= 20;
		});*/
		
		// Move the light with the camera
		scene.registerBeforeRender(function () {
			light.position = camera.position;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
