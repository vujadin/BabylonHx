package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.lib.fire.FireMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.math.Tools;
import com.babylonhx.animations.Animation;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FireMat {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 4, 30, new Vector3(0, 4, 0), scene);
		camera.attachControl();
		
		// Light
		var light = new SpotLight("light", new Vector3(8, 16, 8), new Vector3(-1, -2, -1), 3, 1, scene);
		var shadowGenerator = new ShadowGenerator(512, light);
		shadowGenerator.useBlurCloseExponentialShadowMap = true;
		shadowGenerator.blurBoxOffset = 1;
		shadowGenerator.blurScale = 1;
		shadowGenerator.setDarkness(0.0);
		
		var rootMesh = new Mesh("root", scene);
		rootMesh.scaling = new Vector3(4, 4, 4);
		
		// Fire light, simulates the fire intensity
		var light2 = new PointLight("light2", new Vector3(0, 10, 0), scene);
		light2.diffuse = new Color3(1.0, 0.5, 0.0);
		light2.parent = rootMesh;
		
		var keys:Array<Dynamic> = [];
		var previous:Float = Math.NEGATIVE_INFINITY;
		for (i in 0...20) {
			var rand = Tools.Clamp(Math.random(), 0.5, 1.0);
			
			if (previous != Math.NEGATIVE_INFINITY) {
				if (Math.abs(rand - previous) < 0.1) {
					continue;
				}
			}
			
			previous = rand;
			
			keys.push({
				frame: i,
				value: rand
			});
		}
		
		var anim = new Animation("anim", "intensity", 1, Animation.ANIMATIONTYPE_FLOAT, Animation.ANIMATIONLOOPMODE_CYCLE);
		anim.setKeys(cast keys);
		
		light2.animations.push(anim);
		scene.beginAnimation(light2, 0, keys.length, true, 8);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 300.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/santa", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		
		// Fire material
		var fireMaterial = new FireMaterial("fire", scene);
		fireMaterial.diffuseTexture = new Texture("assets/img/fire/diffuse.png", scene);
		fireMaterial.distortionTexture = new Texture("assets/img/fire/distortion.png", scene);
		fireMaterial.opacityTexture = new Texture("assets/img/fire/opacity.png", scene);
		fireMaterial.opacityTexture.level = 0.5;
		fireMaterial.speed = 5.0;
		
		// Load candle 3D Model		
		//SceneLoader.ImportMesh("", "assets/models/", "candle.babylon", scene, function(meshes:Array<AbstractMesh>, ps, sks) {
			//var plane = scene.getMeshByName("Plane");
			//plane.receiveShadows = true;
			//
			//for (i in 0...meshes.length) {
				//if (meshes[i] != plane) {
					//shadowGenerator.getShadowMap().renderList.push(meshes[i]);
					//meshes[i].receiveShadows = false;
				//}
				//
				//if (meshes[i].parent == null) {
					//meshes[i].parent = rootMesh;
				//}
			//}
			
			// Create the fire plane (billboarded on Y)
			var plane = Mesh.CreatePlane("firePlane", 1.5, scene);
			plane.position = new Vector3(0, 8.3, 0);
			plane.scaling.x = 0.45;
			plane.scaling.y = 1.5;
			plane.billboardMode = AbstractMesh.BILLBOARDMODE_Y;
			plane.material = fireMaterial;
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		//});
	}
	
}
