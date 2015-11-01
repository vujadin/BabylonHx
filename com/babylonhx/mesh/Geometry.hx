package com.babylonhx.mesh;

import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.tools.Tools;
import haxe.Json;

import com.babylonhx.utils.typedarray.Float32Array;


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
	public var _delayInfo:Array<String> = []; //ANY
	private var _indexBuffer:WebGLBuffer;
	public var _boundingInfo:BoundingInfo;
	public var _delayLoadingFunction:Dynamic->Geometry->Void;
	
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
			this.applyToMesh(mesh);
			mesh.computeWorldMatrix(true);
		}
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
			
			this._extend = Tools.ExtractMinAndMax(data, 0, this._totalVertices);
			
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
		this.notifyUpdate();
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
			
			var extend:BabylonMinMax = null;
			
			var stride = vertexBuffer.getStrideSize();
			this._totalVertices = cast data.length / stride;
			
			if (updateExtends) {
				this._extend = Tools.ExtractMinAndMax(data, 0, this._totalVertices);
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
		this.notifyUpdate();
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
                    this._extend = Tools.ExtractMinAndMax(this._vertexBuffers[kind].getData(), 0, this._totalVertices);
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

}
