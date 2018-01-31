package samples;

import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFile;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFileLoader;
import com.babylonhx.tools.Tools;
import haxe.Json;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TestCustomFileStruct {

	public function new(scene:Scene) {
		//var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 50, Vector3.Zero(), scene);
		//camera.attachControl();
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		var mat = new StandardMaterial("mat", scene);
		mat.freeze();
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 2000, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.emissiveColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skyboxMaterial.freeze();
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		var originalMeshes:Array<Mesh> = [];	
			
		Tools.LoadFile("assets/levels/level2/materials.json", function(data:String) {
			var materials:Array<Dynamic> = cast Json.parse(data);
			for (m in materials) {
				if (m.customType == null) {
					// standard material...
					StandardMaterial.Parse(m, scene, "assets/levels/level2/");
				}
			}
			materials = null;
			
			Tools.LoadFile("assets/levels/level2/multimaterials.json", function(data:String) {
				var multiMaterials:Array<Dynamic> = cast Json.parse(data);
				for (mm in multiMaterials) {
					MultiMaterial.Parse(mm, scene, "assets/levels/level2/");
				}
				
				Tools.LoadFile("assets/levels/level2/ctmFileList.json", function(data:String) {
					var ctmFileList = Json.parse(data);
					var fList:Array<String> = cast ctmFileList.fileList;
					
					for (fName in fList) {
						CTMFileLoader.load(ctmFileList.rootUrl + fName + ctmFileList.ext, scene, function(meshes:Array<Mesh>, triangleCount:Int) {
							meshes[0].name = fName;
							meshes[0].material = mat;
							originalMeshes.push(meshes[0]);
						});
					}
				
					Tools.LoadFile("assets/levels/level2/meshes.json", function(data:String) {
						var meshes:Array<Dynamic> = cast Json.parse(data);
						
						for (m in meshes) {
							for (om in originalMeshes) {
								if (m.io == om.name) {
									if (scene.getMaterialByID(m.m) != null) {
										om.material = scene.getMaterialByID(m.m);
										om.material.freeze();
									}
									else if (scene.getMultiMaterialByID(m.m) != null) {
										om.material = scene.getMultiMaterialByID(m.m);
										trace(cast (om.material, MultiMaterial).subMaterials.length);
									}
									else {
										om.material = mat;
										trace(m.m);
									}
								}
							}
						}
						
						for (m in meshes) {
							var inst = cast(scene.getMeshByName(m.io), Mesh).clone("c"); // cast(scene.getMeshByName(m.io), Mesh).createInstance("inst");
							inst.position.copyFromFloats(m.p[0], m.p[1], m.p[2]);
							inst.rotation.copyFromFloats(m.r[0], m.r[1], m.r[2]);
							inst.scaling.copyFromFloats(m.s[0], m.s[1], m.s[2]);							
						}
						
						for (om in originalMeshes) {
							scene.removeMesh(om);
							om.dispose();
							om = null;
						}
					});
				});
			});				
		});
		
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});		
	}
	
}
