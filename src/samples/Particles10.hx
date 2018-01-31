package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles10 {

	public function new(scene:Scene) {
		var url = "assets/img/star.jpg";
		
		var camera = new ArcRotateCamera("cam", -1.57079633, 1.57079633, 20, new Vector3(0, 0, 0), scene);
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = 0.7;
		
		var createBeam = function(hilt:Mesh, ps:ParticleSystem, color1:Color4, color2:Color4, colorDead:Color4) {			
			ps.particleTexture = new Texture(url, scene);
			
			ps.minSize = 0.7;
			ps.maxSize = 0.7;
			ps.minLifeTime = 5;
			ps.maxLifeTime = 5;
			ps.minEmitPower = 2;
			ps.maxEmitPower = 2;
			
			ps.minAngularSpeed = 0;
			ps.maxAngularSpeed = Math.PI;
			
			ps.emitter = hilt;
			
			ps.emitRate = 70;
			ps.updateSpeed = 0.05;
			ps.blendMode = ParticleSystem.BLENDMODE_ONEONE;
			
			ps.color1 = color1;
			ps.color2 = color2;
			ps.colorDead = colorDead;
			
			ps.direction1 = new Vector3(0, 1, 0);
			ps.direction2 = new Vector3(0, 1, 0);
			ps.minEmitBox = new Vector3(0, 1.5, 0);
			ps.maxEmitBox = new Vector3(0, 1.5, 0);
			
			ps.start();
		};
		
		var createSparkles = function(emitter:Vector3, color1:Color4, color2:Color4) {
			var ps1 = new ParticleSystem("ps1", 10000, scene);
			ps1.particleTexture = new Texture(url, scene);
			
			ps1.minSize = 0.5;
			ps1.maxSize = 1;
			ps1.minLifeTime = 1;
			ps1.maxLifeTime = 1;
			ps1.minEmitPower = 3;
			ps1.maxEmitPower = 3;
			
			ps1.minAngularSpeed = 0;
			ps1.maxAngularSpeed = Math.PI;
			
			ps1.emitter = emitter;
			
			ps1.emitRate = 20;
			ps1.updateSpeed = 0.05;
			ps1.blendMode = ParticleSystem.BLENDMODE_ONEONE;
			
			ps1.color1 = color1;
			ps1.color2 = color2;
			ps1.colorDead = new Color4(0, 0, 0.2, 0);
			
			ps1.direction1 = new Vector3(-1, 1, -1);
			ps1.direction2 = new Vector3(1, -1, 1);
			ps1.minEmitBox = new Vector3(0, -0.5, 0);
			ps1.maxEmitBox = new Vector3(0, 0.5, 0);
			
			ps1.gravity = new Vector3(0, -5, 0);
			
			ps1.start();
		};
		
		// Sword 1
		var hilt1 = Mesh.CreateCylinder("box", 2.5, .5, .5, 12, 8, scene);
		hilt1.position.y = -5;
		hilt1.position.x = -2;
		var color1 = new Color4(1, 0, 0, 1);
		var color2 = new Color4(0, 1, 0, 1);
		var colorDead = new Color4(0, 0, 1, 1);
		createBeam(hilt1, new ParticleSystem("ps1", 1000, scene), color1, color2, colorDead);
		
		// Sword 2
		var hilt2 = Mesh.CreateCylinder("box", 2.5, .5, .5, 12, 8, scene);
		hilt2.position.y = -5;
		hilt2.position.x = 2;
		hilt2.rotation.z = Math.PI / 4;
		hilt2.rotation.y = -Math.PI / 40;
		var color1 = new Color4(0, 0, 1, 1);
		var color2 = new Color4(0, 1, 0, 1);
		var colorDead = new Color4(1, 0, 0, 1);
		createBeam(hilt2, new ParticleSystem("ps2", 1000, scene), color1, color2, colorDead);
		
		Tools.delay(function() {
			createSparkles(new Vector3(-2, -1, -0.25), new Color4(1, 0.5, 0.5, 1), new Color4(0.5, 1, 0.5, 1));
		}, 800);
		
		// Camera Animations
		scene.registerBeforeRender(function(_, _) {
			untyped scene.activeCamera.alpha += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {			
			scene.render();
		});
	}
	
}
