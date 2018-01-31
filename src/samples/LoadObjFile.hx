package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhxext.loaders.obj.ObjLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;

import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.shadows.ShadowGenerator;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadObjFile {
	
	static var models = ["Brown_Cliff_01"];
	//static var models = ["Brown_Cliff_01", "Brown_Cliff_Bottom_01", "Brown_Cliff_Bottom_Corner_01", "Brown_Cliff_Bottom_Corner_Green_Top_01", "Brown_Cliff_Bottom_Green_Top_01", "Brown_Cliff_Corner_01", "Brown_Cliff_Corner_Green_Top_01", "Brown_Cliff_End_01", "Brown_Cliff_End_Green_Top_01", "Brown_Cliff_Green_Top_01", "Brown_Cliff_Top_01", "Brown_Cliff_Top_Corner_01", "Brown_Waterfall_01", "Brown_Waterfall_Top_01", "Campfire_01", "Fallen_Trunk_01", "Flower_Red_01", "Flower_Tall_Red_01"];

	public function new(scene:Scene) {
		
		scene.gravity = new Vector3(0, -0.5, 0);
		
		var objLoader = new ObjLoader(scene);
		
		// light1
        var light = new DirectionalLight("dir01", new Vector3(-1, -2, -1), scene);
        light.position = new Vector3(20, 60, 20);
        light.intensity = 0.5;
        
        var lightSphere = Mesh.CreateSphere("sphere", 10, 2, scene);
        lightSphere.position = light.position;
        lightSphere.material = new StandardMaterial("light", scene);
        cast(lightSphere.material, StandardMaterial).emissiveColor = new Color3(1, 1, 0);
        
        // light2
        var light2:SpotLight = new SpotLight("spot02", new Vector3(30, 60, 20), new Vector3(-1, -2, -1), 1.2, 24, scene);
        //light2.intensity = 0.5;
        
        var lightSphere2 = Mesh.CreateSphere("sphere", 10, 2, scene);
        lightSphere2.position = light2.position;
        lightSphere2.material = new StandardMaterial("light", scene);
        cast(lightSphere2.material, StandardMaterial).emissiveColor = new Color3(1, 1, 0);
		
		var camera = new FreeCamera("Camera", new Vector3(0, 30, -0), scene);
		camera.attachControl(this);
		camera.speed = 0.4;
		
        // Torus
        var torus = Mesh.CreateTorus("torus", 4, 2, 30, scene, false);
		torus.material = new StandardMaterial("torusmat", scene);
		untyped torus.material.diffuseTexture = new Texture("assets/img/wood.jpg", scene);
		
		light.position = new Vector3(0, 10, 0);
		light.intensity = 0.3;
		
		objLoader.load("assets/models/meleagre/", "meleagre.obj", function(meshes:Array<Mesh>) {			
			// Skybox
			var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
			var skyboxMaterial = new StandardMaterial("skyBox", scene);
			skyboxMaterial.backFaceCulling = false;
			skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
			skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
			skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
			skyboxMaterial.specularColor = new Color3(0, 0, 0);
			skybox.material = skyboxMaterial;
			skybox.infiniteDistance = true;
			
			// Animations
			var alpha = 0.0;
			scene.registerBeforeRender(function (_, _) {
				torus.rotation.x += 0.01;
				torus.rotation.z += 0.02;
				torus.position = new Vector3(Math.cos(alpha) * 30, 10, Math.sin(alpha) * 30);
				alpha += 0.01;
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
