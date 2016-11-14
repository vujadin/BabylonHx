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
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.particles.SolidParticleSystem;
import com.babylonhx.particles.SolidParticle;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticles4 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 2, 10, Vector3.Zero(), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		var light = new PointLight("light1", new Vector3(0, 0, 0), scene);
		
		light.intensity = 0.7;
		
		var knot = Mesh.CreateTorusKnot("knot", 4, 0.5, 512, 64, 4, 5, scene);
		 
		var knotmat = new StandardMaterial("knot", scene);
		knotmat.pointsCloud = true;
		knotmat.pointSize = 5.0;
		
		knot.material = knotmat;
		knot.isVisible = false;
		
		var particleSystem = new ParticleSystem("particles", 2000, scene);
		
		particleSystem.particleTexture = new Texture("assets/img/flare.png", scene);
		
		// Where the particles come from
		particleSystem.emitter = knot;
		particleSystem.minEmitBox = new Vector3(-1, 0, 0); 
		particleSystem.maxEmitBox = new Vector3(1, 0, 0); 
		
		particleSystem.color1 = new Color4(0.7, 0.8, 1.0, 1.0);
		particleSystem.color2 = new Color4(0.2, 0.5, 1.0, 1.0);
		particleSystem.colorDead = new Color4(0, 0, 0.2, 0.0);
		
		particleSystem.minSize = 0.1;
		particleSystem.maxSize = 0.5;
		
		particleSystem.minLifeTime = 5.3;
		particleSystem.maxLifeTime = 15.0;
		
		particleSystem.emitRate = 20000;
		
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		
		particleSystem.gravity = new Vector3(0, 0, 0);
		
		particleSystem.direction1 = new Vector3(0, 0, 0);
		particleSystem.direction2 = new Vector3(0, 0, 0);
		
		particleSystem.minAngularSpeed = 0;
		particleSystem.maxAngularSpeed = Math.PI;
		
		particleSystem.minEmitPower = 1;
		particleSystem.maxEmitPower = 1;
		particleSystem.updateSpeed = 0.25;
				
		var vertices = knot.getVerticesData(VertexBuffer.PositionKind);
		var vertexIndex:Int = 0;
		
		var positionfunc = function(part:SolidParticle, i:Int, s) {
			part.position.x = vertices[i * 3];
			part.position.y = vertices[i * 3 + 1];
			part.position.z = vertices[i * 3 + 2];
			part.color = new Color4(part.position.x, part.position.y, part.position.z, 1);
		};
		
		var sps = new SolidParticleSystem('s', scene, { updatable: false } );
		trace("sps");
		//var model = Mesh.CreateBox('b', 0.2, scene);
		var model = MeshBuilder.CreatePolyhedron('m', { size: 0.02 }, scene);
		sps.addShape(model, Std.int(vertices.length / 3), { positionFunction: positionfunc } );
		sps.buildMesh();
		model.dispose();
		
		particleSystem.startPositionFunction = function(worldMatrix:Matrix, positionToUpdate:Vector3, _) {
			var posX = vertices[vertexIndex * 3];
			var posY = vertices[vertexIndex * 3 + 1];
			var posZ = vertices[vertexIndex * 3 + 2];
			
			Vector3.TransformCoordinatesFromFloatsToRef(posX, posY, posZ, worldMatrix, positionToUpdate);
			
			vertexIndex++;
			
			if (vertexIndex >= knot.getTotalVertices()) {
				vertexIndex = 0;
			}
		};
		
		particleSystem.start();
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
