package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Color3;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.postprocess.Bloom2PostProcess;
import com.babylonhx.math.Vector2;

import com.babylonhx.postprocess.BlurPostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PostprocessBloom2 {

	public function new(scene:Scene) {		
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.setPosition(new Vector3(-10, 10, 0));
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.intensity = 1.8;
		
		SceneLoader.ImportMesh("", "assets/models/chest/", "chest.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			
			// Skybox
			var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
			var skyboxMaterial = new StandardMaterial("skyBox", scene);
			skyboxMaterial.backFaceCulling = false;
			skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
			skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
			skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
			skyboxMaterial.specularColor = new Color3(0, 0, 0);
			skybox.material = skyboxMaterial;
			skybox.infiniteDistance = true;
			
			var bloomPP = new Bloom2PostProcess("bloom2_PP", 0.5, camera);
			
			/*var blurWidth = 1.0;
		
			var postProcess0 = new PassPostProcess("Scene copy", 1.0, camera);
			var postProcess1 = new PostProcess("Down sample", "downsample", ["screenSize", "highlightThreshold"], null, 0.25, camera, Texture.BILINEAR_SAMPLINGMODE);
			postProcess1.onApply = function (effect:Effect, es:EventState = null) {
				effect.setFloat2("screenSize", postProcess1.width, postProcess1.height);
				effect.setFloat("highlightThreshold", 0.90);
			};
			var postProcess2 = new BlurPostProcess("Horizontal blur", new Vector2(1.0, 0), blurWidth, 0.25, camera);
			var postProcess3 = new BlurPostProcess("Vertical blur", new Vector2(0, 1.0), blurWidth, 0.25, camera);
			var postProcess4 = new PostProcess("Final compose", "compose", ["sceneIntensity", "glowIntensity", "highlightIntensity"], ["sceneSampler"], 1, camera);
			postProcess4.onApply = function (effect:Effect, es:EventState = null) {
				effect.setTextureFromPostProcess("sceneSampler", postProcess0);
				effect.setFloat("sceneIntensity", 0.5);
				effect.setFloat("glowIntensity", 0.4);
				effect.setFloat("highlightIntensity", 1.0);
			};*/
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});	
		
	}
	
}
