package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.WebVRFreeCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Space;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.particles.solid.SolidParticleSystem;
import com.babylonhx.particles.solid.SolidParticle;

import com.babylonhx.animations.Animation;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.collisions.PickingInfo;

import com.babylonhx.tools.EventState;
import com.babylonhx.utils.Image;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.RawTexture;
import com.babylonhx.materials.textures.procedurals.standard.Plasma;
import com.babylonhx.materials.textures.procedurals.standard.Spiral;
import com.babylonhx.materials.textures.procedurals.standard.Combustion;
import com.babylonhx.materials.textures.procedurals.standard.Electric;
import com.babylonhx.materials.textures.procedurals.standard.Voronoi;

import com.babylonhx.postprocess.NotebookDrawingsPostProcess;
import com.babylonhx.postprocess.WatercolorPostProcess;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticles6 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 2, 5, Vector3.Zero(), scene);
		camera.attachControl();
		
		var sphere1 = Mesh.CreateSphere("Sphere1", 50, 16.0, scene);
		sphere1.position.x = 0;
		sphere1.convertToFlatShadedMesh();
		var verticesCount = sphere1.getTotalVertices();
		
		var positions = sphere1.getVerticesData(VertexBuffer.PositionKind);
		var numberOfPoints = Std.int(positions.length / 3);
		var positionsVec3:Array<Vector3> = [];
		for(i in 0...numberOfPoints) {
			positionsVec3.push(new Vector3(positions[i * 3], positions[i * 3 + 1], positions[i * 3 + 2]));
		}
		trace('len: ' + positionsVec3.length);
		
		var pl = new PointLight("pl", new Vector3(0, 0, 0), scene);
		pl.diffuse = new Color3(1, 1, 1);
		pl.intensity = 1.0;
		
		var nb = positionsVec3.length;    		// nb of triangles
		var fact = 20; 			// cube size
		
		// custom position function for SPS creation
		var myPositionFunction = function (particle:SolidParticle, position:Vector3) {		 
			 // position particles
			 // assign ID					 
			  particle.position = position.add(sphere1.position);
			  particle.rotation.x = Math.random() * 3.15;
			  particle.rotation.y = Math.random() * 3.15;
			  particle.rotation.z = Math.random() * 1.5;
			  particle.color = new Color4(particle.position.x / fact + 0.5, particle.position.y / fact + 0.5, particle.position.z / fact + 0.5, 1.0);
		};
		
		// model : triangle
		var triangle = Mesh.CreateDisc("t", 0.6, 3, scene);
		
		// SPS creation
		var SPS = new SolidParticleSystem('SPS', scene, {isPickable: true});
		SPS.addShape(triangle, nb);
		var mesh = SPS.buildMesh();
		// dispose the model
		triangle.dispose();
		
		// SPS init
		SPS.initParticles = function () {
			for (p in 0...SPS.nbParticles) {
				myPositionFunction(SPS.particles[p], positionsVec3[p]);
			}
		} 
		
		SPS.updateParticle = function (particle) {
			particle.rotation.x += particle.position.z / 100;
			particle.rotation.z += particle.position.x / 100;
			return particle;
		}
		
		SPS.initParticles();
		SPS.setParticles();
		SPS.refreshVisibleSize();                           // force the BBox recomputation
		scene.onPointerDown = function(_, pickResult) {
			var meshFaceId = pickResult.faceId;             // get the mesh picked face
			if (meshFaceId == -1) {return;}                     // return if nothing picked
			var idx = SPS.pickedParticles[meshFaceId].idx;  // get the picked particle idx from the pickedParticles array
			var p = SPS.particles[idx]; 
		};
		
		sphere1.isVisible = false;
		
		// Optimizers after first setParticles() call
		// will be used only for the next setParticles() calls
		SPS.computeParticleColor = false;
		SPS.computeParticleTexture = false;
		
		// SPS mesh animation
		scene.registerBeforeRender(function(_, _) {
			pl.position = camera.position;
			SPS.setParticles();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
