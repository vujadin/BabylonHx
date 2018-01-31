package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;
import com.babylonhx.Scene;
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
class SoftShadows {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -2.5, 1.0, 200, new Vector3(0, 1.0, 0), scene);
		camera.attachControl();
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		
		SceneLoader.ImportMesh("", "assets/models/", "SSAOcat.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			
			//scene.lights[0].dispose();
			scene.activeCamera = camera;
			camera.attachControl();
			
			var light = new DirectionalLight("light", new Vector3(0, -0.5, 0.8), scene);
			var light2 = new DirectionalLight("light", new Vector3(0, -0.5, 0.8), scene);
			var light3 = new DirectionalLight("light", new Vector3(0, -0.5, 0.8), scene);
			
			light.position = new Vector3(0, 120.0, -10);
			light2.position = new Vector3(0, 120.0, -10);
			light3.position = new Vector3(0, 120.0, -10);
			
			light.diffuse = Color3.Red();
			light2.diffuse = Color3.Green();
			light3.diffuse = Color3.Blue();
			
			var cat = scene.meshes[2];
			cat.receiveShadows = false;
			
			// Shadows
			var generator = new ShadowGenerator(512, light);
			generator.getShadowMap().renderList.push(cat);
			generator.useBlurExponentialShadowMap = true;
			generator.blurBoxOffset = 2.0;
			
			var generator2 = new ShadowGenerator(512, light2);
			generator2.getShadowMap().renderList.push(cat);
			generator2.useBlurExponentialShadowMap = true;
			generator2.blurBoxOffset = 2.0;
			
			var generator3 = new ShadowGenerator(512, light3);
			generator3.getShadowMap().renderList.push(cat);
			generator3.useBlurExponentialShadowMap = true;
			generator3.blurBoxOffset = 2.0;
			
			// Animations
			var alpha = 0.0;
			scene.registerBeforeRender(function(_, _) {
				light.direction.z = 0.8 * Math.cos(alpha);
				light.direction.x = 0.3 * Math.sin(alpha);
				
				light2.direction.z = 0.3 * Math.cos(alpha);
				light2.direction.x = 0.8 * Math.sin(alpha);
				
				light3.direction.x = 0.3 * Math.cos(alpha);
				light3.direction.z = 0.8 * Math.sin(alpha);
				alpha += 0.01;
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}