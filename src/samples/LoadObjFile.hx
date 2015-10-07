package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhxext.loaders.obj.ObjLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadObjFile {

	public function new(scene:Scene) {
		//light
		var light = new DirectionalLight("dir01", new Vector3(0.5, 1, -0.5), scene);
		light.position = new Vector3(20, 40, 20);
				
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 7, Vector3.Zero(), scene);
		camera.attachControl(this, false);
		
		new Layer("background", "assets/img/graygrad.jpg", scene, true);
						
		var objParser = new ObjLoader(scene);
		objParser.load("assets/models/", "apricot.obj", function(meshes:Array<Mesh>) {
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
