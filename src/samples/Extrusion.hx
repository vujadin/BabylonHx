package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Extrusion {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 50, Vector3.Zero(), scene);
		camera.attachControl(this, true);
								
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = 0.7;
				
		// curve
		var curvePoints = function(l:Float, t:Float):Array<Vector3> {
			var path:Array<Vector3> = [];
			var step = l / t;
			var i = -l / 2;
			while(i <= l/2) {
				path.push(new Vector3(12 * Math.sin(i / 10), i, 0));
				i += step;
			}
			return path;
		};
		var curve = curvePoints(40, 200);
	  
		// 2D shape
		var shape = [
			new Vector3(0, 1, -1),  
			new Vector3(0 , 1, 0),
			new Vector3(0 , 0.6, 0.3),
			new Vector3(0 , 0.8, 0.8),
			new Vector3(0 , 0.3, 0.6),
			new Vector3(0 , 0, 1),
			new Vector3(0, -1, 1)
		];
		
		// custom scale function
		var myScaling = function(i:Float, distance:Float):Float {
			var scale = Math.cos(distance / 40) * 4;
			return scale;
		};
		
		// custom rotation function
		var myRotation = function(i:Float, distance:Float):Float {
			var rotation = distance / 300 * Math.PI / 2;
			return rotation;
		};
		
		var extr = Mesh.ExtrudeShapeCustom("extr", shape, curve, myScaling, myRotation, false, false, scene);
		extr.material = scene.defaultMaterial;
		extr.material.backFaceCulling = false;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
