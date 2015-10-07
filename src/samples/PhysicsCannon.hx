package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.plugins.CannonPlugin;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PhysicsCannon {

	public function new(scene:Scene) {
		scene.enablePhysics(new Vector3(0, -200, 0), new CannonPlugin());
		
		var camera = new ArcRotateCamera("Camera", 0.86, 1.37, 450, Vector3.Zero(), scene);
		camera.attachControl(this);
		camera.maxZ = 50000;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
				
		var mat = new StandardMaterial("ground", scene);
		var texDiff = new Texture("assets/img/wood.jpg", scene);
		texDiff.uScale = texDiff.vScale = 5;
		mat.diffuseTexture = texDiff;
		mat.specularColor = Color3.Black();
		
		var g = Mesh.CreateBox("ground", 400, scene);
		g.position.y = -30;
		g.scaling.y = 0.01;
		g.material = mat;
		var physOpt = new PhysicsBodyCreationOptions();
		physOpt.mass = 0;
		g.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var b1 = Mesh.CreateBox("b1", 50, scene);
		b1.position.x = -10;
		b1.material = mat;
		b1.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var b11 = Mesh.CreateBox("b1", 40, scene);
		b11.position.x = -100;
		b11.scaling.y = 3;
		b11.position.y = 30;
		b11.material = mat;
		b11.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var b111 = Mesh.CreateBox("b1", 200, scene);
		b111.position.z = -180;
		b111.scaling.y = 0.03;
		b111.scaling.z = 0.5;
		b111.position.y = 80;
		b111.rotation.x = Math.PI / 5;
		b111.material = mat;
		b111.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var b2 = Mesh.CreateBox("b2", 400, scene);
		b2.position.z = -200;
		b2.scaling.z = 0.01;
		b2.scaling.y = 0.15;
		b2.material = mat;
		b2.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var b3 = Mesh.CreateBox("b2", 400, scene);
		b3.position.z = 200;
		b3.scaling.z = 0.01;
		b3.scaling.y = 0.15;
		b3.material = mat;
		b3.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var b4 = Mesh.CreateBox("b2", 400, scene);
		b4.position.x = 200;
		b4.scaling.x = 0.01;
		b4.scaling.y = 0.15;
		b4.material = mat;
		b4.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var b5 = Mesh.CreateBox("b2", 400, scene);
		b5.position.x = -200;
		b5.scaling.x = 0.01;
		b5.scaling.y = 0.15;
		b5.material = mat;
		b5.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		// Get a random number between two limits
		var randomNumber = function (min:Float, max:Float) {
			if (min == max) {
				return (min);
			}
			var random = Math.random();
			return Std.int((random * (max - min)) + min);
		};
		
		// Initial height
		var y = 50;
		
		// all our objects
		var objects:Array<Mesh> = [];
		
		// max number of objects
		var max = 20;
		
		// Creates a random position above the ground
		var getPosition = function(y:Float):Vector3 {
			return new Vector3(randomNumber(-200, 200), y, randomNumber(-200, 200));
		};
		
		
		var materialAmiga = new StandardMaterial("ball", scene);
		materialAmiga.diffuseTexture = new Texture("assets/img/rust.jpg", scene);
		materialAmiga.emissiveColor = new Color3(0.5, 0.5, 0.5);
		materialAmiga.diffuseTexture.uScale = 5;
		materialAmiga.diffuseTexture.vScale = 5;
		
		var materialCrate = new StandardMaterial("crate", scene);
		materialCrate.diffuseTexture = new Texture("assets/img/crate.png", scene);
		
		// Create objects
		for (index in 0...max) {
			
			// SPHERES
			var s = Mesh.CreateSphere("s", 30, randomNumber(20, 50), scene);
			s.position = getPosition(y + 250);
			s.material = materialAmiga;
			physOpt = new PhysicsBodyCreationOptions();
			physOpt.mass = 1;
			physOpt.friction = 0.5;
			physOpt.restitution = 0.5;
			s.setPhysicsState(PhysicsEngine.SphereImpostor, physOpt);
			
			// BOXES
			var d = Mesh.CreateBox("b", randomNumber(10, 30), scene);
			d.position = getPosition(y);
			d.position.y += 400;
			d.material = materialCrate;
			
			d.rotation.x = randomNumber( -Math.PI / 2, Math.PI / 2);
			d.rotation.y = randomNumber( -Math.PI / 2, Math.PI / 2);
			d.rotation.z = randomNumber( -Math.PI / 2, Math.PI / 2);
			d.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
			
			// SAVE OBJECT
			objects.push(s);
			objects.push(d);
			
			// INCREMENT HEIGHT
			y += 10;
		}
		
		
		
		
		
		/*var camera = new ArcRotateCamera("Camera", 0.86, 1.80, 650, new Vector3(0, 150, 0), scene);
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
		materialBox.diffuseTexture = new Texture("assets/img/wood.jpg", scene);
		//materialBox.bumpTexture = new Texture("assets/img/woodbump.jpg", scene);
		
		var materialSphere = new StandardMaterial("sphere", scene);
		materialSphere.diffuseTexture = new Texture("assets/img/rust.jpg", scene);
		materialSphere.bumpTexture = new Texture("assets/img/rustbump.jpg", scene);
		
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
				
		var height = 20;
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
		}*/
		
		
		
						
		/*var camera = new ArcRotateCamera("Camera", 0.95, 1.4, 1800, new Vector3(0, 150, 0), scene);
		camera.attachControl(this);
		camera.maxZ = 50000;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 5), scene);
		
		var skybox = Mesh.CreateBox("skyBox", 50000.0, scene);
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
		mat.diffuseTexture = texDiff;
		mat.specularColor = Color3.Black();
		
		var materialBox = new StandardMaterial("box", scene);
		materialBox.diffuseTexture = new Texture("assets/img/wood.jpg", scene);
		materialBox.bumpTexture = new Texture("assets/img/woodbump.jpg", scene);
		materialBox.specularPower = 500;
		
		var materialSphere = new StandardMaterial("sphere", scene);
		materialSphere.diffuseTexture = new Texture("assets/img/rust.jpg", scene);
		materialSphere.bumpTexture = new Texture("assets/img/rustbump.jpg", scene);
		
		var g = Mesh.CreateBox("ground", 1500, scene);
		g.position.y = -30;
		g.scaling.y = 0.01;
		g.material = mat;
		var physOpt = new PhysicsBodyCreationOptions();
		physOpt.mass = 0;
		g.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var gg = Mesh.CreateBox("gg", 400, scene);
		gg.rotation.x = Math.PI / 5;
		gg.position.z = -1000;
		gg.position.y = 100;
		gg.scaling.y = 0.05;
		gg.material = mat;
		gg.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var ggg = Mesh.CreateBox("ggg", 280, scene);
		ggg.position.z = 800;
		ggg.position.y = 100;
		ggg.scaling.z = 0.05;
		ggg.material = mat;
		ggg.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
		
		var s = Mesh.CreateSphere("s", 30, 220, scene);
		s.position.y = 2000;
		s.position.z = -750;
		s.material = materialSphere;
		physOpt = new PhysicsBodyCreationOptions();
		physOpt.mass = 85;
		physOpt.friction = 0.5;
		physOpt.restitution = 0.5;
		s.setPhysicsState(PhysicsEngine.SphereImpostor, physOpt);
						
		physOpt.mass = 1;
		physOpt.friction = 0.4;
		physOpt.restitution = 0.2;
		
		var height = 12;
		var depth = 1;
		var sx = 60;
		var sy = 40;
		var sz = 60;
		var px:Float = 0;
		var py:Float = 0;
		var pz:Float = 0;
		
		for (i in 0...height) {
			for (j in i...height) {
				for (k in 0...depth) {
					px = (j - i * 0.5 - (height - 1) * 0.5) * (sx * 1.05);
					py = i * (sy + 0.01) + sy * 0.6;
					pz = (k - (sz - 1) * 0.5) + (k * sz);
					
					var box = Mesh.CreateBox("b" + (j + i), 39, scene);
					box.material = materialBox;
					
					box.position = new Vector3(px, i * (sz * 0.667), pz);
					box.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
				}
			}
		}*/
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
