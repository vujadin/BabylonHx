package com.babylonhx.mesh;

import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.Tags;

import haxe.Json;

import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Int32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Geometry') class Geometry implements IGetSetVerticesData {
	
	// Members
	public var id:String;
	public var delayLoadState = Engine.DELAYLOADSTATE_NONE;
	public var delayLoadingFile:String;
	public var onGeometryUpdated:Geometry->String->Void;

	// Private
	private var _scene:Scene;
	private var _engine:Engine;
	private var _meshes:Array<Mesh>;
	private var _totalVertices:Int = 0;
	private var _indices:Array<Int>;
	private var _vertexBuffers:Map<String, VertexBuffer>;
	private var _isDisposed:Bool = false;
	private var _extend:BabylonMinMax;
	private var _boundingBias:Vector2;
	public var _delayInfo:Array<String> = []; //ANY
	private var _indexBuffer:WebGLBuffer;
	public var _boundingInfo:BoundingInfo;
	public var _delayLoadingFunction:Dynamic->Geometry->Void;
	public var _softwareSkinningRenderId:Int = 0;
	
	public var boundingBias(get, set):Vector2;
	public var extend(get, never):BabylonMinMax;
	

	public function new(id:String, scene:Scene, ?vertexData:VertexData, updatable:Bool = false, ?mesh:Mesh) {
		this.id = id;
		this._engine = scene.getEngine();
		this._meshes = [];
		this._scene = scene;
		
		//Init vertex buffer cache
		this._vertexBuffers = new Map();
		this._indices = [];
		
		// vertexData
		if (vertexData != null) {
			this.setAllVerticesData(vertexData, updatable);
		} 
		else {
			this._totalVertices = 0;
		}
		
		// applyToMesh
		if (mesh != null) {
			if (Std.is(mesh, LinesMesh)) {
				this.boundingBias = new Vector2(0, cast(mesh, LinesMesh).intersectionThreshold);
				
				this.updateBoundingInfo(true, null);
			}
			
			this.applyToMesh(mesh);
			mesh.computeWorldMatrix(true);
		}
	}
	
	/**
	 *  The Bias Vector to apply on the bounding elements (box/sphere), the max extend is computed as v += v * bias.x + bias.y, the min is computed as v -= v * bias.x + bias.y 
	 * @returns The Bias Vector 
	 */
	private function get_boundingBias():Vector2 {
		return this._boundingBias;
	}
	private function set_boundingBias(value:Vector2):Vector2 {
		if (this._boundingBias != null && this._boundingBias.equals(value)) {
			return value;
		}
		
		this._boundingBias = value.clone();
		this.updateExtend();
		
		return value;
	}
	
	private function get_extend():BabylonMinMax {
		return this._extend;
	}

	inline public function getScene():Scene {
		return this._scene;
	}

	inline public function getEngine():Engine {
		return this._engine;
	}

	inline public function isReady():Bool {
		return this.delayLoadState == Engine.DELAYLOADSTATE_LOADED || this.delayLoadState == Engine.DELAYLOADSTATE_NONE;
	}

	public function setAllVerticesData(vertexData:VertexData, updatable:Bool = false) {
		vertexData.applyToGeometry(this, updatable);
		this.notifyUpdate();
	}

	public function setVerticesData(kind:String, data:Array<Float>, updatable:Bool = false, ?stride:Int) {		
		if (this._vertexBuffers.exists(kind)) {
			this._vertexBuffers[kind].dispose();
		}
		
		this._vertexBuffers.set(kind, new VertexBuffer(this._engine, data, kind, updatable, this._meshes.length == 0, stride));
		
		if (kind == VertexBuffer.PositionKind) {
			stride = this._vertexBuffers[kind].getStrideSize();
			
			this._totalVertices = cast data.length / stride;
			
			this.updateExtend(data);
			
			var meshes = this._meshes;
			var numOfMeshes = meshes.length;
			
			for (index in 0...numOfMeshes) {
				var mesh = meshes[index];
				mesh._resetPointsArrayCache();
				mesh._boundingInfo = new BoundingInfo(this._extend.minimum, this._extend.maximum);
				mesh._createGlobalSubMesh();
				mesh.computeWorldMatrix(true);
			}
		}
		
		this.notifyUpdate(kind);
	}

	inline public function updateVerticesDataDirectly(kind:String, data:Float32Array, offset:Int) {
		var vertexBuffer = this.getVertexBuffer(kind);
		
		if (vertexBuffer != null) {
			vertexBuffer.updateDirectly(data, offset);
			this.notifyUpdate();
		}		
	}

	public function updateVerticesData(kind:String, data:Array<Float>, updateExtends:Bool = false, makeItUnique:Bool = false) {
		var vertexBuffer = this.getVertexBuffer(kind);
		
		if (vertexBuffer == null) {
			return;
		}
		
		vertexBuffer.update(data);
		
		if (kind == VertexBuffer.PositionKind) {
			
			var stride = vertexBuffer.getStrideSize();
			this._totalVertices = cast data.length / stride;
			
			if (updateExtends) {
				this.updateExtend(data);
			}
			
			this.updateBoundingInfo(updateExtends, data);
		}
		
		this.notifyUpdate(kind);
	}
	
	private function updateBoundingInfo(updateExtends:Bool, ?data:Array<Float>) {
		if (updateExtends) {
			this.updateExtend(data);
		}
		
		var meshes = this._meshes;
		var numOfMeshes = meshes.length;
		
		for (index in 0...numOfMeshes) {
			var mesh = meshes[index];
			mesh._resetPointsArrayCache();
			if (updateExtends) {
				mesh._boundingInfo = new BoundingInfo(this._extend.minimum, this._extend.maximum);
				
				for (subIndex in 0...mesh.subMeshes.length) {
					var subMesh = mesh.subMeshes[subIndex];
					
					subMesh.refreshBoundingInfo();
				}
			}
		}            
	}

	public function getTotalVertices():Int {
		if (!this.isReady()) {
			return 0;
		}
		
		return this._totalVertices;
	}

	public function getVerticesData(kind:String, copyWhenShared:Bool = false):Array<Float> {
		var vertexBuffer:VertexBuffer = this.getVertexBuffer(kind);
		if (vertexBuffer == null) {
			return null;
		}
		
		var orig:Array<Float> = vertexBuffer.getData();
		if (!copyWhenShared || this._meshes.length == 1){
			return orig;
		}
		else {
			var len = orig.length;
			var copy:Array<Float> = [];
			for (i in 0...len) {
				copy.push(orig[i]);
			}
			
			return copy;
		}
	}

	public function getVertexBuffer(kind:String):VertexBuffer {
		if (!this.isReady()) {
			return null;
		}
		
		return this._vertexBuffers[kind];
	}

	public function getVertexBuffers():Map<String, VertexBuffer> {
		if (!this.isReady()) {
			return null;
		}
		return this._vertexBuffers;
	}

	public function isVerticesDataPresent(kind:String):Bool {
		if (this._vertexBuffers == null) {
			if (this._delayInfo != null) {
				return this._delayInfo.indexOf(kind) != -1;
			}
			return false;
		}
		return this._vertexBuffers[kind] != null;
	}

	public function getVerticesDataKinds():Array<String> {
		var result:Array<String> = [];
		if (this._vertexBuffers == null && this._delayInfo != null) {
			for (kind in this._delayInfo) {
				result.push(kind);
			}
		} 
		else {
			for (kind in this._vertexBuffers.keys()) {
				result.push(kind);
			}
		}
		
		return result;
	}

	public function setIndices(indices:Array<Int>, totalVertices:Int = -1) {
		if (this._indexBuffer != null) {
			this._engine._releaseBuffer(this._indexBuffer);
		}
		
		this._indices = indices;
		if (this._meshes.length != 0 && this._indices != null) {
			this._indexBuffer = this._engine.createIndexBuffer(this._indices);
		}
		
		if (totalVertices != -1) {
			this._totalVertices = totalVertices;
		}
		
		var meshes = this._meshes;
		var numOfMeshes = meshes.length;
		
		for (index in 0...numOfMeshes) {
			meshes[index]._createGlobalSubMesh();
		}
		
		this.notifyUpdate();
	}

	public function getTotalIndices():Int {
		if (!this.isReady()) {
			return 0;
		}
		return this._indices.length;
	}

	public function getIndices(copyWhenShared:Bool = false):Array<Int> {
		if (!this.isReady()) {
			return null;
		}
		
		var orig = this._indices;
		
		if (!copyWhenShared || this._meshes.length == 1) {
			return orig;
		}
		else {
			var len = orig.length;
			var copy:Array<Int> = [];
			for (i in 0...len) {
				copy.push(orig[i]);
			}
			
			return copy;
		}
	}

	public function getIndexBuffer():WebGLBuffer {
		if (!this.isReady()) {
			return null;
		}
		return this._indexBuffer;
	}

	public function releaseForMesh(mesh:Mesh, shouldDispose:Bool = false) {
		var meshes = this._meshes;
		var index = meshes.indexOf(mesh);
		
		if (index == -1) {
			return;
		}
		
		for (key in this._vertexBuffers.keys()) {
			this._vertexBuffers[key].dispose();
		}
		
		if (this._indexBuffer != null && this._engine._releaseBuffer(this._indexBuffer)) {
			this._indexBuffer = null;
		}
		
		meshes.splice(index, 1);
		
		mesh._geometry = null;
		
		if (meshes.length == 0 && shouldDispose) {
			this.dispose();
		}
	}

	public function applyToMesh(mesh:Mesh) {
		if (mesh._geometry == this) {
			return;
		}
		
		var previousGeometry = mesh._geometry;
		if (previousGeometry != null) {
			previousGeometry.releaseForMesh(mesh);
		}
		
		var meshes = this._meshes;
		
		// must be done before setting vertexBuffers because of mesh._createGlobalSubMesh()
		mesh._geometry = this;
		
		this._scene.pushGeometry(this);
		
		meshes.push(mesh);
		
		if (this.isReady()) {
			this._applyToMesh(mesh);
		} 
		else {
			mesh._boundingInfo = this._boundingInfo;
		}
	}
	
	private function updateExtend(data:Array<Float> = null) {
		if (data == null) {
			data = this._vertexBuffers[VertexBuffer.PositionKind].getData();
		}
		
		this._extend = Tools.ExtractMinAndMax(data, 0, this._totalVertices, this.boundingBias);
	}

	private function _applyToMesh(mesh:Mesh) {
		var numOfMeshes = this._meshes.length;
		
		// vertexBuffers
		for (kind in this._vertexBuffers.keys()) {
			if (numOfMeshes == 1) {
				this._vertexBuffers[kind].create();
			}
			this._vertexBuffers[kind]._buffer.references = numOfMeshes;
			
			if (kind == VertexBuffer.PositionKind) {
				mesh._resetPointsArrayCache();
				
				if (this._extend == null) {
                    this.updateExtend(this._vertexBuffers[kind].getData());
                }
                mesh._boundingInfo = new BoundingInfo(this._extend.minimum, this._extend.maximum);
				
				mesh._createGlobalSubMesh();
				
				//bounding info was just created again, world matrix should be applied again.
                mesh._updateBoundingInfo();
			}
		}
		
		// indexBuffer
		if (numOfMeshes == 1 && this._indices != null) {
			this._indexBuffer = this._engine.createIndexBuffer(this._indices);
		}
		if (this._indexBuffer != null) {
			this._indexBuffer.references = numOfMeshes;
		}
	}
	
	private function notifyUpdate(?kind:String) {
		if (this.onGeometryUpdated != null) {
			this.onGeometryUpdated(this, kind);
		}
	}

	public function load(scene:Scene, ?onLoaded:Void->Void) {
		if (this.delayLoadState == Engine.DELAYLOADSTATE_LOADING) {
			return;
		}
		
		if (this.isReady()) {
			if (onLoaded != null) {
				onLoaded();
			}
			
			return;
		}
		
		this.delayLoadState = Engine.DELAYLOADSTATE_LOADING;
		
		scene._addPendingData(this);
		/*Tools.LoadFile(this.delayLoadingFile, function(data) {
			this._delayLoadingFunction(Json.parse(data), this);

			this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
			this._delayInfo = [];

			scene._removePendingData(this);

			var meshes = this._meshes;
			var numOfMeshes = meshes.length;
			for (index in 0...numOfMeshes) {
				this._applyToMesh(meshes[index]);
			}

			if (onLoaded != null) {
				onLoaded();
			}
		}, function() { }, scene.database);*/
	}
	
	public function isDisposed():Bool {
		return this._isDisposed;
	}

	public function dispose() {
		var meshes = this._meshes;
		var numOfMeshes = meshes.length;
		
		for (index in 0...numOfMeshes) {
			this.releaseForMesh(meshes[index]);
		}
		this._meshes = [];
		
		for (kind in this._vertexBuffers.keys()) {
			this._vertexBuffers[kind].dispose();
		}
		this._vertexBuffers = new Map<String, VertexBuffer>();
		this._totalVertices = 0;
		
		if (this._indexBuffer != null) {
			this._engine._releaseBuffer(this._indexBuffer);
		}
		this._indexBuffer = null;
		this._indices = [];
		
		this.delayLoadState = Engine.DELAYLOADSTATE_NONE;
		this.delayLoadingFile = null;
		this._delayLoadingFunction = null;
		this._delayInfo = [];
		
		this._boundingInfo = null; // todo:.dispose()
		
		this._scene.removeGeometry(this);
		
		this._isDisposed = true;
	}

	public function copy(id:String):Geometry {
		var vertexData = new VertexData();
		
		vertexData.indices = [];
		
		var indices = this.getIndices();
		for (index in 0...indices.length) {
			vertexData.indices.push(indices[index]);
		}
		
		var updatable = false;
		var stopChecking = false;
		
		for (kind in this._vertexBuffers.keys()) {
			vertexData.set(this.getVerticesData(kind).copy(), kind);
			
			if (!stopChecking) {
				updatable = this.getVertexBuffer(kind).isUpdatable();
				stopChecking = !updatable;
			}
		}
		
		var geometry = new Geometry(id, this._scene, vertexData, updatable, null);
		
		geometry.delayLoadState = this.delayLoadState;
		geometry.delayLoadingFile = this.delayLoadingFile;
		geometry._delayLoadingFunction = this._delayLoadingFunction;
		
		for (kind in this._delayInfo) {
			geometry._delayInfo = geometry._delayInfo != null ? geometry._delayInfo : [];
			geometry._delayInfo.push(kind);
		}
		
		// Bounding info
		geometry._boundingInfo = new BoundingInfo(this._extend.minimum, this._extend.maximum);
		
		return geometry;
	}

	// Statics
	public static function ExtractFromMesh(mesh:Mesh, id:String):Geometry {
		var geometry = mesh._geometry;
		
		if (geometry == null) {
			return null;
		}
		
		return geometry.copy(id);
	}
	
	static var UID_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

	public static function RandomId(size:Int = 32):String {
		var nchars = UID_CHARS.length;
		var uid = new StringBuf();
		for (i in 0...size){
			uid.add(UID_CHARS.charAt(Std.int(Math.random() * nchars)));
		}
		return uid.toString();
	}
	
	public static function ImportGeometry(parsedGeometry:Dynamic, mesh:Mesh) {
		var scene = mesh.getScene();
		
		// Geometry
		var geometryId = parsedGeometry.geometryId;
		if (geometryId != null) {
			var geometry = scene.getGeometryByID(geometryId);
			if (geometry != null) {
				geometry.applyToMesh(mesh);
			}
		} 
		/*else if (Std.is(parsedGeometry, ArrayBufferView)) {
			
			var binaryInfo = mesh._binaryInfo;
			
			// VK TODO
			if (binaryInfo.positionsAttrDesc != null && binaryInfo.positionsAttrDesc.count > 0) {
				var positionsData = new Float32Array(parsedGeometry, binaryInfo.positionsAttrDesc.offset, binaryInfo.positionsAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.PositionKind, positionsData, false);
			}
			
			if (binaryInfo.normalsAttrDesc != null && binaryInfo.normalsAttrDesc.count > 0) {
				var normalsData = new Float32Array(parsedGeometry, binaryInfo.normalsAttrDesc.offset, binaryInfo.normalsAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.NormalKind, normalsData, false);
			}
			
			if (binaryInfo.uvsAttrDesc != null && binaryInfo.uvsAttrDesc.count > 0) {
				var uvsData = new Float32Array(parsedGeometry, binaryInfo.uvsAttrDesc.offset, binaryInfo.uvsAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.UVKind, uvsData, false);
			}
			
			if (binaryInfo.uvs2AttrDesc != null && binaryInfo.uvs2AttrDesc.count > 0) {
				var uvs2Data = new Float32Array(parsedGeometry, binaryInfo.uvs2AttrDesc.offset, binaryInfo.uvs2AttrDesc.count);
				mesh.setVerticesData(VertexBuffer.UV2Kind, uvs2Data, false);
			}
			
			if (binaryInfo.uvs3AttrDesc != null && binaryInfo.uvs3AttrDesc.count > 0) {
				var uvs3Data = new Float32Array(parsedGeometry, binaryInfo.uvs3AttrDesc.offset, binaryInfo.uvs3AttrDesc.count);
				mesh.setVerticesData(VertexBuffer.UV3Kind, uvs3Data, false);
			}
			
			if (binaryInfo.uvs4AttrDesc != null && binaryInfo.uvs4AttrDesc.count > 0) {
				var uvs4Data = new Float32Array(parsedGeometry, binaryInfo.uvs4AttrDesc.offset, binaryInfo.uvs4AttrDesc.count);
				mesh.setVerticesData(VertexBuffer.UV4Kind, uvs4Data, false);
			}
			
			if (binaryInfo.uvs5AttrDesc != null && binaryInfo.uvs5AttrDesc.count > 0) {
				var uvs5Data = new Float32Array(parsedGeometry, binaryInfo.uvs5AttrDesc.offset, binaryInfo.uvs5AttrDesc.count);
				mesh.setVerticesData(VertexBuffer.UV5Kind, uvs5Data, false);
			}
			
			if (binaryInfo.uvs6AttrDesc != null && binaryInfo.uvs6AttrDesc.count > 0) {
				var uvs6Data = new Float32Array(parsedGeometry, binaryInfo.uvs6AttrDesc.offset, binaryInfo.uvs6AttrDesc.count);
				mesh.setVerticesData(VertexBuffer.UV6Kind, uvs6Data, false);
			}
			
			if (binaryInfo.colorsAttrDesc != null && binaryInfo.colorsAttrDesc.count > 0) {
				var colorsData = new Float32Array(parsedGeometry, binaryInfo.colorsAttrDesc.offset, binaryInfo.colorsAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.ColorKind, colorsData, false, binaryInfo.colorsAttrDesc.stride);
			}
			
			if (binaryInfo.matricesIndicesAttrDesc != null && binaryInfo.matricesIndicesAttrDesc.count > 0) {
				var matricesIndicesData = new Int32Array(parsedGeometry, binaryInfo.matricesIndicesAttrDesc.offset, binaryInfo.matricesIndicesAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, matricesIndicesData, false);
			}
			
			if (binaryInfo.matricesWeightsAttrDesc != null && binaryInfo.matricesWeightsAttrDesc.count > 0) {
				var matricesWeightsData = new Float32Array(parsedGeometry, binaryInfo.matricesWeightsAttrDesc.offset, binaryInfo.matricesWeightsAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.MatricesWeightsKind, matricesWeightsData, false);
			}
			
			if (binaryInfo.indicesAttrDesc != null && binaryInfo.indicesAttrDesc.count > 0) {
				var indicesData = new Int32Array(parsedGeometry, binaryInfo.indicesAttrDesc.offset, binaryInfo.indicesAttrDesc.count);
				mesh.setIndices(indicesData);
			}
			
			if (binaryInfo.subMeshesAttrDesc != null && binaryInfo.subMeshesAttrDesc.count > 0) {
				var subMeshesData = new Int32Array(parsedGeometry, binaryInfo.subMeshesAttrDesc.offset, binaryInfo.subMeshesAttrDesc.count * 5);
				
				mesh.subMeshes = [];
				for (i in 0...binaryInfo.subMeshesAttrDesc.count) {
					var materialIndex = subMeshesData[(i * 5) + 0];
					var verticesStart = subMeshesData[(i * 5) + 1];
					var verticesCount = subMeshesData[(i * 5) + 2];
					var indexStart = subMeshesData[(i * 5) + 3];
					var indexCount = subMeshesData[(i * 5) + 4];
					
					var subMesh = new SubMesh(materialIndex, verticesStart, verticesCount, indexStart, indexCount, mesh);
				}
			}
		} 
		else*/ if (parsedGeometry.positions != null && parsedGeometry.normals != null && parsedGeometry.indices != null) {
			mesh.setVerticesData(VertexBuffer.PositionKind, parsedGeometry.positions, false);
			mesh.setVerticesData(VertexBuffer.NormalKind, parsedGeometry.normals, false);
			
			if (parsedGeometry.uvs != null) {
				mesh.setVerticesData(VertexBuffer.UVKind, parsedGeometry.uvs, false);
			}
			
			if (parsedGeometry.uvs2 != null) {
				mesh.setVerticesData(VertexBuffer.UV2Kind, parsedGeometry.uvs2, false);
			}
			
			if (parsedGeometry.uvs3 != null) {
				mesh.setVerticesData(VertexBuffer.UV3Kind, parsedGeometry.uvs3, false);
			}
			
			if (parsedGeometry.uvs4 != null) {
				mesh.setVerticesData(VertexBuffer.UV4Kind, parsedGeometry.uvs4, false);
			}
			
			if (parsedGeometry.uvs5 != null) {
				mesh.setVerticesData(VertexBuffer.UV5Kind, parsedGeometry.uvs5, false);
			}
			
			if (parsedGeometry.uvs6 != null) {
				mesh.setVerticesData(VertexBuffer.UV6Kind, parsedGeometry.uvs6, false);
			}
			
			if (parsedGeometry.colors != null) {
				mesh.setVerticesData(VertexBuffer.ColorKind, Color4.CheckColors4(parsedGeometry.colors, Std.int(parsedGeometry.positions.length / 3)), false);
			}
			
			if (parsedGeometry.matricesIndices != null) {
				if (!parsedGeometry.matricesIndices._isExpanded) {
					var floatIndices:Array<Int> = [];
					
					for (i in 0...parsedGeometry.matricesIndices.length) {
						var matricesIndex = parsedGeometry.matricesIndices[i];
						
						floatIndices.push(matricesIndex & 0x000000FF);
						floatIndices.push((matricesIndex & 0x0000FF00) >> 8);
						floatIndices.push((matricesIndex & 0x00FF0000) >> 16);
						floatIndices.push(matricesIndex >> 24);
					}
					
					mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, cast floatIndices, false);
				} 
				else {
					parsedGeometry.matricesIndices._isExpanded = null;
					mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, parsedGeometry.matricesIndices, false);
				}
			}
			
			if (parsedGeometry.matricesIndicesExtra != null) {
				if (!parsedGeometry.matricesIndicesExtra._isExpanded) {
					var floatIndices:Array<Int> = [];
					
					for (i in 0...parsedGeometry.matricesIndicesExtra.length) {
						var matricesIndex = parsedGeometry.matricesIndicesExtra[i];
						
						floatIndices.push(matricesIndex & 0x000000FF);
						floatIndices.push((matricesIndex & 0x0000FF00) >> 8);
						floatIndices.push((matricesIndex & 0x00FF0000) >> 16);
						floatIndices.push(matricesIndex >> 24);
					}
					
					mesh.setVerticesData(VertexBuffer.MatricesIndicesExtraKind, cast floatIndices, false);
				} 
				else {
					parsedGeometry.matricesIndices._isExpanded = null;
					mesh.setVerticesData(VertexBuffer.MatricesIndicesExtraKind, parsedGeometry.matricesIndicesExtra, false);
				}
			}
			
			if (parsedGeometry.matricesWeights != null) {
				mesh.setVerticesData(VertexBuffer.MatricesWeightsKind, parsedGeometry.matricesWeights, false);
			}
			
			if (parsedGeometry.matricesWeightsExtra != null) {
				mesh.setVerticesData(VertexBuffer.MatricesWeightsExtraKind, parsedGeometry.matricesWeightsExtra, false);
			}
			
			mesh.setIndices(parsedGeometry.indices);
		}
		
		// SubMeshes
		if (parsedGeometry.subMeshes != null) {
			mesh.subMeshes = [];
			for (subIndex in 0...parsedGeometry.subMeshes.length) {
				var parsedSubMesh = parsedGeometry.subMeshes[subIndex];
				
				var subMesh = new SubMesh(parsedSubMesh.materialIndex, parsedSubMesh.verticesStart, parsedSubMesh.verticesCount, parsedSubMesh.indexStart, parsedSubMesh.indexCount, mesh);
			}
		}
		
		// Flat shading
		if (mesh._shouldGenerateFlatShading) {
			mesh.convertToFlatShadedMesh();
			mesh._shouldGenerateFlatShading = false;
		}
		
		// Update
		mesh.computeWorldMatrix(true);
		
		// Octree
		if (scene.SelectionOctree != null) {
			scene.SelectionOctree.addMesh(mesh);
		}
	}
	
	public static function Parse(parsedVertexData:Dynamic, scene:Scene, rootUrl:String = ""):Geometry {
        if (scene.getGeometryByID(parsedVertexData.id) != null) {
            return null; // null since geometry could be a primitive
        }
		
        var geometry = new Geometry(parsedVertexData.id, scene);
		
        Tags.AddTagsTo(geometry, parsedVertexData.tags);
		
        if (parsedVertexData.delayLoadingFile != null && parsedVertexData.delayLoadingFile != "") {
            geometry.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
            geometry.delayLoadingFile = rootUrl + parsedVertexData.delayLoadingFile;
            geometry._boundingInfo = new BoundingInfo(Vector3.FromArray(parsedVertexData.boundingBoxMinimum), Vector3.FromArray(parsedVertexData.boundingBoxMaximum));
			
            geometry._delayInfo = [];
            if (parsedVertexData.hasUVs == true) {
                geometry._delayInfo.push(VertexBuffer.UVKind);
            }
			
            if (parsedVertexData.hasUVs2 == true) {
                geometry._delayInfo.push(VertexBuffer.UV2Kind);
            }
			
			if (parsedVertexData.hasUVs3 == true) {
                geometry._delayInfo.push(VertexBuffer.UV3Kind);
            }
			
            if (parsedVertexData.hasUVs4 == true) {
                geometry._delayInfo.push(VertexBuffer.UV4Kind);
            }
			
            if (parsedVertexData.hasUVs5 == true) {
                geometry._delayInfo.push(VertexBuffer.UV5Kind);
            }
			
            if (parsedVertexData.hasUVs6 == true) {
                geometry._delayInfo.push(VertexBuffer.UV6Kind);
            }
			
            if (parsedVertexData.hasColors == true) {
                geometry._delayInfo.push(VertexBuffer.ColorKind);
            }
			
            if (parsedVertexData.hasMatricesIndices == true) {
                geometry._delayInfo.push(VertexBuffer.MatricesIndicesKind);
            }
			
            if (parsedVertexData.hasMatricesWeights == true) {
                geometry._delayInfo.push(VertexBuffer.MatricesWeightsKind);
            }
			
            geometry._delayLoadingFunction = VertexData.ImportVertexData;
        } 
		else {
            VertexData.ImportVertexData(parsedVertexData, geometry);
        }
		
        scene.pushGeometry(geometry, true);
		
        return geometry;
    }

}
