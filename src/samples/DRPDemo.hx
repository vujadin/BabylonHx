package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.ColorCurves;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.postprocess.renderpipeline.pipelines.DefaultRenderingPipeline;


/**
 * ...
 * @author Krtolica Vujadin
 */
class DRPDemo {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 100, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(80, 80, 120));
		camera.setTarget(new Vector3(0, 0, 0));
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		SceneLoader.ImportMesh("", "assets/models/", "skull.babylon", scene, function (newMeshes, _, _) {
			// Set the target of the camera to the first imported mesh
			//camera.setTarget(newMeshes[0]);
		});
		
		var defaultPipeline = new DefaultRenderingPipeline("default", true, scene, [ camera.id => camera ]);
		defaultPipeline.bloomEnabled = true;
		defaultPipeline.fxaaEnabled = true;
		defaultPipeline.bloomWeight = 0.5;
		
		var curve = new ColorCurves();
		curve.globalHue = 200;
		curve.globalDensity = 80;
		curve.globalSaturation = 80;
		
		curve.highlightsHue = 20;
		curve.highlightsDensity = 80;
		curve.highlightsSaturation = -80;
		
		curve.shadowsHue = 2;
		curve.shadowsDensity = 80;
		curve.shadowsSaturation = 40;
		
		defaultPipeline.imageProcessing.colorCurves = curve; 
		
		defaultPipeline.fxaaEnabled = false;
		defaultPipeline.imageProcessingEnabled = true;
		defaultPipeline.imageProcessing.vignetteEnabled = true;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
