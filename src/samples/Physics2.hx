package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import com.babylonhx.physics.plugins.OimoPlugin;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.physics.PhysicsEngine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Physics2 {

	public function new(scene:Scene) {
		scene.enablePhysics(new Vector3(0, -2, 0), new OimoPlugin());
						
		var camera = new ArcRotateCamera("Camera", 0.88, 0.88, 600, Vector3.Zero(), scene);
		camera.attachControl(this);
		camera.maxZ = 50000;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		new Layer("background", "assets/img/graygrad.jpg", scene, true);
				
		var mat = new StandardMaterial("ground", scene);
		var texDiff = new Texture("assets/img/wood2.jpg", scene);
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
		
		// Get a random number between two limits
		var randomNumber = function (min:Float, max:Float) {
			if (min == max) {
				return (min);
			}
			var random = Math.random();
			return Std.int((random * (max - min)) + min);
		};
		
		// Initial height
		var y = 300;
		
		// all our objects
		var objects:Array<Mesh> = [];
		
		// max number of objects
		var max = 50;
		
		// Creates a random position above the ground
		var getPosition = function(y:Float):Vector3 {
			return new Vector3(randomNumber(-200, 200), y, randomNumber(-200, 200));
		};		
		
		var materialBall = new StandardMaterial("ball", scene);
		materialBall.diffuseTexture = new Texture("assets/img/metal.jpg", scene);
		materialBall.emissiveColor = new Color3(0.5, 0.5, 0.5);
		materialBall.diffuseTexture.uScale = 5;
		materialBall.diffuseTexture.vScale = 5;
		
		var materialCrate = new StandardMaterial("crate", scene);
		materialCrate.diffuseTexture = new Texture("assets/img/crate.jpg", scene);
		
		// Create objects
		for (index in 0...max) {
			
			// SPHERES
			var s = Mesh.CreateSphere("s", 30, randomNumber(20, 50), scene);
			s.position = getPosition(y);
			s.material = materialBall;
			physOpt = new PhysicsBodyCreationOptions();
			physOpt.mass = 1;
			physOpt.friction = 0.5;
			physOpt.restitution = 0.5;
			s.setPhysicsState(PhysicsEngine.SphereImpostor, physOpt);
			
			// BOXES
			var d = Mesh.CreateBox("b", randomNumber(10, 30), scene);
			d.position = getPosition(y);
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
				
		scene.registerBeforeRender(function() {
			for(obj in objects) {
				// If object falls
				if (obj.position.y < -200) {
					obj.position = getPosition(y);
					obj.updatePhysicsBodyPosition();					
				}
			}
		});
				
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}