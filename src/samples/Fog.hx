package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Fog {

	public function new(scene:Scene) {
		var camera = new FreeCamera("Camera", new Vector3(0, 0, -20), scene);
		var light = new PointLight("Omni", new Vector3(20, 100, 2), scene);
		var sphere0 = Mesh.CreateSphere("Sphere0", 16, 3, scene);
		var sphere1 = Mesh.CreateSphere("Sphere1", 16, 3, scene);
		var sphere2 = Mesh.CreateSphere("Sphere2", 16, 3, scene);
		
		var material0 = new StandardMaterial("mat0", scene);
		material0.diffuseColor = new Color3(1, 0, 0);
		sphere0.material = material0;
		sphere0.position = new Vector3( -10, 0, 0);
		
		var material1 = new StandardMaterial("mat1", scene);
		material1.diffuseColor = new Color3(1, 1, 0);
		sphere1.material = material1;
		
		var material2 = new StandardMaterial("mat2", scene);
		material2.diffuseColor = new Color3(1, 0, 1);
		sphere2.material = material2;
		sphere2.position = new Vector3(10, 0, 0);
		
		sphere1.convertToFlatShadedMesh();
		
		camera.setTarget(new Vector3(0, 0, 0));
		
		// Fog
		scene.fogMode = Scene.FOGMODE_EXP;
		scene.fogDensity = 0.1;
		
		// Animations
		var alpha = 0.0;
		scene.registerBeforeRender(function () {
			sphere0.position.z = 4 * Math.cos(alpha);
			sphere1.position.z = 4 * Math.sin(alpha);
			sphere2.position.z = 4 * Math.cos(alpha);
			
			alpha += 0.1;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
