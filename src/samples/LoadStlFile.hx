package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonhxext.loaders.stl.StlLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadStlFile {

	public function new(scene:Scene) {
		//light
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
				
		var camera = new ArcRotateCamera("Camera", 0.14, 2.0, 9, Vector3.Zero(), scene);
		camera.attachControl(this, false);
		
		new Layer("background", "assets/img/graygrad.jpg", scene, true);
				
		var stlLoader = new StlLoader(scene);
		stlLoader.load("assets/models/", "soccerball2.stl", false);
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});	
	}
	
}
