package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles3 {
	
	var math = Math;
	var ps:ParticleSystem;

	public function new(scene:Scene) {		
		
		var camera = new ArcRotateCamera("cam", -1.57079633, 1.57079633, 5, new Vector3(0, 0, 0), scene);
		camera.attachControl(this, true);
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = 0.7;
		
		var color1 = new Color4(0, 0.5, 0, 0.5);
		var color2 = new Color4(0, 0.2, 0.3, 0.5);
		var colorDead = new Color4(0, 0.5, 0, 0.1);	
		
		function createPs(emitter:Vector3, particleSystem:ParticleSystem, color1:Color4, color2:Color4, colorDead:Color4) {		
			ps = particleSystem;
			ps.particleTexture = new Texture("assets/img/flare.png", scene);
			
			ps.minSize = 0.1;
			ps.maxSize = 0.1;
			ps.minLifeTime = Math.POSITIVE_INFINITY;
			ps.maxLifeTime = Math.NEGATIVE_INFINITY;
			ps.minEmitPower = 2;
			ps.maxEmitPower = 2;
						
			ps.minAngularSpeed = 0;
			ps.maxAngularSpeed = Math.PI;
			
			ps.emitter = emitter;
			
			ps.emitRate = 360;
			ps.updateSpeed = 0.02;
			ps.blendMode = ParticleSystem.BLENDMODE_ONEONE;
					
			ps.color1 = color1;
			ps.color2 = color2;
			ps.colorDead = colorDead;
					
			ps.direction1 = new Vector3(0, 1, 0);
			ps.direction2 = new Vector3(0, 1, 0);
			ps.minEmitBox = new Vector3(0, 0, 0);
			ps.maxEmitBox = new Vector3(0, 0, 0);
			
			ps.updateFunction = update;
			
			ps.start();
		}
		
		var numParts = 10000;
		createPs(Vector3.Zero(), new ParticleSystem("ps1", numParts, scene), color1, color2, colorDead);
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
	inline function update(particles:Array<Particle>) {
		for (index in 0...particles.length) {
			var particle = particles[index];
			particle.age += ps._scaledUpdateSpeed;
			
			var v = math.PI * (index) / 60 + particle.age;
			var t = math.cos(index) * 2 - 1;
			var halfT = t / 2;
			var halfTcosHalfV = halfT * math.cos(v / 2);
			var cosV = math.cos(v);
			particle.position.x = (1 + halfTcosHalfV ) * math.cos(v);
			particle.position.y = (1 + halfTcosHalfV ) * math.sin(v);
			particle.position.z = halfT * math.sin(v / 2);
		}
	}
	
}
