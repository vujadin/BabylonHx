package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.Engine;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
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
import com.babylonhx.physics.plugins.CannonPlugin;

import com.babylonhx.Scene;
import com.babylonhx.physics.PhysicsEngine;
import haxe.Timer;

import oimohx.physics.dynamics.World;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Physics_Pyramid {
	
	var lastKey:Int = 0;

	public function new(scene:Scene) {
				
		scene.enablePhysics(new Vector3(0, -290, 0), new CannonPlugin());
						
		var camera = new ArcRotateCamera("Camera", 0.95, 1.4, 1800, new Vector3(0, 150, 0), scene);
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
		var texDiff = new Texture("assets/img/grass.jpg", scene);
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
		s.position.z = -1000;
		s.material = materialSphere;
		physOpt = new PhysicsBodyCreationOptions();
		physOpt.mass = 125;
		physOpt.friction = 0.5;
		physOpt.restitution = 0.5;
		s.setPhysicsState(PhysicsEngine.SphereImpostor, physOpt);
		
		camera.target = s;
						
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

		//com.babylonhx.tools.Tools.delay(function() {
			for (i in 0...height) {
				for (j in i...height) {
					for (k in 0...depth) {
						px = (j - i * 0.5 - (height - 1) * 0.5) * (sx * 1.05);
						py = i * (sy + 0.01) + sy * 0.6;
						pz = (k - (sz - 1) * 0.5) + (k * sz);
						
						var box = Mesh.CreateBox("b" + (j + i), sz, scene);
						box.material = materialBox;
						box.scaling.y = 0.667;
						
						box.position = new Vector3(px, i * (sz * 0.667), pz);
						box.setPhysicsState(PhysicsEngine.BoxImpostor, physOpt);
					}
				}
			}
		//}, 1000);
				
		function moveBall(key:Int) {
			switch(key) {
				case 119:	// w
					if(lastKey != key) {
						lastKey = key;
						//s.rigidBody.linearVelocity.scaleEqual(0.8);
						s.rigidBody.angularVelocity.scaleEqual(0.8);
					}
					s.applyImpulse(new Vector3(0, 0, -15), s.position);
					
				case 100: 	// d
					if(lastKey != key) {						
						lastKey = key;
						//s.rigidBody.linearVelocity.scaleEqual(0.6);
						s.rigidBody.angularVelocity.scaleEqual(0.8);
					}
					s.applyImpulse(new Vector3( -15, 0, 0), s.position);
					
				case 115:	// s
					if(lastKey != key) {						
						lastKey = key;
						//s.rigidBody.linearVelocity.scaleEqual(0.8);
						s.rigidBody.angularVelocity.scaleEqual(0.8);
					}
					s.applyImpulse(new Vector3(0, 0, 15), s.position);
					
				case 97:	// a
					if(lastKey != key) {						
						lastKey = key;
						//s.rigidBody.linearVelocity.scaleEqual(0.8);
						s.rigidBody.angularVelocity.scaleEqual(0.8);
					}
					s.applyImpulse(new Vector3(15, 0, 0), s.position);
					
			}
		}
		
		Engine.keyDown.push(moveBall);
						
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
