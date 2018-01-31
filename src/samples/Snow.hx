package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Snow {

	public function new(scene:Scene) {
		// Lights
		var light0 = new DirectionalLight("Omni", new Vector3(-2, -5, 2), scene);
		var light1 = new PointLight("Omni", new Vector3(2, -5, -2), scene);
		
		// Need a free camera for collisions
		var camera = new FreeCamera("FreeCamera", new Vector3(0, -8, -20), scene);
		camera.attachControl();
		
	    // Create a particle system
		var particleSystem = new ParticleSystem("particles", 5000, scene);
		particleSystem.emitter = Mesh.CreateBox("emitter", 0.01, scene);
		
		// Texture of each particle
		particleSystem.particleTexture = new Texture("assets/img/snowflake.jpg", scene);
		
		// Emitter position & area of emitting
		particleSystem.emitter.position = new Vector3(0, 10, 0);
		particleSystem.minEmitBox = new Vector3(10, 0, 10); // Starting all from
		particleSystem.maxEmitBox = new Vector3( -10, 0, -10); // To...
		
		// Colors of all particles
		particleSystem.color1 = new Color4(1.0, 1.0, 1.0, 1.0);
		particleSystem.color2 = new Color4(1.0, 1.0, 1.0, 1.0);
		particleSystem.colorDead = new Color4(0.2, 0.2, 0.2, 0.01);
		
		// Size of each particle (random between...
		particleSystem.minSize = 0.01;
		particleSystem.maxSize = 0.2;
		
		// Life time of each particle (random between...
		particleSystem.minLifeTime = 5;
		particleSystem.maxLifeTime = 50;
		
		// Emission rate
		particleSystem.emitRate = 500;
		
		// Blend mode : BLENDMODE_ONEONE, or BLENDMODE_STANDARD
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		
		// Set the gravity of all particles
		particleSystem.gravity = new Vector3(0, -4.905, 0);
		
		// Direction of each particle after it has been emitted
		particleSystem.direction1 = new Vector3(-50, 1, 50);
		particleSystem.direction2 = new Vector3(50, -1, -50);
		
		// Angular speed, in radians
		particleSystem.minAngularSpeed = 0.01;
		particleSystem.maxAngularSpeed = Math.PI / 2;
		
		// Speed
		particleSystem.minEmitPower = 0.5;
		particleSystem.maxEmitPower = 1;
		particleSystem.updateSpeed = 0.0125;
		
		// Start the particle system
		particleSystem.start();
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
