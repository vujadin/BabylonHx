package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DashedLinesMesh {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0.8, 0.8, 0.8, 1.0);
		var camera = new ArcRotateCamera("Camera", 3 *Math.PI / 2, Math.PI / 2, 20, Vector3.Zero(), scene);
		camera.attachControl();
		
		// lights
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.groundColor = new Color3(0.2, 0.2, 0.5);
		light.intensity = 0.6;
		
		var points:Array<Vector3> = [];
		var pi2 = Math.PI * 2;
		var nb = 20;
		var step = pi2 / nb;
		var i:Float = 0;
		while (i < nb) {
			points.push(new Vector3(Math.cos(i) * 3, i / 3 - 2, Math.sin(i) * 3));
			i += step;
		}
		
		var dashedLines = Mesh.CreateDashedLines("dl", points, 3, 1, 200, scene, true);
		dashedLines.color = Color3.Blue();
		
		var updatePoints= function(k) {
			for (i in 0...points.length) {
				var x =  Math.cos(k + i / 3) * 3;
				var y =  Math.sin(k + i / 10) * 8;
				var z = Math.sin(k + i / 3) * 3;
				points[i].x = x;
				points[i].y = y;
				points[i].z = z;
			}
		}
		
		var k:Float = 0;
		scene.registerBeforeRender(function(_, _) {
			updatePoints(k);
			dashedLines = Mesh.CreateDashedLines(null, points, 3, 1, 200, scene, true, dashedLines);
			k += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
