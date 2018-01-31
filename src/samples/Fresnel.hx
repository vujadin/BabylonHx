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
		camera.attachControl();
		
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
		var material = new StandardMaterial("mat1", scene);
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
		var material2 = new StandardMaterial("mat2", scene);
		material2.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		material2.diffuseColor = new Color3(0, 0, 0);
		material2.emissiveColor = new Color3(0.5, 0.5, 0.5);
		material2.specularPower = 32;
		
		// Fresnel
		material2.reflectionFresnelParameters = new FresnelParameters();
		material2.reflectionFresnelParameters.bias = 0.1;
		
		material2.emissiveFresnelParameters = new FresnelParameters();
		material2.emissiveFresnelParameters.bias = 0.5;
		material2.emissiveFresnelParameters.power = 4;
		material2.emissiveFresnelParameters.leftColor = Color3.White();
		material2.emissiveFresnelParameters.rightColor = Color3.Black();
		
		sphere2.material = material2;
		sphere2.isBlocker = true; // For intercepting lens flare
		
		// Sphere3 material
		var material3 = new StandardMaterial("mat3", scene);
		material3.diffuseColor = new Color3(0, 0, 0);
		material3.emissiveColor = Color3.White();
		material3.specularPower = 64;
		material3.alpha = 0.2;
		
		// Fresnel
		material3.emissiveFresnelParameters = new FresnelParameters();
		material3.emissiveFresnelParameters.bias = 0.2;
		material3.emissiveFresnelParameters.leftColor = Color3.White();
		material3.emissiveFresnelParameters.rightColor = Color3.Black();
		
		material3.opacityFresnelParameters = new FresnelParameters();
		material3.opacityFresnelParameters.power = 4;
		material3.opacityFresnelParameters.leftColor = Color3.White();
		material3.opacityFresnelParameters.rightColor = Color3.Black();
		
		sphere3.material = material3;
		sphere3.isBlocker = true; // For intercepting lens flare
		
		// Sphere4 material
		var material4 = new StandardMaterial("mat4", scene);
		material4.diffuseColor = new Color3(0, 0, 0);
		material4.emissiveColor = Color3.White();
		material4.specularPower = 64;
		
		// Fresnel
		material4.emissiveFresnelParameters = new FresnelParameters();
		material4.emissiveFresnelParameters.power = 4;
		material4.emissiveFresnelParameters.bias = 0.5;
		material4.emissiveFresnelParameters.leftColor = Color3.White();
		material4.emissiveFresnelParameters.rightColor = Color3.Black();
		
		sphere4.material = material4;
		sphere4.isBlocker = true; // For intercepting lens flare
		
		// Sphere5 material
		var material5 = new StandardMaterial("mat5", scene);
		material5.diffuseColor = new Color3(0, 0, 0);
		material5.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		material5.reflectionTexture.level = 0.5;
		material5.specularPower = 64;
		material5.emissiveColor = new Color3(0.2, 0.2, 0.2);
		
		// Fresnel
		material5.emissiveFresnelParameters = new FresnelParameters();
		material5.emissiveFresnelParameters.bias = 0.4;
		material5.emissiveFresnelParameters.power = 2;
		material5.emissiveFresnelParameters.leftColor = Color3.Black();
		material5.emissiveFresnelParameters.rightColor = Color3.White();
		
		sphere5.material = material5;
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
		
		// Animations
		scene.registerBeforeRender(function(_, _) {
			camera.alpha += 0.01 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
		
	}
	
}
	