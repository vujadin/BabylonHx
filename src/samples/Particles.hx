package samples;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.Animation.BabylonFrame;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles {

	public function new(scene:Scene) {
		// Setup environment
		var light0 = new PointLight("Omni", new Vector3(0, 2, 8), scene);
		var camera = new ArcRotateCamera("ArcRotateCamera", 1, 0.8, 20, new Vector3(0, 0, 0), scene);
		camera.attachControl(this, true);
		
		// Fountain object
		var fountain = Mesh.CreateBox("foutain", 1.0, scene);
				
		// Create a particle system
		var particleSystem = new ParticleSystem("particles", 2000, scene);
		
		//Texture of each particle
		particleSystem.particleTexture = new Texture("assets/img/flare.png", scene);
		
		// Where the particles come from
		particleSystem.emitter = fountain; // the starting object, the emitter
		particleSystem.minEmitBox = new Vector3(-1, 0, 0); // Starting all from
		particleSystem.maxEmitBox = new Vector3(1, 0, 0); // To...
		
		// Colors of all particles
		particleSystem.color1 = new Color4(0.7, 0.8, 1.0, 1.0);
		particleSystem.color2 = new Color4(0.2, 0.5, 1.0, 1.0);
		particleSystem.colorDead = new Color4(0, 0, 0.2, 0.0);
		
		// Size of each particle (random between...
		particleSystem.minSize = 0.1;
		particleSystem.maxSize = 0.5;
		
		// Life time of each particle (random between...
		particleSystem.minLifeTime = 0.3;
		particleSystem.maxLifeTime = 1.5;
		
		// Emission rate
		particleSystem.emitRate = 1500;
		
		// Blend mode : BLENDMODE_ONEONE, or BLENDMODE_STANDARD
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		
		// Set the gravity of all particles
		particleSystem.gravity = new Vector3(0, -9.81, 0);
		
		// Direction of each particle after it has been emitted
		particleSystem.direction1 = new Vector3(-7, 8, 3);
		particleSystem.direction2 = new Vector3(7, 8, -3);
		
		// Angular speed, in radians
		particleSystem.minAngularSpeed = 0;
		particleSystem.maxAngularSpeed = Math.PI;
		
		// Speed
		particleSystem.minEmitPower = 1;
		particleSystem.maxEmitPower = 3;
		particleSystem.updateSpeed = 0.005;
		
		// Start the particle system
		particleSystem.start();
		
		// Fountain's animation
		var keys:Array<BabylonFrame> = [];
		var animation = new Animation("animation", "rotation.x", 30, Animation.ANIMATIONTYPE_FLOAT,
																		Animation.ANIMATIONLOOPMODE_CYCLE);
		// At the animation key 0, the value of scaling is "1"
		keys.push({
			frame: 0,
			value: 0
		});
		
		// At the animation key 50, the value of scaling is "0.2"
		keys.push({
			frame: 50,
			value: Math.PI
		});
		
		// At the animation key 100, the value of scaling is "1"
		keys.push({
			frame: 100,
			value: 0
		});
		
		// Launch animation
		animation.setKeys(keys);
		fountain.animations.push(animation);
		scene.beginAnimation(fountain, 0, 100, true);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
