package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.bones.BoneLookController;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BoneLookControllerDemo {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera", 0, 1, 20, new Vector3(0, 4, 0), scene);
		camera.setTarget(new Vector3(0, 4, 0));
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = 0.7;
		
		var sphere = Mesh.CreateSphere('', 10, 0.5, scene);
		
		SceneLoader.ImportMesh("", "assets/models/Dude/", "Dude.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			var mesh = newMeshes[0];
			trace(newMeshes.length);
			var skeleton = skeletons[0];
			
			mesh.scaling = new Vector3(0.1, 0.1, 0.1);
			mesh.position = new Vector3(0, 0, 0);
			
			var animation = scene.beginAnimation(skeletons[0], 0, 100, true, 1.0);
			
			var t1 = 0.0;
			var t2 = 0.0;
			
			//adjustYaw?: number, adjustPitch?: number, adjustRoll?: number
			var lookAtCtl = new BoneLookController(mesh, skeleton.bones[7], sphere.position, { adjustYaw:Math.PI*.5, adjustRoll:Math.PI*.5 });
			trace(skeleton.bones[7].name);
			//var boneAxisViewer = new BoneAxisViewer(scene, skeleton.bones[7], 1, mesh);
			
			scene.registerBeforeRender(function (_, _) {
				t1 += .02;
				t2 += .03;
				
				sphere.position.x = 12 * Math.sin(t1);
				sphere.position.y = 6 + 6 * Math.sin(t2);
				sphere.position.z = -6;
				
				lookAtCtl.update();
				
				//boneAxisViewer.update();				
			});		
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
