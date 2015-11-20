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
import com.babylonhxext.loaders.obj.ObjLoader;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PostprocessRefraction {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 90, Vector3.Zero(), scene);
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
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/Sky_FantasySky_Fire_Cam", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
				
		var objParser = new ObjLoader(scene);
		objParser.load("assets/models/", "suzanne.obj", function(meshes:Array<Mesh>) {
			var monkey1 = meshes[0];
			var monkey2 = monkey1.clone("monkey2");
			var monkey3 = monkey1.clone("monkey3");
			
			monkey1.material = new StandardMaterial("red", scene);
			cast(monkey1.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
			cast(monkey1.material, StandardMaterial).diffuseColor = new Color3(1.0, 0, 0);
			
			monkey2.material = new StandardMaterial("green", scene);
			cast(monkey2.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
			cast(monkey2.material, StandardMaterial).diffuseColor = new Color3(0, 1.0, 0);
			
			monkey3.material = new StandardMaterial("blue", scene);
			cast(monkey3.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
			cast(monkey3.material, StandardMaterial).diffuseColor = new Color3(0, 0, 1.0);
			   
			// Post-process
			var postProcess = new RefractionPostProcess("Refraction", "assets/img/refMap.png", new Color3(1.0, 1.0, 1.0), 0.5, 0.5, 1.0, camera);
			
			// Animations
			var alpha = 0.0;
			scene.registerBeforeRender(function() {
				monkey1.position = new Vector3(20 * Math.sin(alpha), 0, 20 * Math.cos(alpha));
				monkey2.position = new Vector3(20 * Math.sin(alpha), 0, -20 * Math.cos(alpha));
				monkey3.position = new Vector3(20 * Math.cos(alpha), 0, 20 * Math.sin(alpha));
				
				monkey1.rotation.x += 0.02;
				monkey1.rotation.y += 0.02;
				
				monkey2.rotation.x += 0.02;
				monkey2.rotation.y += 0.02;
				
				monkey3.rotation.x += 0.02;
				monkey3.rotation.y += 0.02;
				
				alpha += 0.01;
			});
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
