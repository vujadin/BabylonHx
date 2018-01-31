package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.layer.Layer;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.postprocess.SSAORenderingPipeline;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SSAO2 {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0, 0, 0, 1);
		
		// Create camera
		var camera = new FreeCamera("camera", new Vector3(29, 13, 23), scene);
		camera.setTarget(new Vector3(0, 0, 0));
		camera.attachControl();
		
		// Create some boxes and deactivate lighting (specular color and back faces)
		var boxMaterial = new StandardMaterial("boxMaterail", scene);
		boxMaterial.diffuseTexture = new Texture("assets/img/ground.jpg", scene);
		boxMaterial.specularColor = Color3.Black();
		boxMaterial.emissiveColor = Color3.White();
		boxMaterial.freeze();
		
		for (i in 0...10) {
			for (j in 0...10) {
				var box = Mesh.CreateBox("box" + i + " - " + j, 5, scene);
				box.position = new Vector3(i * 5, 2.5, j * 5);
				box.rotation = new Vector3(i, i * j, j);
				box.material = boxMaterial;
			}
		}
		
		// Create SSAO and configure all properties (for the example)
		var ssaoRatio = {
			ssaoRatio: 0.5, // Ratio of the SSAO post-process, in a lower resolution
			combineRatio: 1.0 // Ratio of the combine post-process (combines the SSAO and the scene)
		};
		
		var ssao = new SSAORenderingPipeline("ssao", scene, ssaoRatio);
		ssao.fallOff = 0.0002;
		ssao.area = 0.0075;
		ssao.radius = 0.0001;
		ssao.totalStrength = 1.0;
		ssao.base = 0.0;
		
		ssao.getBlurHPostProcess().direction.x = 1;
		ssao.getBlurHPostProcess().width = 2;
		
		ssao.getBlurVPostProcess().direction.y = 1;
		ssao.getBlurVPostProcess().width = 2;
		
		// Attach camera to the SSAO render pipeline
		scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssao", camera);
		
		// Manage SSAO
		scene.getEngine().keyDown.push(function (keyCode:Int) {
			// draw SSAO with scene when pressed "1"
			if (keyCode == 49) {
				scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssao", camera);
				scene.postProcessRenderPipelineManager.enableEffectInPipeline("ssao", ssao.SSAOCombineRenderEffect, camera);
			}
				// draw without SSAO when pressed "2"
			else if (keyCode == 50) {
				scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline("ssao", camera);
			}
				// draw only SSAO when pressed "2"
			else if (keyCode == 51) {
				scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssao", camera);
				scene.postProcessRenderPipelineManager.disableEffectInPipeline("ssao", ssao.SSAOCombineRenderEffect, camera);
			}
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}