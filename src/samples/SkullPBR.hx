package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.Light;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.lib.pbr.PBRMaterial;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.tools.EventState;

import haxe.io.Bytes;
import haxe.io.BytesInput;

import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.VertexData;

import com.babylonhx.loading.plugins.ctmfileloader.CTM;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFile;

import com.babylonhx.serializers.obj.ObjExport;
import com.babylonhxext.loaders.obj.ObjLoader;

import com.babylonhx.utils.typedarray.UInt32Array;
import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SkullPBR {
	
	var mesh:Mesh;
	var light:Light;
	var light3:PointLight;
	var angle:Float = 0;
	var camera:ArcRotateCamera;
	var mat:Material;
	var scene:Scene;
	
	var offsets:Array<Dynamic> = [];
	
	static function saveText(name:String, buf:String) {
		#if cpp
		var stream = sys.io.File.write(name, false);
		
		try { 
			stream.writeString(buf); 
			stream.flush(); 
		}
		catch (err:Dynamic) {
			trace(err);
		}
		
		stream.close();
		#end
	}
	
	function initOffsets(file:CTMFile) {
		var indices = file.body.indices;
		var start = 0;
		var min = file.body.vertices.length;
		var max = 0;
		var minPrev = min;
	  
		var i:Int = 0;
		while (i < indices.length) {
			for (j in 0...3) {
				var idx = indices[i++];
				
				if (idx < min) {
					min = idx;
				}
				if (idx > max) {
					max = idx;
				}
			}
			
			if (max - min > 65535) {
				i -= 3;
				var k = start;
				while (k < i) {
					indices[k] -= minPrev;
					++k;
				}
				
				offsets.push({ start: start, count: i - start, index: minPrev });
				
				start = i;
				min = file.body.vertices.length;
				max = 0;
			}
			
			minPrev = min;
		}
		
		var k = start;
		while (k < i) {
			indices[k] -= minPrev;
			++k;
		}
		
		offsets.push({ start: start, count: i - start, index: minPrev });
		
		var vertexData:VertexData = new VertexData();
			
		var vertices:Array<Float> = [];
		for (i in 0...file.body.vertices.length) {
			vertices.push(file.body.vertices[i]);
		}
		
		var normals:Array<Float> = [];
		if (file.body.normals != null) {
			
			for (i in 0...file.body.normals.length) {
				normals.push(file.body.normals[i]);
			}			 
		}
		
		var uvs:Array<Float> = [];
		if (file.body.uvMaps != null) {			
			for (i in 0...file.body.uvMaps[0].uv.length) {
				uvs.push(file.body.uvMaps[0].uv[i]);
			}			
		}
		
		if (file.header.attrMapCount > 0 && file.body.attrMaps != null) {
			var colors:Array<Float> = [];
			for (i in 0...file.body.attrMaps[0].attr.length) {
				colors.push(file.body.attrMaps[0].attr[i]);
			}
			vertexData.colors = colors;
		}
		
		var indices:Array<Int> = [];
		for (i in 0...file.body.indices.length) {
			indices.push(file.body.indices[i]);
		}
		
		for (i in 0...offsets.length) {				
			var indicesFinal = indices.slice(Std.int(offsets[i].start * 2), offsets[i].count);
			//VertexData._ComputeSides(Mesh.FRONTSIDE, vertices, indicesFinal, normals, uvs);
			VertexData.ComputeNormals(vertices, indicesFinal, normals);
			
			vertexData.positions = vertices;
			vertexData.normals = normals;
			vertexData.uvs = uvs;
			vertexData.indices = indicesFinal;
			
			mesh = new Mesh("camaro", scene);
			vertexData.applyToMesh(mesh);
			mesh.flipFaces(true);
			/*var mat = new StandardMaterial("camaromat", scene);
			mat.diffuseTexture = new Texture("assets/img/girl.jpg", scene);
			mat.specularColor = Color3.Black();
			mesh.material = mat;
			mesh.scaling.set(5, 5, 5);*/
		}
	}

	public function new(scene:Scene) {
		camera = new ArcRotateCamera("Camera", 0, 0, 100, Vector3.Zero(), scene);
		camera.attachControl();
		
		this.scene = scene;
		
		var light2 = new HemisphericLight("hemi-2", new Vector3(1, 1, 1), scene);
		light2.diffuse = new Color3(1, 1, 1);
		light2.specular = new Color3(1, 1, 1);
		light2.groundColor = new Color3(0, 0, 0);
		light2.intensity = .7;
		
		/*var m = Mesh.CreateCapsule("capstest", 4, 5, 20, scene);		
		untyped m.material.diffuseTexture = new Texture("assets/img/10.jpg", scene);
		m.position.x = 10;*/
		//m.material.wireframe = true;

		
		/*var light = new DirectionalLight("dir01", new Vector3(5, 0, -2), scene);
		light.diffuse = new Color3(1, 1, 1);
		light.specular = new Color3(1, 1, 1);
		light.position = new Vector3(20, 10, 20);*/
		
		Tools.LoadFile("assets/models/wood_truck.ctm", function(data:Bytes) {
			var file = new CTMFile(new BytesInput(data));
			file.load();
			if (file.body.indices != null) {
				trace("Indices: " + file.body.indices.length);
			}
			if (file.body.vertices != null) {
				trace("Vertices: " + file.body.vertices.length);
			}
			if (file.body.uvMaps != null) {
				trace("UVMaps: " + file.body.uvMaps[0].uv.length);
			}
			if (file.body.normals != null) {
				trace("Normals: " + file.body.normals.length);
			}
			if (file.body.attrMaps != null) {
				trace("AttrMaps: " + file.body.attrMaps[0].attr.length);
			}
			
			//var timenow = Sys.cpuTime() * 1000;// Date.now().getTime();
			initOffsets(file);
			//init(file, scene);
			//trace("parsing time: " + (Sys.cpuTime() * 1000 - timenow));
			
			/*SceneLoader.ImportMesh("", "assets/models/", "girl.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
				koopaShell = cast newMeshes[0];
				koopaShell.scaling.set(5, 5, 5);
				allMeshes.set("koopaShell", koopaShell);
				koopaShell.setEnabled(false);
			});*/
			
			#if cpp
			/*var bmObj:String = ObjExport.OBJ(mesh);
			saveText(Sys.getCwd() + "/file.obj", bmObj);*/
			#end
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
			
		}, "ctm"); 
		
		/*SceneLoader.ImportMesh("", "assets/models/", "skull.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			mesh = cast newMeshes[0];
			camera.target = mesh;
			camera.minZ = 10;
			camera.setPosition(new Vector3(0, 0, 100));
			camera.radius = 100;
			
			var tx_box = new CubeTexture("assets/img/skybox/skybox", scene);
			var tx_gold = new Texture("assets/img/gold.jpg", scene);
			var tx_sp = new Texture("assets/img/gold_spec.jpg", scene);
			
			var box = Mesh.CreateBox("sky-box", 800.0, scene);		
			var box_mat = new PBRMaterial("skull-box-mat", scene);		
			box_mat.reflectionTexture = tx_box;
			box_mat.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;		
			box_mat.microSurface = 1.0;
			box_mat.cameraExposure = 0.66;
			box_mat.cameraContrast = 1.66;
			box_mat.disableLighting = true;
			box_mat.backFaceCulling = false;
			box.infiniteDistance = true;
			box.material = box_mat;
			
			var use_pbr = false;
			
			if (use_pbr == true) {
				//skull pbr material    
				mat = new PBRMaterial("skull-mat", scene);
				
				cast (mat, PBRMaterial).microSurface = .82;
				cast (mat, PBRMaterial).albedoColor = new Color3(0.05, 0.03, 0.01);
				cast (mat, PBRMaterial).albedoTexture = tx_gold;
				
				cast (mat, PBRMaterial).reflectivityColor = new Color3(0.9, 0.8, 0.2);
				cast (mat, PBRMaterial).reflectivityTexture = tx_sp;
				
				cast (mat, PBRMaterial).environmentIntensity = .5;
				cast (mat, PBRMaterial).directIntensity = .5;
				cast (mat, PBRMaterial).cameraExposure = 1.66;
				cast (mat, PBRMaterial).cameraContrast = 1.66;
				cast (mat, PBRMaterial).usePhysicalLightFalloff = true;
				
				//reflection
				cast (mat, PBRMaterial).reflectionTexture = tx_box;
				cast (mat, PBRMaterial).reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
				
				//refraction			
				cast (mat, PBRMaterial).refractionTexture = tx_box;
				cast (mat, PBRMaterial).refractionTexture.coordinatesMode = Texture.SKYBOX_MODE;
				
				cast (mat, PBRMaterial).linkRefractionWithTransparency = true;
			} 
			else {
				//skull standard material
				mat = new StandardMaterial("skull-mat", scene);
				
				cast (mat, StandardMaterial).diffuseColor = new Color3(0.9, 0.8, 0.2);
				cast (mat, StandardMaterial).diffuseTexture = tx_gold;
				
				cast (mat, StandardMaterial).specularColor = new Color3(0.9, 0.8, 0.2);
				cast (mat, StandardMaterial).specularTexture = tx_sp;
				
				cast (mat, StandardMaterial).ambientColor = new Color3(0.0, 0.0, 0.0);
				cast (mat, StandardMaterial).emissiveColor = new Color3(0.0, 0.0, 0.0);
				cast (mat, StandardMaterial).specularPower = 30;
				cast (mat, StandardMaterial).alpha = 1.0;
				
				//reflection
				cast (mat, StandardMaterial).reflectionTexture = tx_box;
				cast (mat, StandardMaterial).reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
				cast (mat, StandardMaterial).reflectionFresnelParameters = new FresnelParameters();
				cast (mat, StandardMaterial).reflectionFresnelParameters.power = .55;
				cast (mat, StandardMaterial).reflectionFresnelParameters.bias = .25;
				cast (mat, StandardMaterial).reflectionFresnelParameters.leftColor = Color3.White();
				cast (mat, StandardMaterial).reflectionFresnelParameters.rightColor = Color3.Black();
				
				cast (mat, StandardMaterial).emissiveFresnelParameters = new FresnelParameters();
				cast (mat, StandardMaterial).emissiveFresnelParameters.bias = 0.15;
				cast (mat, StandardMaterial).emissiveFresnelParameters.power = .85;
				cast (mat, StandardMaterial).emissiveFresnelParameters.leftColor = Color3.White();
				cast (mat, StandardMaterial).emissiveFresnelParameters.rightColor = Color3.Black();
				
				//refraction
				cast (mat, StandardMaterial).refractionTexture = tx_box;
				cast (mat, StandardMaterial).refractionTexture.coordinatesMode = Texture.SKYBOX_MODE;
				cast (mat, StandardMaterial).refractionFresnelParameters = new FresnelParameters();
				cast (mat, StandardMaterial).refractionFresnelParameters.leftColor = Color3.White();
				cast (mat, StandardMaterial).refractionFresnelParameters.rightColor = Color3.Black();
				cast (mat, StandardMaterial).refractionFresnelParameters.bias = .25;
				cast (mat, StandardMaterial).refractionFresnelParameters.power = .55;
			}
			
			mesh.material = mat;
			
			var light2 = new HemisphericLight("hemi-2", new Vector3(0, 0, 30), scene);
			light2.diffuse = new Color3(1, 1, 1);
			light2.specular = new Color3(1, 1, 1);
			light2.groundColor = new Color3(0, 0, 0);
			light2.intensity = .7;
			
			light3 = new PointLight("point-3", new Vector3(0, 0, -100), scene);
			light3.diffuse = new Color3(1, 1, 1);
			light3.specular = new Color3(1, 1, 1);
			light3.intensity = .75;
			
			angle = 0.0;
			scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
				before_render();
			});
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});*/
	}
		
	function init(file:CTMFile, scene:Scene, reorderVertices:Bool = true) {
		var vertexIndexArray = file.body.indices;
		var vertexPositionArray = file.body.vertices;
		var vertexNormalArray = file.body.normals;
		
		var vertexUvArray:Float32Array = null;
		var vertexColorArray:Float32Array = null;
		
		if (file.body.uvMaps != null && file.body.uvMaps.length > 0) {
			vertexUvArray = file.body.uvMaps[0].uv;
		}
		
		if (file.body.attrMaps != null && file.body.attrMaps.length > 0 && file.body.attrMaps[0].name == "Color") {
			vertexColorArray = file.body.attrMaps[0].attr;
		}
		
		// reorder vertices
		// (needed for buffer splitting, to keep together face vertices)
		
		var newFaces:UInt32Array = null;
		var	newVertices:Float32Array = null;
		var newNormals:Float32Array = null;
		var newUvs:Float32Array = null;
		var newColors:Float32Array = null;
		
		if (reorderVertices) {
			newFaces = new UInt32Array(vertexIndexArray.length);
			newVertices = new Float32Array(vertexPositionArray.length);
			
			if (vertexNormalArray != null) {
				newNormals = new Float32Array(vertexNormalArray.length);
			}
			if (vertexUvArray != null) {
				newUvs = new Float32Array(vertexUvArray.length);
			}
			if (vertexColorArray != null) {
				newColors = new Float32Array(vertexColorArray.length);
			}
			
			var indexMap:Dynamic = {};
			var vertexCounter:Int = 0;
			
			function handleVertex(v:Int) {
				if (indexMap[v] == null) {
					indexMap[v] = vertexCounter;
					
					var sx = Std.int(v * 3);
					var sy = Std.int(v * 3 + 1);
					var sz = Std.int(v * 3 + 2);
					
					var dx = Std.int(vertexCounter * 3);
					var dy = Std.int(vertexCounter * 3 + 1);
					var dz = Std.int(vertexCounter * 3 + 2);
					
					newVertices[dx] = vertexPositionArray[sx];
					newVertices[dy] = vertexPositionArray[sy];
					newVertices[dz] = vertexPositionArray[sz];
					
					if (vertexNormalArray != null) {
						newNormals[dx] = vertexNormalArray[sx];
						newNormals[dy] = vertexNormalArray[sy];
						newNormals[dz] = vertexNormalArray[sz];
					}
					
					if (vertexUvArray != null) {
						newUvs[Std.int(vertexCounter * 2)] 	  = vertexUvArray[Std.int(v * 2)];
						newUvs[Std.int(vertexCounter * 2 + 1)] = vertexUvArray[Std.int(v * 2 + 1)];						
					}
					
					if (vertexColorArray != null) {
						newColors[Std.int(vertexCounter * 4)] 	 = vertexColorArray[Std.int(v * 4)];
						newColors[Std.int(vertexCounter * 4 + 1)] = vertexColorArray[Std.int(v * 4 + 1)];
						newColors[Std.int(vertexCounter * 4 + 2)] = vertexColorArray[Std.int(v * 4 + 2)];
						newColors[Std.int(vertexCounter * 4 + 3)] = vertexColorArray[Std.int(v * 4 + 3)];
					}
					
					vertexCounter += 1;
				}
			}
			
			var a:Int = 0;
			var b:Int = 0;
			var c:Int = 0;
			
			var i:Int = 0;
			while (i < vertexIndexArray.length) {
				a = vertexIndexArray[i];
				b = vertexIndexArray[i + 1];
				c = vertexIndexArray[i + 2];
				
				handleVertex(a);
				handleVertex(b);
				handleVertex(c);
				
				newFaces[i] 	= indexMap[a];
				newFaces[i + 1] = indexMap[b];
				newFaces[i + 2] = indexMap[c];
				
				i += 3;
			}
			
			/*vertexIndexArray = newFaces;
			vertexPositionArray = newVertices;
			
			if (vertexNormalArray) {
				vertexNormalArray = newNormals;
			}
			if (vertexUvArray) {
				vertexUvArray = newUvs;
			}
			if (vertexColorArray) {
				vertexColorArray = newColors;
			}*/			
		}
		
		// compute offsets
		
		var indices = newFaces;
		var start = 0;
		var min = file.body.vertices.length;
		var max = 0;
		var minPrev = min;
		 
		var i:Int = 0;
		while (i < indices.length) {
			for (j in 0...3) {
				var idx = indices[i++];
				
				if (idx < min) {
					min = idx;
				}
				if (idx > max) {
					max = idx;
				}
			}
			
			if (max - min > 65535) {
				i -= 3;
				var k = start;
				while (k < i) {
					indices[k] -= minPrev;
					++k;
				}
				
				offsets.push({ start: start, count: i - start, index: minPrev });
				
				start = i;
				min = file.body.vertices.length;
				max = 0;
			}
			
			minPrev = min;
		}
		
		var k = start;
		while (k < i) {
			indices[k] -= minPrev;
			++k;
		}
		
		offsets.push({ start: start, count: i - start, index: minPrev });
		
		trace(offsets);
		
		var vertexData:VertexData = new VertexData();
			
		var vertices:Array<Float> = [];
		for (i in 0...newVertices.length) {
			vertices.push(newVertices[i]);
		}
		vertexData.positions = vertices;
		
		var normals:Array<Float> = [];
		if (file.body.normals != null) {
			for (i in 0...newNormals.length) {
				normals.push(newNormals[i]);
			}
			vertexData.normals = normals; 
		}
		
		if (file.body.uvMaps != null) {
			var uvs:Array<Float> = [];
			for (i in 0...newUvs.length) {
				uvs.push(newUvs[i]);
			}
			vertexData.uvs = uvs;
		}
		
		if (file.header.attrMapCount > 0 && file.body.attrMaps != null) {
			var colors:Array<Float> = [];
			for (i in 0...newColors.length) {
				colors.push(newColors[i]);
			}
			vertexData.colors = colors;
		}
			
		var indices2:Array<Int> = [];
		for (i in 0...indices.length) {
			indices2[i] = newFaces[i];
		}
		
		vertexData.indices = indices2;// .slice(offsets[0].start, offsets[0].count);
		
		//vertexData.positions = vertices.slice(offsets[0].index, offsets[1].index);
		
		//vertexData.normals = normals.slice(offsets[0].index, offsets[1].index);
		
		var mesh = new Mesh("camaro", scene);
		vertexData.applyToMesh(mesh);
		var mat = new StandardMaterial("camaromat", scene);
		mesh.flipFaces(true);
		//mat.backFaceCulling = false;
		//mat.wireframe = true;
		mesh.material = mat;	
		
	}
	
}
