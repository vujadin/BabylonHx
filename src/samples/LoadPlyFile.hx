package samples;

import com.babylonhxext.loaders.ply.PlyLoader;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadPlyFile {

	public function new(scene:Scene) {
		//light
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
		
		new Layer("background", "assets/img/graygrad.jpg", scene, true);
				
		var camera = new ArcRotateCamera("Camera", 0.3, 1.1, 15, Vector3.Zero(), scene);
		camera.attachControl(this, false);
				
		var stlLoader = new PlyLoader(scene);
		stlLoader.load("assets/models/", "bunny.ply", function(meshes:Array<Mesh>) {
			var bunny = meshes[0];
			bunny.rotation.y += Math.PI / 2;
			bunny.rotation.x -= Math.PI / 2;
			bunny.position.y -= 2;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});	
	}
	
}
