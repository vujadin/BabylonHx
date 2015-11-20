package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadScene {

	public function new(scene:Scene) {
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		SceneLoader.Load("assets/scenes/toyride_babylon/", "toyride.babylon", scene.getEngine(), function(s:Scene) {
			scene = s;
			//scene.activeCamera.attachControl();
			var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
			camera.attachControl();
			
			var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
			
			// Skybox
			var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
			var skyboxMaterial = new StandardMaterial("skyBox", scene);
			skyboxMaterial.backFaceCulling = false;
			skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/Sky_FantasySky_Fire_Cam", scene);
			skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
			skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
			skyboxMaterial.specularColor = new Color3(0, 0, 0);
			skybox.material = skyboxMaterial;
			skybox.infiniteDistance = true;
				
			s.getEngine().runRenderLoop(function () {
				s.render();
			});
		});	
		
	}
	
}
