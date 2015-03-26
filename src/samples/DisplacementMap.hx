package samples;

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
class DisplacementMap {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.attachControl(this);
		
		var light = new HemisphericLight("Omni0", new Vector3(0, 1, 0), scene);
		var material = new StandardMaterial("kosh", scene);
		var sphere = Mesh.CreateSphere("Sphere", 32, 3, scene, true);
		
		camera.setPosition(new Vector3( -10, 10, 0));
		
		sphere.applyDisplacementMap("assets/img/amiga.jpg", 0, 1.5);
		
		// Sphere material
		material.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
		sphere.material = material;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
