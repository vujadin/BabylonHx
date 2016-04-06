package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
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
class GlosinessAndRoughness {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		
		camera.setTarget(Vector3.Zero());
		
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		var sphere1 = Mesh.CreateSphere("sphere1", 32, 2, scene);		
		var sphere2 = Mesh.CreateSphere("sphere2", 32, 2, scene);		
		var sphere3 = Mesh.CreateSphere("sphere3", 32, 2, scene);		
		var sphere4 = Mesh.CreateSphere("sphere4", 32, 2, scene);		
		var sphere5 = Mesh.CreateSphere("sphere5", 32, 2, scene);		
		var sphere6 = Mesh.CreateSphere("sphere6", 32, 2, scene);
		
		sphere1.position.x = -6;		
		sphere2.position.x = -3;
		sphere3.position.x = 0;		
		sphere4.position.x = 3;		
		sphere5.position.x = 6;		
		sphere6.position.x = 6;
		sphere6.position.z = 3;
		
		var mat1 = new StandardMaterial("mat1", scene);
		mat1.specularTexture = new Texture("assets/img/specmap.png", scene);
		mat1.specularPower = 16;
		mat1.diffuseColor = Color3.Black();
		
		sphere1.material = mat1;
		
		var mat2 = new StandardMaterial("mat2", scene);
		mat2.specularTexture = new Texture("assets/img/specmap.png", scene);
		mat2.specularPower = 16;
		mat2.diffuseColor = Color3.Black();
		mat2.useGlossinessFromSpecularMapAlpha = true;
		
		sphere2.material = mat2;
		
		var mat3 = new StandardMaterial("mat3", scene);
		mat3.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		mat3.diffuseColor = Color3.Black();
		sphere3.material = mat3;
		
		var mat4 = new StandardMaterial("mat4", scene);
		mat4.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		mat4.diffuseColor = Color3.Black();
		mat4.roughness = 2.5;
		sphere4.material = mat4;
		
		var mat5 = new StandardMaterial("mat5", scene);
		mat5.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		mat5.specularTexture = new Texture("assets/img/specmap.png", scene);
		mat5.specularPower = 16;
		mat5.diffuseColor = Color3.Black();
		mat5.useGlossinessFromSpecularMapAlpha = true;
		mat5.roughness = 4;
		sphere5.material = mat5;
		
		var mat6 = new StandardMaterial("mat6", scene);
		mat6.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		mat6.reflectionTexture.level = 0.5;
		mat6.specularTexture = new Texture("assets/img/specmap.png", scene);
		mat6.specularPower = 16;
		mat6.diffuseColor = Color3.Black();
		mat6.useGlossinessFromSpecularMapAlpha = true;
		mat6.roughness = 6;
		sphere6.material = mat6;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.infiniteDistance = true;
		skybox.material = skyboxMaterial;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
