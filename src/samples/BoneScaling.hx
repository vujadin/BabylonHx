package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BoneScaling {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 50, -100), scene);
		camera.attachControl();

		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);

		light.intensity = 0.7;

		var ground = Mesh.CreateGround("ground1", 100, 100, 1, scene);
		
		SceneLoader.ImportMesh("him", "assets/models/Dude/", "Dude.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			var dude = newMeshes[0];
			var skeleton = skeletons[0];
			
			scene.beginAnimation(skeletons[0], 0, 100, true, 1.0);
			
			var t = 0.0;
			
			skeleton.bones[7].setScale(1.6, 1.6, 1.6);
			
			scene.registerBeforeRender(function (_, _) {
				t += .01;				
				skeleton.bones[7].setYawPitchRoll(0, Math.PI * .3 * Math.sin(t), -Math.PI * .2);				
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
