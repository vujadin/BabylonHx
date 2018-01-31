package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
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
class HeightMap {

	public function new(scene:Scene) {
		// Light
		var spot = new SpotLight("spot", new Vector3(0, 80, 10), new Vector3(0, -1, 0), 17, 1, scene);
		spot.diffuse = new Color3(1, 1, 1);
		spot.specular = new Color3(0, 0, 0);
		
		// Camera
		var camera = new ArcRotateCamera("Camera", 0, (Math.PI / 2) * 0.9, 250, Vector3.Zero(), scene);
		//camera.upperBetaLimit = camera.lowerBetaLimit = (Math.PI / 2) * 0.9;
		//camera.upperRadiusLimit = camera.lowerRadiusLimit = 250;
		camera.attachControl();
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		// Ground
		var ground:Mesh = Mesh.CreateGroundFromHeightMap("ground", "assets/img/smb.png", 400, 400, 256, 0, 50, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/smb.png", scene);
		//cast(groundMaterial.diffuseTexture, Texture).uScale = 10;
		//cast(groundMaterial.diffuseTexture, Texture).vScale = 10;		
		ground.material = groundMaterial;		
		
		scene.registerBeforeRender(function(_, _) {
			camera.alpha += 0.005;
		});
		
		scene.getEngine().runRenderLoop(function() {
            scene.render();
        });
	}
	
}
