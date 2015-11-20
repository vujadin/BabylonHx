package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BumpMap {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 25, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light = new PointLight("Omni", new Vector3( -60, 60, 80), scene);
		
		//new Layer("background", "assets/img/graygrad.jpg", scene, true);
		
		var material = new StandardMaterial("kosh", scene);
		material.diffuseTexture = new Texture("assets/img/DiffuseMap.jpg", scene);
		material.bumpTexture = new Texture("assets/img/NormalMap.jpg", scene);
		
		var box = Mesh.CreateBox("box", 4.0, scene);
		box.material = material;
		
		camera.setPosition(new Vector3(0, 10, 5));
		
		// Animations
		scene.registerBeforeRender(function() {
			light.position = camera.position;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
