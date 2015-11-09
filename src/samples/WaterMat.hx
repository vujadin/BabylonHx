package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.lib.water.WaterMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;

/**
 * ...
 * @author Krtolica Vujadin
 */
class WaterMat {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 4, 100, Vector3.Zero(), scene);
		camera.attachControl();

		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", { width: 1000, height: 1000, depth: 1000 }, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		//skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
				
		// Ground
		var groundTexture = new Texture("assets/img/sand.jpg", scene);
		groundTexture.vScale = groundTexture.uScale = 4.0;
		
		var groundMaterial = new StandardMaterial("groundMaterial", scene);
		groundMaterial.diffuseTexture = groundTexture;
		
		var ground = Mesh.CreateGround("ground", { width: 512, height: 512, subdivision: 32, updatable: false }, scene);
		ground.position.y = -1;
		ground.material = groundMaterial;
			
		// Water
		var waterMesh = Mesh.CreateGround("waterMesh", { width: 512, height: 512, subdivision: 32, updatable: false }, scene);
		var water = new WaterMaterial("water", scene, new Vector2(1024, 1024));
		water.backFaceCulling = true;
		water.bumpTexture = new Texture("assets/img/waterbump.png", scene);
		water.windForce = -15;
		water.waveHeight = 0.5;
		water.bumpHeight = 0.1;
		water.colorBlendFactor = 0;
		water.addToRenderList(skybox);
		water.addToRenderList(ground);
		waterMesh.material = water;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
