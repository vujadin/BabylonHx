package samples;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Color3;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.animations.Animation;

import com.babylonhx.materials.lib.lava.LavaMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LavaMat {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", Math.PI / 2, Math.PI / 2, 100, Vector3.Zero(), scene);
		camera.attachControl();
		
		// Lights
		var hemisphericLight = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);		
		
		var knot = Mesh.CreateTorusKnot("knot", 10, 3, 128, 64, 2, 3, scene);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		//skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;		
		
		// Lava
		var lava = new LavaMaterial("lava", scene);
		lava.diffuseTexture = new Texture("assets/img/lava/lavatile.jpg", scene);
		lava.noiseTexture = new Texture("assets/img/lava/cloud.png", scene);
		cast(lava.diffuseTexture, Texture).uScale = 0.5;
		cast(lava.diffuseTexture, Texture).vScale = 0.5;		
		lava.fogColor = Color3.Black();
		//lava.speed = 2.5;	
		
		knot.material = lava;
		
		// Register a render loop to repeatedly render the scene
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
