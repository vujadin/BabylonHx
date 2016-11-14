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

import com.babylonhxext.materials.WaterMaterial;


/**
 * ...
 * @author Krtolica Vujadin
 */

class Water {
	
	var ninja:Mesh;
	var ninjaGravity:Int = 800;
	var ninjaJumpPower:Float = 0;
	var score:Int = 0;
	var scoreText:Dynamic;
	var topScore:Int = 0;
	var powerBar:Dynamic; // Sprite
	var powerTween:Dynamic;
	var placedPoles:Int = 0;
	var minPoleGap:Int = 100;
	var maxPoleGap:Int = 300;
	var ninjaJumping:Bool = false;
	var ninjaFallingDown:Bool = false;
	var jumps:Int = 0;
	var maxExtraJumps:Int = 1;
	
	var player:Mesh;
	var pillar:Mesh;
	var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
		//var camera = new ArcRotateCamera("Camera", 3.15, 1.01, 420, Vector3.Zero(), scene);
		var camera = new FreeCamera("Camera", new Vector3(89, 400, 390), scene);
		camera.rotation = new Vector3(0.26, 3.16, 0);
		//camera.setPosition(new Vector3(50, 50, -50));
		camera.attachControl();
		
		
		// Light directional
		/*var light = new DirectionalLight("dir01", new Vector3(-1, -2, 0), scene);
		light.specular = new Color3(0.05, 0.05, 0.05);
		light.position = new Vector3(30, 50, 5);
		light.intensity = 0.1;*/
		
		var light = new HemisphericLight("hemi", new Vector3(0, -1, 0), scene);
		light.intensity = 3;
		
		var sun = new PointLight("Omni", new Vector3(20, 1110, -150), scene);
		//sun.intensity = 1.8;
		sun.intensity = 0.5;
		
		//var box = Mesh.CreateBox("box", 20, scene);
		
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/ground10.jpg", scene);
		untyped groundMaterial.diffuseTexture.uScale = 22;
		untyped groundMaterial.diffuseTexture.vScale = 22;
		groundMaterial.backFaceCulling = false;
		
		groundMaterial.specularColor = new Color3(0, 0, 0);
		
		var ground = Mesh.CreateGround('ground', 8000, 8000, 1, scene, true);
		ground.position.y = -5;
		ground.material = groundMaterial;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/Sky_FantasySky_Night1_Cam", scene, ["+X.png", "+Y.png", "+Z.png", "-X.png", "-Y.png", "-Z.png"]);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		var waterBumpTex = new Texture("assets/img/waterbump.jpg", scene);
		waterBumpTex.uScale = waterBumpTex.vScale = 12.5;
		waterBumpTex.wrapU = Texture.MIRROR_ADDRESSMODE;
		waterBumpTex.wrapV = Texture.MIRROR_ADDRESSMODE;
		var waterMaterial = new WaterMaterial("water", scene, sun, waterBumpTex);
		waterMaterial.waterFlowSpeed = 0.00007;
		waterMaterial.waterDirection = new Vector2(1.0, 0.0);
		// refraction
		cast(waterMaterial.refractionTexture, RenderTargetTexture).renderList.push(ground);
		// reflection
		cast(waterMaterial.reflectionTexture, RenderTargetTexture).renderList.push(skybox);
		
		var water = Mesh.CreateGround('ground', 8000, 8000, 1, scene, false);
		//water.visibility = 0.5;
		water.material = waterMaterial;
				
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		SceneLoader.ImportMesh("", "assets/models/wizard/", "wizard.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			player = cast newMeshes[0];
			player.scaling = new Vector3(0.2, 0.2, 0.2);
			player.checkCollisions = true;
			
			//camera.target = player.position.clone();
			//camera.target.z -= 500;
			//camera.target.y += 300;
			
			player.rotation.y += Math.PI / 2;
			player.position.x += 200;
			player.position.y += 272;
			
			cast(waterMaterial.reflectionTexture, MirrorTexture).renderList.push(newMeshes[0]);
			
			scene.beginAnimation(newSkeletons[0], 14, 86, true, 0.8);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
			
			scene.getEngine().mouseUp.push(function() {
				trace(camera.position, camera.rotation);
			});
			
			SceneLoader.ImportMesh("", "assets/models/pillar/", "pillar.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
				pillar = cast newMeshes[0];
				pillar.checkCollisions = true;
				
				pillar.scaling = new Vector3(2.2, 2.2, 2.2);
				pillar.position.x += 200;
				pillar.position.y -= 40;
				
				var pillar2 = pillar.createInstance("pillarInst1");
				pillar2.position.x -= 200;
				pillar2.position.y += 50;
			});
		});		
	}
		
}
