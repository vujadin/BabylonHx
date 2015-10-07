package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lensflare.LensFlare;
import com.babylonhx.lensflare.LensFlareSystem;
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
class LensFlares {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.attachControl(this);
		camera.alpha = 2.8;
		camera.beta = 2.25;
		
		var light0 = new PointLight("Omni0", new Vector3(21.84, 50, -28.26), scene);
		
		// Creating light sphere
		var lightSphere0 = Mesh.CreateSphere("Sphere0", 16, 0.5, scene);
		
		lightSphere0.material = new StandardMaterial("white", scene);
		cast(lightSphere0.material, StandardMaterial).diffuseColor = new Color3(0, 0, 0);
		cast(lightSphere0.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
		cast(lightSphere0.material, StandardMaterial).emissiveColor = new Color3(1, 1, 1);
		
		lightSphere0.position = light0.position;
		
		var lensFlareSystem = new LensFlareSystem("lensFlareSystem", light0, scene);
		var flare00 = new LensFlare(0.2, 0, new Color3(1, 1, 1), "assets/img/lens5.png", lensFlareSystem);
		var flare01 = new LensFlare(0.5, 0.2, new Color3(0.5, 0.5, 1), "assets/img/lens4.png", lensFlareSystem);
		var flare02 = new LensFlare(0.2, 1.0, new Color3(1, 1, 1), "assets/img/lens4.png", lensFlareSystem);
		var flare03 = new LensFlare(0.4, 0.4, new Color3(1, 0.5, 1), "assets/img/flare.png", lensFlareSystem);
		var flare04 = new LensFlare(0.1, 0.6, new Color3(1, 1, 1), "assets/img/lens5.png", lensFlareSystem);
		var flare05 = new LensFlare(0.3, 0.8, new Color3(1, 1, 1), "assets/img/lens4.png", lensFlareSystem);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
