package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lensflare.LensFlare;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.FresnelParameters;
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

class Fresnel {
	
	public function new(scene:Scene) {
		
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 5, Vector3.Zero(), scene);
		camera.attachControl(this, false);
		
		var material = new StandardMaterial("kosh", scene);
		var sphere1 = Mesh.CreateSphere("Sphere1", 32, 3, scene);
		var sphere2 = Mesh.CreateSphere("Sphere2", 32, 3, scene);
		var sphere3 = Mesh.CreateSphere("Sphere3", 32, 3, scene);
		var sphere4 = Mesh.CreateSphere("Sphere4", 32, 3, scene);
		var sphere5 = Mesh.CreateSphere("Sphere5", 32, 3, scene);
		var light = new PointLight("Omni0", new Vector3( -17.6, 18.8, -49.9), scene);
		
		camera.setPosition(new Vector3(-15, 3, 0));
		
		sphere2.position.z -= 5;
		sphere3.position.z += 5;
		sphere4.position.x += 5;
		sphere5.position.x -= 5;
		
		// Sphere1 material
		material.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		material.diffuseColor = new Color3(0, 0, 0);
		material.emissiveColor = new Color3(0.5, 0.5, 0.5);
		material.alpha = 0.2;
		material.specularPower = 16;
		
		// Fresnel
		material.reflectionFresnelParameters = new FresnelParameters();
		material.reflectionFresnelParameters.bias = 0.1;
		
		material.emissiveFresnelParameters = new FresnelParameters();
		material.emissiveFresnelParameters.bias = 0.6;
		material.emissiveFresnelParameters.power = 4;
		material.emissiveFresnelParameters.leftColor = Color3.White();
		material.emissiveFresnelParameters.rightColor = Color3.Black();
		
		material.opacityFresnelParameters = new FresnelParameters();
		material.opacityFresnelParameters.leftColor = Color3.White();
		material.opacityFresnelParameters.rightColor = Color3.Black();
		
		sphere1.material = material;
		
		// Sphere2 material
		material = new StandardMaterial("kosh2", scene);
		material.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		material.diffuseColor = new Color3(0, 0, 0);
		material.emissiveColor = new Color3(0.5, 0.5, 0.5);
		material.specularPower = 32;
		
		// Fresnel
		material.reflectionFresnelParameters = new FresnelParameters();
		material.reflectionFresnelParameters.bias = 0.1;
		
		material.emissiveFresnelParameters = new FresnelParameters();
		material.emissiveFresnelParameters.bias = 0.5;
		material.emissiveFresnelParameters.power = 4;
		material.emissiveFresnelParameters.leftColor = Color3.White();
		material.emissiveFresnelParameters.rightColor = Color3.Black();
		
		sphere2.material = material;
		sphere2.isBlocker = true; // For intercepting lens flare
		
		// Sphere3 material
		material = new StandardMaterial("kosh3", scene);
		material.diffuseColor = new Color3(0, 0, 0);
		material.emissiveColor = Color3.White();
		material.specularPower = 64;
		material.alpha = 0.2;
		
		// Fresnel
		material.emissiveFresnelParameters = new FresnelParameters();
		material.emissiveFresnelParameters.bias = 0.2;
		material.emissiveFresnelParameters.leftColor = Color3.White();
		material.emissiveFresnelParameters.rightColor = Color3.Black();
		
		material.opacityFresnelParameters = new FresnelParameters();
		material.opacityFresnelParameters.power = 4;
		material.opacityFresnelParameters.leftColor = Color3.White();
		material.opacityFresnelParameters.rightColor = Color3.Black();
		
		sphere3.material = material;
		sphere3.isBlocker = true; // For intercepting lens flare
		
		// Sphere4 material
		material = new StandardMaterial("kosh4", scene);
		material.diffuseColor = new Color3(0, 0, 0);
		material.emissiveColor = Color3.White();
		material.specularPower = 64;
		
		// Fresnel
		material.emissiveFresnelParameters = new FresnelParameters();
		material.emissiveFresnelParameters.power = 4;
		material.emissiveFresnelParameters.bias = 0.5;
		material.emissiveFresnelParameters.leftColor = Color3.White();
		material.emissiveFresnelParameters.rightColor = Color3.Black();
		
		sphere4.material = material;
		sphere4.isBlocker = true; // For intercepting lens flare
		
		// Sphere5 material
		material = new StandardMaterial("kosh5", scene);
		material.diffuseColor = new Color3(0, 0, 0);
		material.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		material.reflectionTexture.level = 0.5;
		material.specularPower = 64;
		material.emissiveColor = new Color3(0.2, 0.2, 0.2);
		
		// Fresnel
		material.emissiveFresnelParameters = new FresnelParameters();
		material.emissiveFresnelParameters.bias = 0.4;
		material.emissiveFresnelParameters.power = 2;
		material.emissiveFresnelParameters.leftColor = Color3.Black();
		material.emissiveFresnelParameters.rightColor = Color3.White();
		
		sphere5.material = material;
		sphere5.isBlocker = true; // For intercepting lens flare
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		// Lens flares
		var lensFlareSystem = new LensFlareSystem("lensFlareSystem", light, scene);
		var flare00 = new LensFlare(0.2, 0, new Color3(1, 1, 1), "assets/img/flare.png", lensFlareSystem);
		var flare01 = new LensFlare(0.5, 0.2, new Color3(0.5, 0.5, 1), "assets/img/flare.png", lensFlareSystem);
		var flare02 = new LensFlare(0.2, 1.0, new Color3(1, 1, 1), "assets/img/flare.png", lensFlareSystem);
		var flare03 = new LensFlare(0.4, 0.4, new Color3(1, 0.5, 1), "assets/img/flare.png", lensFlareSystem);
		var flare04 = new LensFlare(0.1, 0.6, new Color3(1, 1, 1), "assets/img/flare.png", lensFlareSystem);
		var flare05 = new LensFlare(0.3, 0.8, new Color3(1, 1, 1), "assets/img/flare.png", lensFlareSystem);
		
		// Animations
		scene.registerBeforeRender(function() {
			camera.alpha += 0.01 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
		
	}
	
}
	