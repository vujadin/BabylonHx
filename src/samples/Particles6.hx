package samples;

import com.babylonhx.animations.Animation;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles6 {
	
	var whereNow = 0;
	var freezeWhen = 1500;
	var domeRadius = 50;
	var ps:ParticleSystem;

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0, 0, 0, 1);
		
		var camera = new ArcRotateCamera("Camera", -1.05, 1.1, 200, new Vector3(0, 15, 0), scene);
		camera.attachControl();
		
		var light = new HemisphericLight("fred", new Vector3(0, 1, 0), scene);
		
		ps = new ParticleSystem("particles", 10000, scene);
		
		ps.updateFunction = updateFunction;
		ps.startPositionFunction = startPositionFunction;
		
		// Texture of each particle - set far below
		// ps.particleTexture = new Texture("textures/star.jpg", scene);
		ps.particleTexture = new Texture("assets/img/star.jpg", scene);
		
		// Where the particles come from
		// ps.emitter = box; // the starting object, the emitter
		ps.emitter = new Vector3(0, 15, 0);
		// ps.minEmitBox = new Vector3(-15, 0, -15); // Starting all from
		// ps.maxEmitBox = new Vector3(15, 0, 15); // To...
		
		ps.minEmitBox = new Vector3(1, 0, 0); // Starting all from
		ps.maxEmitBox = new Vector3( -1, 0, 0); // To...
		
		// the localized _update does the coloring.
		ps.color1 = ps.color2 = ps.colorDead = new Color4(1, 1, 1, 1);
		
		// the sizing.
		ps.minSize = 1;
		ps.maxSize = 3;
		
		// Life time of each particle (random between...
		ps.minLifeTime = 100.0;
		ps.maxLifeTime = 100.0;
		
		// Emission rate
		ps.emitRate = 5000;
		
		// Blend mode : BLENDMODE_ONEONE, or BLENDMODE_STANDARD
		ps.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		
		// Set the gravity of all particles
		// ps.gravity = new Vector3(0, -9.81, 0);
		
		// Direction of each particle after it has been emitted
		// ps.direction1 = new Vector3(-.5, -.5, 1);
		// ps.direction2 = new Vector3(.5, .5, 1);
		
		// ps.direction1 = new Vector3(-.5, 1, -.5);
		// ps.direction2 = new Vector3(.5, 1, .5);
		
		// Angular speed, in radians
		ps.minAngularSpeed = 0;
		// ps.maxAngularSpeed = Math.PI*2;
		ps.maxAngularSpeed = 0;
		
		// Speed
		ps.minEmitPower = 0;
		ps.maxEmitPower = 0;
		ps.updateSpeed = 0.005;
		
		// Start the particle system
		ps.start();
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
	function randomNumber(min:Float, max:Float):Float {
		if (min == max) {
			return min;
		}
		var random = Math.random();
		return ((random * (max - min)) + min);
	}

	// -------------------------------------------------------------------------------------------------
	// Wingy's default positions
	function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, _) {
		var  r= 50;
		var v3 = getCart(domeRadius);
		Vector3.TransformCoordinatesFromFloatsToRef(v3.x * r, v3.z * r, v3.y * r, worldMatrix, positionToUpdate);
	}

	// -------------------------------------------------------------------------------------------------

	function updateFunction(particles:Array<Particle>) {
		var index:Int = 0;
		while (index < particles.length) {
			var particle = particles[index];
			particle.age += ps._scaledUpdateSpeed;
			if (particle.age >= particle.lifeTime) {
				ps.recycleParticle(particle);
				index--;
				continue;
			}
			else {
				particle.color = new Color4(Math.random() * 2, Math.random() * 2, Math.random() * 2, 1);
				// particle.colorStep.scaleToRef(_this._scaledUpdateSpeed, _this._scaledColorStep);
				// particle.color.addInPlace(_this._scaledColorStep);
				// if (particle.color.a < 0)
					// particle.color.a = 0;
				// particle.angle += particle.angularSpeed * _this._scaledUpdateSpeed;
				// particle.direction.scaleToRef(_this._scaledUpdateSpeed, _this._scaledDirection);
				// particle.position.addInPlace(_this._scaledDirection);
				// _this.gravity.scaleToRef(_this._scaledUpdateSpeed, _this._scaledGravity);
				// particle.direction.addInPlace(_this._scaledGravity);
			}
			++index;
		}
	};

	// -----------------------------------------------------------------------
	// a gruesome stolen func - thx to...
	// https://rbrundritt.wordpress.com/2008/10/14/conversion-between-spherical-and-cartesian-coordinates-systems/
	function getCart(radius:Float) {	  
		var x = Math.random() * 3 + Math.random() * ( -3);
		var y = Math.random() * 3 + Math.random() * ( -3);
		var z = Math.random() * 3 + Math.random() * ( -3);
		
		if (Math.pow((Math.pow(x, 2) + 9 / 4 * Math.pow(y, 2) + Math.pow(z, 2) - 1), 3) - Math.pow(x, 2) * Math.pow(z, 3) - 9 / 80 * Math.pow(y, 2) * Math.pow(z, 3) < 0){
		   return new Vector3(x,y,z);
		}
		else {
		   return getCart(radius);
		}		
	}

	// -----------------------------------------------------------------------
	// a stolen formula - claims to eliminate polar bias (clustering near poles)
	// in use - thx to http://rectangleworld.com/blog/archives/298
	function plot1():Array<Float> {
		var theta = Math.random() * 2 * Math.PI;
		var phi = Math.acos(Math.random() * 2 - 1);
		return [theta, phi];
	};
	
}
