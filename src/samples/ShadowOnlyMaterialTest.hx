package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.ctm.CTMFile;
import com.babylonhx.loading.ctm.CTMFileLoader;
import com.babylonhx.materials.lib.shadowonly.ShadowOnlyMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShadowOnlyMaterialTest {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0, 0, 0, 0);
		scene.ambientColor = new Color3(0.4, 0.4, 0.4);
		
		var camera = new ArcRotateCamera("Camera", -0.5, 0.8, 20, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light = new DirectionalLight('light', new Vector3(0, -1, 1), scene);
		light.intensity = 0.5;
		
		var ground = Mesh.CreatePlane('ground', 1000, scene);
		ground.rotation.x = Math.PI / 2;
		ground.material = new ShadowOnlyMaterial('mat', scene);
		ground.receiveShadows = true;
		
		ground.position.y = -50;
		
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.useBlurExponentialShadowMap = true;
		shadowGenerator.blurScale = 2;
		shadowGenerator.setDarkness(0.2);
		
		CTMFileLoader.load("assets/models/suzanne.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			shadowGenerator.getShadowMap().renderList.push(meshes[0]);
			camera.target = meshes[0];
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}