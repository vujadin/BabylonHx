package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.lib.normal.NormalMaterial;
//import com.babylonhx.materials.lib.terrain.TerrainMaterial;
//import com.babylonhx.materials.lib.simple.SimpleMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.lights.HemisphericLight;

/**
 * ...
 * @author Krtolica Vujadin
 */
class NormalMat {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", Math.PI / 2, Math.PI / 2, 100, Vector3.Zero(), scene);
		camera.attachControl();
		
		// Lights
		var hemisphericLight = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);		
		
		var knot = Mesh.CreateTorusKnot("knot", 10, 3, 128, 64, 2, 3, scene);
		
		// Skybox
		/*var skybox = Mesh.CreateBox("skyBox", 1000, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		//skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;*/		
		
		// material
		var normalmat = new NormalMaterial("normalmat", scene);
		knot.material = normalmat;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}