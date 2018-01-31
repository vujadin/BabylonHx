package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Space;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TestRot {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("cam", 0.15, 0.35, 60, Vector3.Zero(), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		var box = Mesh.CreateBox("m", 10, scene);
		box.material = new StandardMaterial("mat", scene);
		box.material.freeze();
		
		var rotationAxis = new Vector3(1, 0, 0);
		var rotationAngle = 0.0;
		var rotationSpeed = 0.0005;
		/*scene.registerBeforeRender(function(_, _) {
			box.rotate(rotationAxis, rotationAngle, Space.WORLD);
			rotationAngle += rotationSpeed;
			if (rotationAngle > 0.2) {
				rotationSpeed = -0.0005;
			}
			if (rotationAngle < -0.2) {
				rotationSpeed = 0.0005;
			}
		});*/
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
