package samples;

import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GodRays2 {

	public function new(scene:Scene) {
		var engine = scene.getEngine();
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 2, 10, Vector3.Zero(), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new PointLight("light1", new Vector3(0, 0, 0), scene);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		var knot = Mesh.CreateTorusKnot("knot", 2, 0.5, 256, 64, 2, 3, scene);
		var knot2 = Mesh.CreateTorusKnot("knot", 2, 0.1, 256, 64, 2, 3, scene);
		
		var knotmat = new StandardMaterial("knot", scene);
		knotmat.pointsCloud = true;
		knotmat.pointSize = 5.0;
		
		knot.material = knotmat;
		
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.getShadowMap().renderList.push(knot);
		shadowGenerator.getShadowMap().renderList.push(knot2);
		knot.receiveShadows = true;
		knot2.receiveShadows = true;
		
		var particleSystem = new ParticleSystem("particles", 2000, scene);
		
		particleSystem.particleTexture = new Texture("assets/img/flare.png", scene);
		
		particleSystem.emitter = knot;
		particleSystem.minEmitBox = new Vector3(-1, 0, 0); 
		particleSystem.maxEmitBox = new Vector3(1, 0, 0); 
		
		particleSystem.color1 = new Color4(0.7, 0.8, 1.0, 1.0);
		particleSystem.color2 = new Color4(0.2, 0.5, 1.0, 1.0);
		particleSystem.colorDead = new Color4(0, 0, 0.2, 0.0);
		
		particleSystem.minSize = 0.1;
		particleSystem.maxSize = 0.5;
		
		particleSystem.minLifeTime = 0;
		particleSystem.maxLifeTime = 300.0;
		
		particleSystem.emitRate = 2000;
		
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		
		particleSystem.gravity = new Vector3(0, 0, 0);
		
		particleSystem.direction1 = new Vector3(0, 0, 0);
		particleSystem.direction2 = new Vector3(0, 0, 0);
		
		particleSystem.minAngularSpeed = 0;
		particleSystem.maxAngularSpeed = Math.PI;
		
		particleSystem.minEmitPower = 1;
		particleSystem.maxEmitPower = 1;
		particleSystem.updateSpeed = 8;
		
		var godrays = new VolumetricLightScatteringPostProcess('godrays', 1.0, camera, null, 100, Texture.BILINEAR_SAMPLINGMODE, engine, false);
		untyped godrays.mesh.material.diffuseTexture = new Texture('assets/img/sun.png', scene, true, false, Texture.BILINEAR_SAMPLINGMODE);
		untyped godrays.mesh.material.diffuseTexture.hasAlpha = true;
		godrays.mesh.position = new Vector3(0, 0, 0);
		godrays.mesh.scaling = new Vector3(1.2, 1.2, 1.2);
		
		var vertices = knot.getVerticesData(VertexBuffer.PositionKind);
		var vertexIndex:Int = 0;
		particleSystem.startPositionFunction = function(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle) {
			var posX = vertices[Std.int(vertexIndex * 3)];
			var posY = vertices[Std.int(vertexIndex * 3 + 1)];
			var posZ = vertices[Std.int(vertexIndex * 3 + 2)];
			
			Vector3.TransformCoordinatesFromFloatsToRef(posX, posY, posZ, worldMatrix, positionToUpdate);
			
			vertexIndex++;
			
			if (vertexIndex >= knot.getTotalVertices()) {
				vertexIndex = 0;
			}
			
			light.position = positionToUpdate;
			godrays.mesh.position = positionToUpdate;
		}
		
		particleSystem.start();	 
		
		var time:Float = 0;
		scene.registerBeforeRender(function(_, _) {
			time = Tools.Now();
			
			knot.rotation.x = (Math.PI / 10 + Math.cos(time));
			knot.rotation.y = (Math.PI / 10 + Math.sin(time));
			knot.rotation.z = 20 + (-8 + 8 * Math.sin(time));
			knot2.rotation.x = (Math.PI / 10 + Math.cos(time));
			knot2.rotation.y = (Math.PI / 10 + Math.sin(time));
			knot2.rotation.z = 20 + (-8 + 8 * Math.sin(time));			
		});	
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}