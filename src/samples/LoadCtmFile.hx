package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.loading.ctm.CTMFile;
import com.babylonhx.loading.ctm.CTMFileLoader;
import com.babylonhx.postprocess.renderpipeline.pipelines.SSAORenderingPipeline;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadCtmFile {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -50), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		//var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		var light3 = new DirectionalLight("Dir0", new Vector3(1, -1, 0), scene);
		
		//CTMFileLoader.load("assets/models/curioshop_blendswap.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			//meshes[0].scaling.set(3, 3, 3);
		//});
		CTMFileLoader.load("assets/models/renomme/renomme.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			//meshes[0].scaling.set(3, 3, 3);
			for (m in meshes) {
				m.material = new StandardMaterial('renomme_mat', scene);
				untyped m.material.diffuseTexture = new Texture("assets/models/renomme/renomme.jpg", scene);
			}
		});
		
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
