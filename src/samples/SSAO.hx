package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.Engine;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.math.Vector3;
import com.babylonhx.postprocess.SSAORenderingPipeline;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SSAO {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -2.5, 1.0, 200, new Vector3(0, 0, 0), scene);
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		
		// The first parameter can be used to specify which mesh to import. Here we import all meshes
		SceneLoader.Append("assets/models/", "SSAOcat.babylon", scene, function (_) {
			scene.activeCamera = camera;
			camera.attachControl(this);
			
			// Create ssao rendering pipeline
			/*
			SSAO is a rendering pipeline, so we have to attach it to cameras
			The ratio is used by SSAO & Blur post-processes before adding to the
			original scene color to save performances. It is advised to use a ratio
			between 0.5 and 0.75 for good results and performances.
			You can also attach cameras directly by passing an array of Camera to the
			last parameter.
			*/
			
			var ssao = new SSAORenderingPipeline('ssaopipeline', scene, 0.75);
			scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssaopipeline", camera);

			Engine.keyDown.push(function (keyCode:Int) {
				// draw SSAO with scene when pressed "1"
				if (keyCode == 49) {
					scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssaopipeline", camera);
					scene.postProcessRenderPipelineManager.enableEffectInPipeline("ssaopipeline", ssao.SSAOCombineRenderEffect, camera);
				}
					// draw without SSAO when pressed "2"
				else if (keyCode == 50) {
					scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline("ssaopipeline", camera);
				}
					// draw only SSAO when pressed "3"
				else if (keyCode == 51) {
					scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssaopipeline", camera);
					scene.postProcessRenderPipelineManager.disableEffectInPipeline("ssaopipeline", ssao.SSAOCombineRenderEffect, camera);
				}
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
