package com.babylonhx.loading.obj;

import com.babylonhx.loading.obj.MtlLine.MtlHeader;
import com.babylonhx.loading.obj.ObjLine.ObjHeader;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

class ObjLoader {
	
	var lines:Array<ObjLine> = [];
		
	var positions:Array<Vector3> = [];
	var normals:Array<Vector3> = [];
	var textureCoordinates:Array<Vector2> = [];
	var stagingVertices:Array<PositionNormalTextured> = [];
	var stagingIndices:Array<Int> = [];
	var registeredVertices:Map<String, Int> = new Map<String, Int>();
	var meshParts:Map<String, PreMesh> = new Map<String, PreMesh>();
	
	var positionsIndexOffset:Int = 1;
	var normalsIndexOffset:Int = 1;
	var textureCoordinatesIndexOffset:Int = 1;
	
	var defaultMaterial:StandardMaterial = null;
	var materials:Map<String, StandardMaterial> = new Map<String, StandardMaterial>();
	
	var _scene:Scene;
	var _rootUrl:String;
	var _file:String;
	
	var _meshes:Array<Mesh> = [];
	public var meshes(get, never):Array<Mesh>;
	function get_meshes():Array<Mesh> {
		return _meshes;
	}
	
	var _subMeshesIndices:Array<Array<Int>> = []; 
	var _activeSubMesh:Int = 0;

	public function new(scene:Scene) {
		_subMeshesIndices.push([0, 0]);		
		_scene = scene;
	}
	
	public function load(rootUrl:String, file:String, ?onLoad:Array<Mesh>->Void) {
		this._rootUrl = rootUrl;
		this._file = file;
		
		Tools.LoadFile(rootUrl + file, function(content:String) {
			var _lns = content.split("\n");
			
			var currentProgression:Int = 0;
			var total:Int = _lns.length;
			var currentName:String = "";
			var currentMaterial:StandardMaterial = null;
			
			var mtlLine:ObjLine = null;
			for (l in _lns) {
				lines.push(new ObjLine(l));
				if (lines[lines.length - 1].header == ObjHeader.MaterialLibrary) {
					mtlLine = lines[lines.length - 1];
				}
			}
			
			var loadOBJ = function() {
				for (line in lines) {
					
					switch(line.header) {
						case ObjHeader.Object:
							currentName = line.tokens[1];
							appendNewPart(currentName, currentMaterial);
							
						case ObjHeader.Vertices:
							positions.push(line.toVector3());
							
						case ObjHeader.TextureCoordinates:
							textureCoordinates.push(line.toVector2());
							
						case ObjHeader.Normals:
							normals.push(line.toVector3());
							
						case ObjHeader.Group:
							currentName = line.tokens.length > 1 ? line.tokens[1] : "noname";
							
						case ObjHeader.Faces:
							appendFace(line);
							
						case ObjHeader.Material:
							var materialName:String = line.tokens[1];
							currentMaterial = materials.get(materialName);
							
						default:
					}
				}
				
				if (positions.length > 0) {
					appendNewPart(currentName, currentMaterial);
				}
				
				for (key in meshParts.keys()) {
					var newMesh:Mesh = meshParts.get(key).createMesh(_scene);		
					_meshes.push(newMesh);
				}
				
				if (onLoad != null) {
					onLoad(_meshes);
				}
			};
			
			if (mtlLine != null) {
				importMaterialLibrary(mtlLine, _scene, loadOBJ);
			}
			else {
				loadOBJ();
			}
		}, "");
	}
	
	function appendFace(line:ObjLine) {
		switch(line.tokens.length) {
			case 3:
				appendIndex(1, line);
				appendIndex(2, line);
				appendIndex(2, line);
				
			case 4:
				for (index in 1...4) {
					appendIndex(index, line);
				}
				
			case 5:
				/*for (index in 1...4) {
					appendIndex(index, line);
				}*/
				
				appendIndex(1, line);
				appendIndex(2, line);
				appendIndex(3, line);
				
				appendIndex(1, line);
				appendIndex(3, line);
				appendIndex(4, line);
				
		}
		
		/*// Line
		if (line.tokens.length == 3) {
			appendIndex(1, line);
			appendIndex(2, line);
			appendIndex(2, line);
			return;
		}
		
		// Triangle
		if (line.tokens.length == 4) {
			for (index in 1...4) {
				appendIndex(index, line);
			}
			
			return;
		}
		
		// Quad
		if (line.tokens.length == 5) {			
			appendIndex(1, line);
			appendIndex(2, line);
			appendIndex(3, line);
			
			appendIndex(1, line);
			appendIndex(3, line);
			appendIndex(4, line);
		}*/
	}

