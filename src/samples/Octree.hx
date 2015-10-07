package samples;

import com.babylonhx.cameras.ArcRotateCamera;
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
class Octree {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.attachControl(this);
		var light0 = new PointLight("Omni0", new Vector3(0, 10, 0), scene);
		var material = new StandardMaterial("kosh", scene);
		var sphere = Mesh.CreateSphere("sphere0", 16, 1, scene);

		camera.setPosition(new Vector3(-10, 10, 0));
		
		// Sphere material
		material.diffuseColor = new Color3(0.5, 0.5, 0.5);
		material.specularColor = new Color3(1.0, 1.0, 1.0);
		material.specularPower = 32;
		material.checkReadyOnEveryCall = false;
		sphere.material = material;
		
		// Fog
		scene.fogMode = Scene.FOGMODE_EXP;
		scene.fogDensity = 0.05;
		
		// Clone spheres
		var playgroundSize = 50;
		for (index in 0...8000) {
			var clone = sphere.clone("sphere" + (index + 1), null, true);
			var scale = Math.random() * 0.8 + 0.6;
			clone.scaling = new Vector3(scale, scale, scale);
			clone.position = new Vector3(Math.random() * 2 * playgroundSize - playgroundSize, Math.random() * 2 * playgroundSize - playgroundSize, Math.random() * 2 * playgroundSize - playgroundSize);
		}
		sphere.setEnabled(false);
		scene.createOrUpdateSelectionOctree();
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}