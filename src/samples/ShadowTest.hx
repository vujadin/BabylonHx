package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.WebVRFreeCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

import com.babylonhx.helpers.EnvironmentHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShadowTest {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		// light1
		/*var light = new DirectionalLight("dir01", new Vector3(-1, -2, -1), scene);
		light.position = new Vector3(20, 40, 20);
		light.intensity = 0.5;*/
		
		var light2 = new DirectionalLight("*dir00", new Vector3(2, -4.6, -3.3), scene);//new SpotLight("light", new Vector3(2, 2, 2), new Vector3(-1, -2, -1), 3, 1, scene);
		var generator = new ShadowGenerator(1024, light2);
		generator.useExponentialShadowMap = true;
		
		//scene.forceShowBoundingBoxes = true;
		
		var box = Mesh.CreateBox("sphere1", 2, scene);
		box.material = new StandardMaterial("boxmat", scene);
		box.material.freeze();
		box.position.y = 1;
		//box.showBoundingBox = true;
		generator.getShadowMap().renderList.push(box);
		
		var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		ground.material = new StandardMaterial("groundmat", scene);
		ground.receiveShadows = true;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
		});
	}
	
}