	function appendIndex(index:Int, line:ObjLine) {
		var indices:Array<String> = line.tokens[index].split('/');
		
		// Required: Position
		var positionIndex:Int = Std.parseInt(indices[0]) - positionsIndexOffset;
		var texCoordIndex:Int = -1;
		var normalIndex:Int = -1;
		
		// Optional: Texture coordinate
		if (indices.length > 1 && indices[1] != "") {
			texCoordIndex = Std.parseInt(indices[1]) - textureCoordinatesIndexOffset;
		}
		
		// Optional: Normal
		if (indices.length > 2 && indices[2] != "") {
			normalIndex = Std.parseInt(indices[2]) - normalsIndexOffset;
		}
		
		// Build vertex
		var vertex = new PositionNormalTextured(); 
		vertex.Position = positions[positionIndex];
		
		if (texCoordIndex >= 0) {
			vertex.TextureCoordinates = textureCoordinates[texCoordIndex];
		}
		
		if (normalIndex >= 0) {
			vertex.Normal = normals[normalIndex];
		}
		
		// check if the vertex does not already exists
		var hash:String = vertex.ToString();
		var vertexIndex:Int = 0;
		
		if(!registeredVertices.exists(hash)) {
			stagingVertices.push(vertex);
			vertexIndex = stagingVertices.length - 1;
			registeredVertices.set(hash, vertexIndex);
			_subMeshesIndices[_activeSubMesh][1] = vertexIndex;
		} 
		else {
			vertexIndex = registeredVertices.get(hash);
		}
		
		stagingIndices.push(vertexIndex);
	}
	
	function appendNewPart(name:String, currentMaterial:StandardMaterial) {
		if (stagingVertices.length == 0) {
			return;
		}
		
		if (currentMaterial == null) {
			if (defaultMaterial == null) {
				defaultMaterial = new StandardMaterial(name, _scene);
			}
			
			currentMaterial = defaultMaterial;
		}
		
		var part:PreMesh = null;
		
		if (!meshParts.exists(currentMaterial.name)) {
			part = new PreMesh(currentMaterial == defaultMaterial ? null : currentMaterial);
			meshParts.set(currentMaterial.name, part);
		} 
		else {
			part = meshParts.get(currentMaterial.name);
		}
		
		part.addPart(name, stagingVertices, stagingIndices);
		
		positionsIndexOffset += positions.length;
		positions = [];
		
		normalsIndexOffset += normals.length;
		normals = [];
		
		textureCoordinatesIndexOffset += textureCoordinates.length;
		textureCoordinates = [];
		
		stagingVertices = [];
		stagingIndices = [];
		registeredVertices = new Map<String, Int>();
	}
	
	function importMaterialLibrary(materialLine:ObjLine, scene:Scene, onComplete:Void->Void) {
		trace(materialLine);
		for (i in 1...materialLine.tokens.length) {
			var fileName = materialLine.tokens[i];
			
			Tools.LoadFile(_rootUrl + fileName, function(content:String) {
				var mtlLines:Array<String> = content.split("\n");
				
				var mtlDocument:Array<MtlLine> = [];			
				for (line in mtlLines) {
					mtlDocument.push(new MtlLine(line));
				}
				
				var currentMaterial:StandardMaterial = null;
				
				for (line in mtlDocument) {
					switch (line.header) {
						case MtlHeader.Material:
							currentMaterial = new StandardMaterial(line.tokens[1], scene);
							currentMaterial.backFaceCulling = true;
							materials.set(currentMaterial.name, currentMaterial);
							
						case MtlHeader.DiffuseColor:
							currentMaterial.diffuseColor = line.toColor3();
							
						case MtlHeader.DiffuseTexture:
							//currentMaterial.diffuseColor = new Color3(1, 1, 1);
							currentMaterial.diffuseTexture = new Texture(_rootUrl + line.tokens[1], scene);
							
						case MtlHeader.BumpTexture:
							currentMaterial.bumpTexture = new Texture(_rootUrl + line.tokens[1], scene);
							
						case MtlHeader.AmbientTexture:
							currentMaterial.ambientTexture = new Texture(_rootUrl + line.tokens[1], scene);
							
						case MtlHeader.SpecularTexture:
							currentMaterial.specularTexture = new Texture(_rootUrl + line.tokens[1], scene);
							
						case MtlHeader.ReflectionTexture:
							currentMaterial.reflectionTexture = new Texture(_rootUrl + line.tokens[1], scene);
							
						case MtlHeader.Alpha:
							currentMaterial.alpha = line.toFloat();
							
						case MtlHeader.AmbientColor:
							currentMaterial.ambientColor = line.toColor3();
							
						case MtlHeader.EmissiveColor:
							currentMaterial.emissiveColor = line.toColor3();
							
						case MtlHeader.SpecularColor:
							currentMaterial.specularColor = line.toColor3();
							
						case MtlHeader.SpecularPower:
							currentMaterial.specularPower = line.toFloat();
							
						default:
					}
				}
				
				if (onComplete != null) {
					onComplete();
				}
			}, "");			
		}
	}
	
}
