package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.postprocess.RefractionPostProcess;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PostprocessRefraction {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 100, Vector3.Zero(), scene);
		camera.attachControl(this);
		var light = new DirectionalLight("dir01", new Vector3(0, -1, -0.2), scene);
		var light2 = new DirectionalLight("dir02", new Vector3(-1, -2, -1), scene);
		light.position = new Vector3(0, 30, 0);
		light2.position = new Vector3(10, 20, 10);
		
		light.intensity = 0.6;
		light2.intensity = 0.6;
		
		camera.setPosition(new Vector3(-60, 60, 0));
		camera.lowerBetaLimit = (Math.PI / 2) * 0.8;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
				
		//Tools.delay(function() {
			//trace("start");
			// Spheres
			var sphere0 = Mesh.CreateSphere("Sphere0", 16, 10, scene);
			var sphere1 = Mesh.CreateSphere("Sphere1", 16, 10, scene);
			var sphere2 = Mesh.CreateSphere("Sphere2", 16, 10, scene);
			
			sphere0.material = new StandardMaterial("red", scene);
			cast(sphere0.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
			cast(sphere0.material, StandardMaterial).diffuseColor = new Color3(1.0, 0, 0);
			
			sphere1.material = new StandardMaterial("green", scene);
			cast(sphere1.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
			cast(sphere1.material, StandardMaterial).diffuseColor = new Color3(0, 1.0, 0);
			
			sphere2.material = new StandardMaterial("blue", scene);
			cast(sphere2.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
			cast(sphere2.material, StandardMaterial).diffuseColor = new Color3(0, 0, 1.0);
			   
			// Post-process
			var postProcess = new RefractionPostProcess("Refraction", "assets/img/refMap.jpg", new Color3(1.0, 1.0, 1.0), 0.5, 0.5, 1.0, camera);
			
			// Animations
			var alpha = 0.0;
			scene.registerBeforeRender(function() {
				sphere0.position = new Vector3(20 * Math.sin(alpha), 0, 20 * Math.cos(alpha));
				sphere1.position = new Vector3(20 * Math.sin(alpha), 0, -20 * Math.cos(alpha));
				sphere2.position = new Vector3(20 * Math.cos(alpha), 0, 20 * Math.sin(alpha));
				
				alpha += 0.01;
			});
		//}, 100);
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
