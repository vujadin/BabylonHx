package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.lib.gradient.GradientMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GradientMaterialTest {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();

		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.groundColor = new Color3(1,1,1);
		light.intensity = 1;
		
		var sphere = Mesh.CreateSphere("sphere1", 16, 3, scene);
		sphere.position.y = 0;
		
		var gradientMaterial = new GradientMaterial("grad", scene);
		gradientMaterial.topColor = new Color3(1, 0, 0);
		gradientMaterial.bottomColor = new Color3(0, 0, 1);
		gradientMaterial.offset = 0;
		gradientMaterial.smoothness = 1.3;
		// gradientMaterial.pointSize = 1;
		// gradientMaterial.vOffset = 0;
		sphere.material = gradientMaterial;
		
		var alpha = Math.PI;
		scene.registerBeforeRender(function(_, _) {
			sphere.position.y += Math.cos(alpha) / 100;
			alpha += .01;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}