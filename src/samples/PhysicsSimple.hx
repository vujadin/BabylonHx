package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.physics.plugins.OimoPlugin;
import com.babylonhx.Scene;
import com.babylonhx.physics.PhysicsEngine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PhysicsSimple {

	public function new(scene:Scene) {
		scene.enablePhysics(new Vector3(0, -1, 0), new OimoPlugin());
						
		var camera = new ArcRotateCamera("Camera", 0.86, 1.80, 650, new Vector3(0, 150, 0), scene);
		camera.position = new Vector3(200, 0, 0);
		camera.attachControl(this);
		camera.maxZ = 100000;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
				
		var mat = new StandardMaterial("ground", scene);
		var texDiff = new Texture("assets/img/ground.jpg", scene);
		texDiff.uScale = texDiff.vScale = 30;
		mat.diffuseTexture = texDiff;
		mat.specularColor = Color3.Black();
				
		var materialBox = new StandardMaterial("box", scene);
		materialBox.diffuseTexture = new Texture("assets/img/wood2.jpg", scene);
		
		var materialSphere = new StandardMaterial("sphere", scene);
		materialSphere.diffuseTexture = new Texture("assets/img/metal.jpg", scene);
		
		var g = Mesh.CreateBox("ground", 1000, scene);
		g.position.y = -10;
		g.scaling.y = 0.01;
		g.material = mat;
		var physOpt = new PhysicsBodyCreationOptions();
		physOpt.mass = 0;
		g.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var s = Mesh.CreateSphere("s", 20, 80, scene);
		s.material = materialSphere;
		s.position.y = 1000;
		physOpt = new PhysicsBodyCreationOptions();
		physOpt.mass = 0.5;
		physOpt.friction = 0.2;
		physOpt.restitution = 0.2;
		s.setPhysicsState(PhysicsEngine.SphereImpostor, physOpt);
				
		var height = 40;
		var radius = 32;
		var sz = 40;
		var sy = sz * 0.15;
		var px:Float = 0;
		var py:Float = 0;
		var pz:Float = 0;
		var angle:Float = 0;
		var rad:Float = 0;
		
		physOpt.mass = 0.2;
		physOpt.friction = 0.1;
		physOpt.restitution = 0.1;
		
		var boxOriginal:Mesh = null;
		for (j in 0...height) {
			for (i in 0...5) {
				rad = radius;
				angle = (Math.PI * 2 / 5 * (i + j * 0.5));
				px = Math.cos(angle) * rad;
				py = (sy * 0.5) + j * sy;
				pz = -Math.sin(angle) * rad;
				
				var box = Mesh.CreateBox("b" + (j + i), sz, scene);
				//var box = boxOriginal == null ? Mesh.CreateBox("b" + (j + i), sz, scene) : boxOriginal.createInstance("b_inst_" + (i + j));
				box.material = materialBox;
				box.scaling.x = 0.15;
				box.scaling.y = 0.15;
				
				box.position = new Vector3(px, j * (sz * 0.135), pz);
				box.rotation = new Vector3(0, angle, 0);
				box.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
			}
		}
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
