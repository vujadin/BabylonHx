package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Color3;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.lib.lava.LavaMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LavaMat {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 50, -300), scene);
		camera.attachControl();
		
		// Lights
		var hemisphericLight = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);		
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;		
		
		// Lava
		var lava = new LavaMaterial("lava", scene);
		lava.diffuseTexture = new Texture("assets/img/lavatile.jpg", scene);
		lava.noiseTexture = new Texture("assets/img/cloud.png", scene);	
		lava.fogColor = new Color3(.2, .2, .4);
		lava.speed = 1.5;	
		
		var ground = Mesh.CreateGround("ground", 500, 500, 100, scene);
		ground.material = lava;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
