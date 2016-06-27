package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RefractReflect {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		var material = new StandardMaterial("kosh", scene);
		var sphere1 = Mesh.CreateSphere("Sphere1", 32, 5, scene);
		var light = new PointLight("Omni0", new Vector3(-17.6, 18.8, -49.9), scene);

		camera.setPosition(new Vector3(-15, 3, 0));
		camera.attachControl();

		// Sphere1 material
		material.refractionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		material.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		material.diffuseColor = new Color3(0, 0, 0);
		material.invertRefractionY = false;
		material.indexOfRefraction = 0.98;
		material.specularPower = 128;
		sphere1.material = material;
		
		material.refractionFresnelParameters = new FresnelParameters();
		material.refractionFresnelParameters.power = 2;
		material.reflectionFresnelParameters = new FresnelParameters();
		material.reflectionFresnelParameters.power = 2;
		material.reflectionFresnelParameters.leftColor = Color3.Black();
		material.reflectionFresnelParameters.rightColor = Color3.White();

		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
