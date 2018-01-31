package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.layer.Layer;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.postprocess.SSAORenderingPipeline;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SSAO {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0, 0, 0, 1);
		
		// Create camera
		var camera = new FreeCamera("camera", new Vector3(29, 13, 23), scene);
		camera.setTarget(new Vector3(0, 0, 0));
		camera.attachControl();
		
		// Create some boxes and deactivate lighting (specular color and back faces)
		var boxMaterial = new StandardMaterial("boxMaterail", scene);
		boxMaterial.diffuseTexture = new Texture("assets/img/ground.jpg", scene);
		boxMaterial.specularColor = Color3.Black();
		boxMaterial.emissiveColor = Color3.White();
		
		for (i in 0...10) {
			for (j in 0...10) {
				var box = Mesh.CreateBox("box" + i + " - " + j, 5, scene);
				box.position = new Vector3(i * 5, 2.5, j * 5);
				box.rotation = new Vector3(i, i * j, j);
				box.material = boxMaterial;
			}
		}
		
		// Create SSAO and configure all properties (for the example)
		var ssaoRatio = {
			ssaoRatio: 0.5, // Ratio of the SSAO post-process, in a lower resolution
			combineRatio: 1.0 // Ratio of the combine post-process (combines the SSAO and the scene)
		};
		
		var ssao = new SSAORenderingPipeline("ssao", scene, ssaoRatio);
		ssao.fallOff = 0.000001;
		ssao.area = 1;
		ssao.radius = 0.0001;
		ssao.totalStrength = 1.0;
		ssao.base = 0.5;
		
		// Attach camera to the SSAO render pipeline
		scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline("ssao", camera);
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
