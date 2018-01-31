package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.Animation.BabylonFrame;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AnimatedParticles {

	public function new(scene:Scene) {
		var light0 = new PointLight("Omni", new Vector3(0, 2, 8), scene);
		var camera = new ArcRotateCamera("ArcRotateCamera", 1, 0.8, 20, new Vector3(0, 0, 0), scene);
		camera.attachControl();
		
		// Fountain object
		var fountain = Mesh.CreateBox("foutain", 1.0, scene);
		
		// Ground
		var ground = Mesh.CreatePlane("ground", 50.0, scene);
		ground.position = new Vector3(0, -10, 0);
		ground.rotation = new Vector3(Math.PI / 2, 0, 0);
		
		ground.material = new StandardMaterial("groundMat", scene);
		ground.material.backFaceCulling = false;
		untyped ground.material.diffuseColor = new Color3(0.3, 0.3, 1);
		
		var particleSystem = new ParticleSystem("particles", 2000, scene, null, true);
		particleSystem.particleTexture = new Texture("assets/img/player.png", scene, true, false, Texture.TRILINEAR_SAMPLINGMODE);
		
		particleSystem.startSpriteCellID = 0;
		particleSystem.endSpriteCellID = 44;
		particleSystem.spriteCellHeight = 64;
		particleSystem.spriteCellWidth = 64;
		particleSystem.spriteCellLoop = true;
		
		// Where the particles come from
		particleSystem.emitter = fountain; // the starting object, the emitter
		particleSystem.minEmitBox = new Vector3(-1, 0, 0); // Starting all from
		particleSystem.maxEmitBox = new Vector3(1, 0, 0); // To...
		
		// Size of each particle (random between...
		particleSystem.minSize = .5;
		particleSystem.maxSize = 1;
		
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
		particleSystem.updateSpeed = 0.001;
		
		// Start the particle system
		particleSystem.start();
		
		// Fountain's animation
		var keys:Array<BabylonFrame> = [];
		var animation = new Animation("animation", "rotation.x", 30, Animation.ANIMATIONTYPE_FLOAT, Animation.ANIMATIONLOOPMODE_CYCLE);
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
