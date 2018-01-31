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
class WaterMat2 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -Math.PI / 3, Math.PI * 2 / 5, 100, new Vector3(0,25,0), scene);
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		
		// Ground
		var groundTexture = new Texture("assets/img/sand.jpg", scene);
		groundTexture.vScale = groundTexture.uScale = 4.0;
		
		var groundMaterial = new StandardMaterial("groundMaterial", scene);
		groundMaterial.diffuseTexture = groundTexture;

		var ground = Mesh.CreateGround("ground", 512, 512, 32, scene, false);
		ground.position.y = -1;
		ground.material = groundMaterial;
		
		var gate = Mesh.CreateTorus("test", 50, 5, 8, scene);
		gate.position.y = 25;
		gate.rotation.x = Math.PI / 2;
		gate.convertToFlatShadedMesh();
		
		var waterMesh1 = Mesh.CreateSphere("test", 64, 50, scene);
		waterMesh1.scaling.y = 0.01;
		waterMesh1.parent = gate;		
		
		var water = new WaterMaterial("water", scene, new Vector2(1024, 1024));
		water.backFaceCulling = true;
		water.bumpTexture = new Texture("assets/img/waterbump.png", scene);
		water.windForce = 5;
		water.waveHeight = 0.3;
		water.bumpHeight = 3;
		water.waveLength = 0.5;
		water.waterColor = new Color3(0.1, 0.1, 0.3);
		water.colorBlendFactor = 0.5;
		water.addToRenderList(skybox);
		water.addToRenderList(ground);
		
		water.alpha = 0.9;
		
		waterMesh1.material = water;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
