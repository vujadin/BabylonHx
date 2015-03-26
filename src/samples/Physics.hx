package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
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
class Physics {

	public function new(scene:Scene) {
		scene.enablePhysics(new Vector3(0, -10, 0), new OimoPlugin());
		
		// Skybox
		/*var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;*/
		
		/** CAMERA **/
		var camera = new ArcRotateCamera("Camera", 0.86, 1.37, 250, Vector3.Zero(), scene);
		camera.attachControl(this);
		camera.maxZ = 50000;
		/*camera.lowerRadiusLimit = 120;
		camera.upperRadiusLimit = 430;
		camera.lowerBetaLimit = 0.75;
		camera.upperBetaLimit = 1.58;*/
		
		/** SUN LIGHT **/
		new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		/** GROUND **/
		var mat = new StandardMaterial("ground", scene);
		//var texDiff = new Texture("assets/img/dirt.jpg", scene);
		//texDiff.uScale = texDiff.vScale = 15;
		//mat.diffuseTexture = texDiff;
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
		var y = 50;
		
		// all our objects
		var objects:Array<Mesh> = [];
		
		// max number of objects
		var max = 100;
		
		// Creates a random position above the ground
		var getPosition = function(y:Float):Vector3 {
			return new Vector3(randomNumber(-200, 200), y, randomNumber( -200, 200));
		};
		
		// Create objects
		for (index in 0...max) {
			
			// SPHERES
			var s = Mesh.CreateSphere("s", 30, randomNumber(20, 30), scene);
			s.position = getPosition(y);
			var matSphere = new StandardMaterial("boxmat", scene);
			matSphere.diffuseColor = Color3.FromInts(175, 71, 89);
			matSphere.specularColor = Color3.Yellow();
			s.material = matSphere;
			physOpt = new PhysicsBodyCreationOptions();
			physOpt.mass = 1;
			physOpt.friction = 0.5;
			physOpt.restitution = 0.5;
			s.setPhysicsState(PhysicsEngine.SphereImpostor, physOpt);
			
			// BOXES
			var d = Mesh.CreateBox("s", randomNumber(10, 20), scene);
			d.position = getPosition(y);
			d.material = matSphere;
			/*var shaderBox = new ShaderMaterial("gradient", scene, {
				vertexElement: ShadersStore.Shaders.get("skysphere.vertex"),
				fragmentElement: ShadersStore.Shaders.get("skysphere.fragment")
			}, { });
			shaderBox.setFloat("offset", 10);
			shaderBox.setFloat("exponent", 1.0);
			shaderBox.setColor3("topColor", Color3.FromInts(129, 121, 153));
			shaderBox.setColor3("bottomColor", Color3.FromInts(161, 152, 191));
			d.material = shaderBox;*/
			
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
				if (obj.position.y < -100) {
					obj.position = getPosition(200);
	                //obj.updateBodyPosition();
				}
			}
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
