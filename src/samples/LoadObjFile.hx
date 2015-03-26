package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.procedurals.standard.WoodProceduralTexture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonhxext.objparser.ObjParser;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadObjFile {

	public function new(scene:Scene) {
		//light
		var light = new DirectionalLight("dir01", new Vector3(-0.5, 1, -0.5), scene);
		light.diffuse = new Color3(1, 1, 1);
		light.specular = new Color3(1, 1, 1);
		light.position = new Vector3(20, 40, 20);
				
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 100, Vector3.Zero(), scene);
		camera.attachControl(this, false);
				
		var objParser = new ObjParser("assets/models/", "dagger.obj", scene);
		
		// Move the light with the camera
		scene.registerBeforeRender(function () {
			light.position = camera.position;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}