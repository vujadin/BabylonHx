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
		// Collisions
		camera.checkCollisions = true;
		camera.applyGravity = true;
		  
        // Torus
        var torus = Mesh.CreateTorus("torus", 4, 2, 30, scene, false);
		torus.material = new StandardMaterial("torusmat", scene);
		untyped torus.material.diffuseTexture = new Texture("assets/img/wood.jpg", scene);
		
		light.position = new Vector3(0, 10, 0);
		light.intensity = 0.3;
		
		objLoader.load("assets/models/des/", "desert1.obj", function(meshes:Array<Mesh>) {
			meshes[0].scaling.set(10, 10, 10);
			meshes[0].material = new StandardMaterial("desmat", scene);
			cast(meshes[0].material, StandardMaterial).diffuseTexture = new Texture("assets/models/des/sand tex.jpg", scene);
			cast(meshes[0].material, StandardMaterial).specularTexture = new Texture("assets/models/des/sand02c_color_spec.jpg", scene);
			cast(meshes[0].material, StandardMaterial).bumpTexture = new Texture("assets/models/des/sand02c_color_nrm.jpg", scene);
			cast(meshes[0].material, StandardMaterial).specularPower = 15;
			cast(meshes[0].material, StandardMaterial).backFaceCulling = false;
			meshes[0].showBoundingBox = true;			
			meshes[0].position.y = -2.05;
			meshes[0].checkCollisions = true;
			meshes[0].receiveShadows = true;
			
			// Shadows
			var shadowGenerator = new ShadowGenerator(1024, light);
			shadowGenerator.getShadowMap().renderList.push(torus);
			shadowGenerator.useVarianceShadowMap = true;
			
			var shadowGenerator2 = new ShadowGenerator(1024, light2);
			shadowGenerator2.getShadowMap().renderList.push(torus);
			shadowGenerator2.usePoissonSampling = true;
			
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
			scene.registerBeforeRender(function () {
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
