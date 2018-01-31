package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SelfShadowing {

	public function new(scene:Scene) {
		// Setup environment
		var camera = new FreeCamera("Camera", new Vector3(0, 0, -20), scene);
		camera.attachControl();
		// light1
		var light = new DirectionalLight("dir01", new Vector3(-1, -2, -1), scene);
		light.position = new Vector3(20, 40, 20);
		
		// Torus
		var torus = Mesh.CreateTorusKnot("knot", 2, 0.5, 128, 64, 2, 3, scene);
		torus.position.x = -5;
		
		var torus2 = Mesh.CreateTorusKnot("knot", 2, 0.5, 128, 64, 2, 3, scene);
		torus2.position.x = 5;
		
		// Shadows
		var shadowGenerator = new ShadowGenerator(1024, light, true);
		shadowGenerator.getShadowMap().renderList.push(torus);
		shadowGenerator.useBlurExponentialShadowMap = true;
		light.shadowMinZ = 1;
		light.shadowMaxZ = 2500;
		shadowGenerator.depthScale = 2500;
		shadowGenerator.bias = 0.001;
		
		torus.receiveShadows = true;
		
		scene.registerBeforeRender(function(_, _) {
			torus.rotation.x += 0.01;
			torus2.rotation.x += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function() {
            scene.render();
        });
	}
	
}