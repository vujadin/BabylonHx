package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFile;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFileLoader;
import com.babylonhx.layer.Layer;
import com.babylonhx.mesh.VertexBuffer;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MeshImport {
	
	public function new(scene:Scene) {
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.intensity = 1.8;
		
		var camera = new FreeCamera("Camera", Vector3.Zero(), scene);
		camera.attachControl(this, false);
		
		var towerMesh:Mesh = null;
		var platformMesh:Mesh = null;
		
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		var mat = new StandardMaterial("torusmat", scene);
		mat.alpha = 0.5;
		
		CTMFileLoader.load("assets/models/roundedcube.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {			
			//meshes[0].material = mat;
			meshes[0].position.y = 2;
		});
		
		SceneLoader.ImportMesh("", "assets/models/", "torus.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			newMeshes[0].material = mat;
			newMeshes[0].material.alpha = 0.5;
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});			
	}
	
	function showNormals(mesh:Mesh, size:Float = 0.5) {
		var normals = mesh.getVerticesData(VertexBuffer.NormalKind);
		var positions = mesh.getVerticesData(VertexBuffer.PositionKind);
	  
		var i:Int = 0;
		while (i < normals.length) {
			var v1 = Vector3.FromArray(positions, i);
			var v2 = v1.clone().add(Vector3.FromArray(normals, i).scaleInPlace(size));
			Mesh.CreateLines("" + i, [v1, v2], mesh.getScene());
			
			i += 3;
		}  
	}
	
}
