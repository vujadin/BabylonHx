package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhxext.loaders.obj.ObjLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Instances2 {

	public function new(scene:Scene) {
		//Adding a light
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
				
		//Adding an Arc Rotate Camera
		var camera = new ArcRotateCamera("Camera", 4, 1.4, 60, Vector3.Zero(), scene);
		camera.attachControl(this, false);
		
		new Layer("background", "assets/img/graygrad.jpg", scene, true);
				
		var objLoader = new ObjLoader(scene); 
		objLoader.load("assets/models/", "suzanne.obj", function(meshes:Array<Mesh>) {
			var _suzanne = meshes[0];
			var instances:Array<InstancedMesh> = [];
			_suzanne.scaling = new Vector3(0.4, 0.4, 0.4);
			for (i in 0...8) {
				for (j in 0...8) {
					for(m in 0...8) {
						var suzanne = _suzanne.createInstance("inst_" + (i + j + m));
						suzanne.material = _suzanne.material;
						suzanne.position.x = i * 4;
						suzanne.position.y = j * 4;
						suzanne.position.z = -m * 4;
						instances.push(suzanne);
					}
				}
			}	
			
			camera.target = instances[220].position;
						
			scene.removeMesh(_suzanne);
			_suzanne = null;
			
			scene.registerBeforeRender(function() {
				for (mesh in instances) {
					mesh.rotation.y += 0.05;
					mesh.rotation.z += 0.05;
				}
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
			
	}
	
}
