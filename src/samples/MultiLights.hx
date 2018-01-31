package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.loading.ctm.CTMFile;
import com.babylonhx.loading.ctm.CTMFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.mesh.VertexBuffer;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MultiLights {

	public function new(scene:Scene) {
		// Setup camera
		var camera = new ArcRotateCamera("Camera", -Math.PI / 2.4, Math.PI / 2.2, 10, Vector3.Zero(), scene);
		camera.attachControl();
		
		var lightSpheres:Array<Mesh> = [];
		var lights:Array<PointLight> = [];
		var lightTags:Array<Vector3> = [];
		
		var sphere:Mesh = Mesh.CreateSphere('sphere', 10, 5, scene);
		sphere.isVisible = false;
		
		var vertices = sphere.getVerticesData(VertexBuffer.PositionKind);
		
		var generateLight = function (x:Float, y:Float, z:Float) {
			var light = new PointLight("Omni", new Vector3(0, 0, 0), scene);
			var lightSphere = Mesh.CreateSphere("Sphere", 6, 0.1, scene);
			
			lightTags.push(new Vector3(
				1 - Math.random() * 2,
				1 - Math.random() * 2,
				1 - Math.random() * 2
			));
			
			lightSphere.material = new StandardMaterial("mat", scene);
			untyped lightSphere.material.diffuseColor = new Color3(0, 0, 0);
			untyped lightSphere.material.specularColor = new Color3(0, 0, 0);
			untyped lightSphere.material.emissiveColor = new Color3(
				Math.random(), Math.random(), Math.random()
			);
			
			light.intensity = 0.6;
			
			light.diffuse = untyped lightSphere.material.emissiveColor;
			//light.specular = untyped lightSphere.material.emissiveColor;
			
			lightSpheres.push(lightSphere);
			lights.push(light);
			
			light.position.set(x, y, z);
			lightSphere.position.set(x, y, z);
		};
		
		var ladyMesh:Mesh = null;
		CTMFileLoader.load("assets/models/lady_with_primroses.ctm", scene, function(meshes:Array<Mesh>, _) {
			ladyMesh = meshes[0];
			ladyMesh.scaling.set(0.03, 0.03, 0.03);
			ladyMesh.position.y -= 1.2;
			ladyMesh.position.x -= 0.2;			
		});
		
		var vertexIndex = 0;
		for (index in 0...Std.int(vertices.length / 3)) {
			generateLight(
				vertices[vertexIndex * 3],
				vertices[vertexIndex * 3 + 1],
				vertices[vertexIndex * 3 + 2]
			);
			
			vertexIndex++;
		}
		
		scene.beforeRender = function (_, _) {			
			ladyMesh.rotation.y += 0.01;
		};
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
