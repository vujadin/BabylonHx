package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Environment {

	public function new(scene:Scene) {
		var light = new PointLight("Omni", new Vector3(10, 50, 50), scene);
		
		var camera = new ArcRotateCamera("Camera", 0.4, 1.2, 20, new Vector3(-10, 0, 0), scene);
		camera.attachControl(this, true);
		
		var material1 = new StandardMaterial("mat1", scene);
		material1.diffuseColor = new Color3(1, 1, 0);
		
		for (i in 0...10) {
			var box = Mesh.CreateBox("Box", 1.0, scene);
			box.material = material1;
			box.position = new Vector3(-i * 5, 0, 0);
		}
		
		// Fog
		scene.fogMode = Scene.FOGMODE_EXP;
		//Scene.FOGMODE_NONE;
		//Scene.FOGMODE_EXP;
		//Scene.FOGMODE_EXP2;
		//Scene.FOGMODE_LINEAR;
		
		scene.fogColor = new Color3(0.9, 0.9, 0.85);
		scene.fogDensity = 0.01;
		
		//Only if LINEAR
		//scene.fogStart = 20.0;
		//scene.fogEnd = 60.0;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		
		var alpha = 0.0;
		scene.registerBeforeRender(function () {
			scene.fogDensity = Math.cos(alpha) / 10;
			alpha += 0.02;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
