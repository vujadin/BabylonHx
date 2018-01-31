package samples;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.Animation.BabylonFrame;
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
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;
import com.babylonhx.Scene;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles7 {
	
	var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
		
		var camera = new ArcRotateCamera("Camera", -.707, 1.1, 40, new Vector3(0, 0, 0), scene);
		camera.attachControl();
		
		scene.clearColor = new Color4(0, 0, 0, 1);
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = 0.7;
		
		var box = Mesh.CreateBox('box', 3, scene);
		
		var perticleFromVerticesEmitter = box;
		perticleFromVerticesEmitter.useVertexColors = true;
		
		var verticesPositions = perticleFromVerticesEmitter.getVerticesData(VertexBuffer.PositionKind);
		var verticesNormals = perticleFromVerticesEmitter.getVerticesData(VertexBuffer.NormalKind);
		
		var verticesColor:Array<Float> = [];
		var i:Int = 0; 
		while (i < verticesPositions.length) {
			var vertexPosition = new Vector3(
				verticesPositions[i],
				verticesPositions[i + 1],
				verticesPositions[i + 2]
			);
			var vertexNormal = new Vector3(
				verticesNormals[i],
				verticesNormals[i + 1],
				verticesNormals[i + 2]
			);
			var r = Math.random();
			var g = Math.random();
			var b = Math.random();
			var alpha = 1;
			var color = new Color4(r, g, b, alpha);
			verticesColor.push(r);
			verticesColor.push(g);
			verticesColor.push(b);
			verticesColor.push(alpha);
			
			var gizmo = Mesh.CreateBox('gizmo', 0.001, scene);
			gizmo.position = vertexPosition;
			gizmo.parent = perticleFromVerticesEmitter;
			createParticleSystem(
				gizmo,
				vertexNormal.normalize().scale(10),
				color
			);
			
			i += 3;
		}
		
		perticleFromVerticesEmitter.setVerticesData(VertexBuffer.ColorKind, new Float32Array(verticesColor));
		
		scene.registerBeforeRender(function(_, _) {
			box.rotation.x += .03;
			box.rotation.z += .05;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
	function createParticleSystem(emitter, direction, color) {
		var particleSystem = new ParticleSystem("particles", 5000, scene);
		
		//Texture of each particle
		particleSystem.particleTexture = new Texture("assets/img/flare.png", scene);
		
		// Where the particles come from
		particleSystem.emitter = emitter; // the starting object, the emitter
		particleSystem.minEmitBox = new Vector3(0, 0, 0); // Starting all from
		particleSystem.maxEmitBox = new Vector3(0, 0, 0); // To...
		
		// Colors of all particles
		particleSystem.color1 = color;
		particleSystem.color2 = color;
		particleSystem.colorDead = new Color4(color.r, color.g, color.b, 0.0);
		
		// Size of each particle (random between...
		particleSystem.minSize = 0.1;
		particleSystem.maxSize = 0.1;
		
		// Life time of each particle (random between...
		particleSystem.minLifeTime = 5;
		particleSystem.maxLifeTime = 5;
		
		// Emission rate
		particleSystem.emitRate = 350;
		
		// Blend mode : BLENDMODE_ONEONE, or BLENDMODE_STANDARD
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		
		// Set the gravity of all particles
		particleSystem.gravity = new Vector3(0, 0, 0);
		
		// Direction of each particle after it has been emitted
		particleSystem.direction1 = direction;
		particleSystem.direction2 = direction;
		
		// Angular speed, in radians
		particleSystem.minAngularSpeed = 0;
		particleSystem.maxAngularSpeed = Math.PI;
		
		// Speed
		particleSystem.minEmitPower = 1;
		particleSystem.maxEmitPower = 1;
		particleSystem.updateSpeed = 0.005;
		
		// Start the particle system
		particleSystem.start();
	}
	
}
