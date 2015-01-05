package samples;

import openfl.display.Sprite;

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
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		
		// The first parameter can be used to specify which mesh to import. Here we import all meshes
		SceneLoader.ImportMesh("", "models/", "skull.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			// Set the target of the camera to the first imported mesh
			camera.target = newMeshes[0];
		});
		
		// Move the light with the camera
		scene.registerBeforeRender(function () {
			light.position = camera.position;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
