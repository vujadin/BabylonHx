package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author ...
 */
class BumpMap {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		var light = new PointLight("Omni", new Vector3(20, 100, 2), scene);
		var sphere = Mesh.CreateSphere("Sphere", 16, 3, scene);
		var material = new StandardMaterial("kosh", scene);
		material.bumpTexture = new Texture("assets/img/normalMap.jpg", scene);
		material.bumpTexture.level = 1.0;
		material.diffuseColor = new Color3(1, 0, 0);
		
		sphere.material = material;
		
		camera.setPosition(new Vector3(-5, 5, 0));
		
		// Animations
		scene.registerBeforeRender(function() {
			sphere.rotation.y += 0.02;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
