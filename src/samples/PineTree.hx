package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Color3;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PineTree {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(.5, .5, .5);
		
		// camera
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(0, 0, -200));
		camera.attachControl();
		
		var light = new DirectionalLight("light1", new Vector3(-1, -3, 1), scene);
		light.intensity = 0.7;
		
		var mat = new StandardMaterial("mat1", scene);
		mat.alpha = 1.0;
		mat.diffuseColor = new Color3(0.5, 0.5, 1.0);
		mat.backFaceCulling = false;
		mat.wireframe = false;
		
		var curvePoints = function(l, t) {
			var path = [];
			var step = l / t;
			var i = -l / 2;
			while (i < l / 2) {
				path.push(new Vector3(0, i, 0));
				path.push(new Vector3(0, i, 0 ));
				i += step;
			}
			return path;
		};
		
		var nbL = 8;
		var curve = curvePoints(60, nbL);
		
		var radiusFunction = function (i, distance) {
			var fact = 2.0;
			if (i % 2 == 0) { fact /= 2; }
			var radius =  (nbL * 2 - i - 1) * fact;
			return radius;
		};
		
		var tube = Mesh.CreateTube("tube", curve, 0, 10, radiusFunction, 1, scene);
		tube.material = mat;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
