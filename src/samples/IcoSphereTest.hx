package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.math.Vector3;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class IcoSphereTest {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		camera.setTarget(Vector3.Zero());		
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		var sphere = Mesh.CreateIcoSphere("icosphere", { radius:2, flat:true, subdivisions: 16 }, scene);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}