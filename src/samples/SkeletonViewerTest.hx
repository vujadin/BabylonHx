package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.debug.SkeletonViewer;

import com.babylonhx.mesh.MeshBuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SkeletonViewerTest {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 45, 20), scene);
		camera.setTarget(new Vector3(0, 40, -80));
		camera.attachControl();
		
		var light = new DirectionalLight("dir01", new Vector3(0, -0.5, -1.0), scene);
		light.position = new Vector3(20, 150, 70);
		
		// Ground
		var ground = Mesh.CreateGround("ground", 1000, 1000, 1, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseColor = new Color3(0.3, 0.3, 0.3);
		groundMaterial.specularColor = new Color3(0, 0, 0);
		ground.material = groundMaterial;
		ground.receiveShadows = true;
		
		// Shadows
		var shadowGenerator = new ShadowGenerator(1024, light);
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		
		SceneLoader.ImportMesh("him", "assets/models/Dude/", "Dude.babylon", scene, function (newMeshes:Array<AbstractMesh>, particleSystems:Array<ParticleSystem>, skeletons:Array<Skeleton>) {
			var dude = newMeshes[0];
			var skeleton = skeletons[0];
			
			for (index in 0...newMeshes.length) {
				shadowGenerator.getShadowMap().renderList.push(newMeshes[index]);
			}
			
			dude.rotation.y = Math.PI;
			dude.position = new Vector3(0, 0, -80);
			
			var sviewer = new SkeletonViewer(skeleton, dude, scene);
			sviewer.isEnabled = true;
			var lorenz = MeshBuilder.CreateLineSystem("lines", { lines: sviewer._debugLines, updatable: true }, scene);
			
			scene.beginAnimation(skeleton, 0, 100, true, 1.0);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});			
			
	}
	
}
