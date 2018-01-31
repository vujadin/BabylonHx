package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Scalar;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Lines3 {
	
	var MAX = 360;
	var R = 20;
	var A = 100.0;
	var B = 99.0;
	var C = 1.0;
	var alpha = Math.PI / 4;
	var beta  = Math.PI / 3;
	var gamma = 0.0;
	var theta = 0.0;


	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(20, 20, 100));
		camera.attachControl();
		camera.maxZ = 200;
		scene.clearColor = new Color4(0, 0, 0, 1);
		
		var points:Array<Vector3> = [];
		var i = 0.0;
		while (i <= MAX) {
			var x = R * Math.sin(2 * Math.PI * i / MAX * A + alpha);
			var y = R * Math.sin(2 * Math.PI * i / MAX * B + beta);
			var z = R * Math.sin(2 * Math.PI * i / MAX * C + gamma);
			points.push(new Vector3(x, y, z));
			i += 0.1;
		}
		
		var mesh = Mesh.CreateLines("mesh", points, scene, true);
		mesh.color = new Color3(1, 1, 0);
		
		scene.registerBeforeRender(function(_, _) {
			mesh.rotation.x = theta;
			mesh.rotation.y = theta;
			theta += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}