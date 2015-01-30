package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.SpotLight;
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
		var spot = new SpotLight("spot", new Vector3(0, 30, 10), new Vector3(0, -1, 0), 17, 1, scene);
		spot.diffuse = new Color3(1, 1, 1);
		spot.specular = new Color3(0, 0, 0);
		spot.intensity = 0.3;
		
		// Camera
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 100, Vector3.Zero(), scene);
		camera.lowerBetaLimit = 0.1;
		camera.upperBetaLimit = (Math.PI / 2) * 0.9;
		camera.lowerRadiusLimit = 30;
		camera.upperRadiusLimit = 150;
		camera.attachControl(this, true);
		
		// Ground
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("img/earth.jpg", scene);
		
		var ground = Mesh.CreateGroundFromHeightMap("ground", "img/worldHeightMap.jpg", 200, 200, 250, 0, 10, scene, false);
		ground.material = groundMaterial;
		
		//Sphere to see the light's position
		var sun = Mesh.CreateSphere("sun", 10, 4, scene);
		sun.material = new StandardMaterial("sun", scene);
		cast(sun.material, StandardMaterial).emissiveColor = new Color3(1, 1, 0);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 800.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		
		//Sun animation
		scene.registerBeforeRender(function () {
			sun.position = spot.position;
			spot.position.x -= 0.5;
			if (spot.position.x < -90)
				spot.position.x = 100;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
