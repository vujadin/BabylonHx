package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.lib.sky.SkyMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.animations.Animation;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SkyMaterialTest {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(5, 4, -47), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		// Light
		var light = new HemisphericLight("light", new Vector3(0, 1, 0), scene);
		
		// Ground
		var ground = Mesh.CreateGroundFromHeightMap("ground", "assets/img/heightMap.png", 100, 100, 100, 0, 10, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/ground.jpg", scene);
		untyped groundMaterial.diffuseTexture.uScale = 6;
		untyped groundMaterial.diffuseTexture.vScale = 6;
		groundMaterial.specularColor = new Color3(0, 0, 0);
		ground.position.y = -2.05;
		ground.material = groundMaterial;
		
		// Sky material
		var skyboxMaterial = new SkyMaterial("skyMaterial", scene);
		skyboxMaterial.backFaceCulling = false;

		// Sky mesh (box)
		var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		skybox.material = skyboxMaterial;
		
		/*
		* Keys:
		* - 1: Day
		* - 2: Evening
		* - 3: Increase Luminance
		* - 4: Decrease Luminance
		* - 5: Increase Turbidity
		* - 6: Decrease Turbidity
		*/
		var setSkyConfig = function (property, from, to) {
			var keys = [
				{ frame: 0, value: from },
				{ frame: 100, value: to }
			];
			
			var animation = new Animation("animation", property, 100, Animation.ANIMATIONTYPE_FLOAT, Animation.ANIMATIONLOOPMODE_CONSTANT);
			animation.setKeys(keys);
			
			scene.stopAnimation(skybox);
			scene.beginDirectAnimation(skybox, [animation], 0, 100, false, 1);
		};
		
		Engine.keyDown.push(function (keyCode:Int) {
			switch (keyCode) {
				case 49: setSkyConfig("material.inclination", skyboxMaterial.inclination, 0); // 1
				case 50: setSkyConfig("material.inclination", skyboxMaterial.inclination, -0.5);  // 2
				
				case 51: setSkyConfig("material.luminance", skyboxMaterial.luminance, 0.1);  // 3
				case 52: setSkyConfig("material.luminance", skyboxMaterial.luminance, 1.0);  // 4
				
				case 53: setSkyConfig("material.turbidity", skyboxMaterial.turbidity, 40);  // 5
				case 54: setSkyConfig("material.turbidity", skyboxMaterial.turbidity, 5);  // 6
			}
		});
		
		// Set to Day
		setSkyConfig("material.inclination", skyboxMaterial.inclination, 0);
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
