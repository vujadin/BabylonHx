package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.bones.BoneIKController;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BoneIKControllerDemo {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera", 0, 1, 25, Vector3.Zero(), scene);
		camera.setTarget(new Vector3(0, 4, 0));
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		light.intensity = 0.7;
		
		var target = Mesh.CreateSphere('', 10, 5, scene);
		var poleTarget = Mesh.CreateSphere('', 10, 2.5, scene);
		
		SceneLoader.ImportMesh("", "assets/models/Dude/", "Dude.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			var mesh = newMeshes[0];
			var skeleton = skeletons[0];
			mesh.scaling = new Vector3(0.1, 0.1, 0.1);
			mesh.position = new Vector3(0, 0, 0);
			
			var animation = scene.beginAnimation(skeletons[0], 0, 100, true, 1.0);
			
			var t = 0.0;
			
			poleTarget.position.x = 0;
			poleTarget.position.y = 100;
			poleTarget.position.z = -50;
			
			target.parent = mesh;
			poleTarget.parent = mesh;
			
			var ikCtl = new BoneIKController(mesh, skeleton.bones[14], { targetMesh: target, poleTargetMesh: poleTarget, poleAngle: Math.PI });
			
			ikCtl.maxAngle = Math.PI * .9;
			
			/*var bone1AxisViewer = new BoneAxisViewer(scene, skeleton.bones[14], 1, mesh);
			var bone2AxisViewer = new BoneAxisViewer(scene, skeleton.bones[13], 1, mesh);*/
			
			/*gui.add(ikCtl, 'poleAngle', -Math.PI, Math.PI);
			gui.add(ikCtl, 'maxAngle', 0, Math.PI);
			gui.add(poleTarget.position, 'x', -100, 100).name('pole target x');
			gui.add(poleTarget.position, 'y', -100, 100).name('pole target y');
			gui.add(poleTarget.position, 'z', -100, 100).name('pole target z');*/
			
			scene.registerBeforeRender(function (_, _) {				
				var bone = skeleton.bones[14];
				
				t += .03;
				
				var dist = 2 + 12 * Math.sin(t);
				
				target.position.x = -20;
				target.position.y = 40 + 40 * Math.sin(t);
				target.position.z = -30 + 40 * Math.cos(t);
				
				ikCtl.update();
				
				//mesh.rotation.y += .01;
				
				/*bone1AxisViewer.update();
				bone2AxisViewer.update();*/				
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});			
		});
	}
	
}
