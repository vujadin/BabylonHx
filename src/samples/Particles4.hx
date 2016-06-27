package samples;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;
import com.babylonhx.Scene;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles4 {

	public function new(scene:Scene) {
		// This creates and positions a free camera (non-mesh)
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 2, 10, Vector3.Zero(), scene);
		
		// This targets the camera to scene origin
		camera.setTarget(Vector3.Zero());
		
		// This attaches the camera to the canvas
		camera.attachControl();
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new PointLight("light1", new Vector3(0, 0, 0), scene);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		var knot = Mesh.CreateTorusKnot("knot", 2, 0.5, 256, 64, 2, 3, scene);
		
		var knotmat = new StandardMaterial("knot", scene);
		knotmat.pointsCloud = true;
		knotmat.pointSize = 2.0;
		
		knot.material = knotmat;
		knot.isVisible = true;
				
		// Create a particle system
		var particleSystem = new ParticleSystem("particles", 2000, scene);
		
		//Texture of each particle
		particleSystem.particleTexture = new Texture("assets/img/flare.png", scene);
		
		// Where the particles come from
		particleSystem.emitter = knot;
		particleSystem.minEmitBox = new Vector3(-1, 0, 0); // Starting all from
		particleSystem.maxEmitBox = new Vector3(1, 0, 0); // To...
		
		// Colors of all particles
		particleSystem.color1 = new Color4(0.7, 0.8, 1.0, 1.0);
		particleSystem.color2 = new Color4(0.2, 0.5, 1.0, 1.0);
		particleSystem.colorDead = new Color4(0, 0, 0, 0.0);
		
		// Size of each particle (random between...
		particleSystem.minSize = 0.1;
		particleSystem.maxSize = 0.5;
		
		// Life time of each particle (random between...
		particleSystem.minLifeTime = 0.3;
		particleSystem.maxLifeTime = 10.0;
		
		// Emission rate
		particleSystem.emitRate = 20000;

		// Blend mode : BLENDMODE_ONEONE, or BLENDMODE_STANDARD
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;

		// Set the gravity of all particles
		particleSystem.gravity = new Vector3(0, 0, 0);

		// Direction of each particle after it has been emitted
		particleSystem.direction1 = new Vector3(0, 0, 0);
		particleSystem.direction2 = new Vector3(0, 0, 0);

		// Angular speed, in radians
		particleSystem.minAngularSpeed = 0;
		particleSystem.maxAngularSpeed = Math.PI;

		// Speed
		particleSystem.minEmitPower = 1;
		particleSystem.maxEmitPower = 1;
		particleSystem.updateSpeed = 0.1;
				
		// start position
		var vertices = knot.getVerticesData(VertexBuffer.PositionKind);
		var vertexIndex = 0;
		particleSystem.startPositionFunction = function(worldMatrix, positionToUpdate) {
			var posX = vertices[vertexIndex * 3];
			var posY = vertices[vertexIndex * 3 + 1];
			var posZ = vertices[vertexIndex * 3 + 2];
		
			Vector3.TransformCoordinatesFromFloatsToRef(posX, posY, posZ, worldMatrix, positionToUpdate);
			
			vertexIndex++;
			
			if (vertexIndex >= knot.getTotalVertices()) {
				vertexIndex = 0;
			}
		}
		
		// Start the particle system
		particleSystem.start();
		
		var time:Float = 0;
		var px:Float = 0;
		var py:Float = 0;
		var pz:Float = 0;
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
			time = Date.now().getTime() * 0.005;
			px = Tools.randomFloat(-0.1, 0.1);
			py = Tools.randomFloat( -0.1, 0.1);
			pz = Tools.randomFloat( -0.1, 0.1);
			
			particleSystem.direction1 = new Vector3(px / 10 , py / 10, pz / 10);
			particleSystem.direction2 = new Vector3(pz / 10, px / 10, py / 10);
			
			//camera.alpha = (Math.PI / 10 + Math.cos(time / 30));
			//camera.beta = (Math.PI / 10 + Math.sin(time / 50));
			//camera.radius = 20 + (-8 + 8 * Math.sin(time / 10));
		
			particleSystem.color1 = new Color4(0.5 + 0.5 * Math.sin(time / 10), 0.5 + 0.5 * Math.cos(time / 8.0), 0.5 + 0.5 * Math.sin(time / 4.0), 1.0);
			particleSystem.color2 = new Color4(0.5 + 0.5 * Math.cos(time / 2), 0.5 + 0.5 * Math.sin(time / 10.0), 0.5 + 0.5 * Math.sin(time / 5.0), 1.0);
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
