package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.lib.fur.FurMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FurMat {

	public function new(scene:Scene) {
		var light = new DirectionalLight("dir01", new Vector3(0, -0.5, -1.0), scene);
		//var light = new HemisphericLight("hemi", new Vector3(0, -1, 0), scene);
		//light.intensity = 3;
		
		var camera = new ArcRotateCamera("Camera", -2.5, 1.0, 200, new Vector3(0, 5, 0), scene);
		camera.attachControl();
		
		var configureFur = function (mesh:Mesh) {
			var fur = new FurMaterial("fur", scene);
			fur.furLength = 0;
			fur.furAngle = 0;
			fur.furColor = new Color3(2, 2, 2);
			fur.diffuseTexture = untyped mesh.material.diffuseTexture;
			fur.furTexture = FurMaterial.GenerateTexture("furTexture", scene);
			fur.furSpacing = 6;
			fur.furDensity = 20;
			fur.furSpeed = 300;
			fur.furGravity = new Vector3(0, -1, 0);
			
			mesh.material = fur;
			
			var quality = 30; // It is enougth
			var shells = FurMaterial.FurifyMesh(mesh, quality);
			
			// Special for bunny (ears)
			for (i in 0...shells.length) {
				shells[i].material.backFaceCulling = false;
			}
		}
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
				
		// Meshes
		SceneLoader.ImportMesh("Rabbit", "assets/models/Rabbit/", "Rabbit.babylon", scene, function(newMeshes, particleSystems, skeletons) {	
			var rabbit = newMeshes[1];
			configureFur(cast rabbit);
			rabbit.isVisible = true;
			//scene.beginAnimation(rabbit.skeleton, 0, 72, true, 0.8);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});		
		
	}
	
}
