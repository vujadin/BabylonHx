package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.lib.fire.FireMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FireMat {

	public function new(scene:Scene) {
		scene.clearColor = new Color3(0, 0, 0);
	
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		// Create fire material
		var fire = new FireMaterial("fire", scene);
		fire.diffuseTexture = new Texture("assets/img/fire/diffuse.png", scene);
		fire.distortionTexture = new Texture("assets/img/fire/distortion.png", scene);
		fire.opacityTexture = new Texture("assets/img/fire/opacity.png", scene);
		fire.speed = 5.0;
		
		var light = new SpotLight("light", new Vector3(2, 2, 2), new Vector3(-1, -2, -1), 3, 1, scene);
		var generator = new ShadowGenerator(512, light);
		generator.useBlurVarianceShadowMap = true;
		generator.blurBoxOffset = 2.0;
		
		SceneLoader.ImportMesh("", "assets/models/", "candle.babylon", scene, function (meshes:Array<AbstractMesh>, skeletons, particleSystems) {
			var plane = scene.getMeshByName("Plane");
			plane.receiveShadows = true;
			
			for (i in 0...meshes.length) {
				if (meshes[i] != plane) {
					generator.getShadowMap().renderList.push(meshes[i]);
				}
			}
			
			plane = Mesh.CreatePlane("fireplane", 1.5, scene);
			plane.position = new Vector3(0, 2.2, 0);
			plane.scaling.x = 0.1;
			plane.scaling.y = 0.7;
			plane.billboardMode = AbstractMesh.BILLBOARDMODE_Y;
			plane.material = fire;
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
