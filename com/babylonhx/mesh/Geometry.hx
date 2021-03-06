package com.babylonhx.mesh;

import com.babylonhx.engine.Engine;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.math.Tools.BabylonMinMax;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.tools.Tags;
import com.babylonhx.materials.Effect;

import haxe.Json;

import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;
import com.babylonhx.utils.GL.GLVertexArrayObject;


/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Class used to store geometry data (vertex buffers + index buffer)
 */
@:expose('BABYLON.Geometry') class Geometry implements IGetSetVerticesData {
	
	// Members
	/**
	 * The unique ID of the geometry
	 */
	public var id:String;
	/**
	 * Delay loading state of the geometry (none by default which means not delayed)
	 */
	public var delayLoadState = Engine.DELAYLOADSTATE_NONE;
	/**
	 * File containing the data to load when running in delay load state
	 */
	public var delayLoadingFile:String;
	/**
	 * Callback called when the geometry is updated
	 */
	public var onGeometryUpdated:Geometry->Null<String>->Void;

	// Private
	private var _scene:Scene;
	private var _engine:Engine;
	private var _meshes:Array<Mesh>;
	private var _totalVertices:Int = 0;
	private var _indices:UInt32Array;
	private var _vertexBuffers:Map<String, VertexBuffer>;
	private var _isDisposed:Bool = false;
	private var _extend:BabylonMinMax;
	private var _boundingBias:Vector2 = null;
	public var _delayInfo:Array<String> = []; //ANY
	private var _indexBuffer:WebGLBuffer;
	private var _indexBufferIsUpdatable:Bool = false;
	public var _boundingInfo:BoundingInfo;
	public var _delayLoadingFunction:Dynamic->Geometry->Void;
	public var _softwareSkinningRenderId:Int = 0;
	private var _vertexArrayObjects:Map<String, GLVertexArrayObject>;
	private var _updatable:Bool;
	
	// Cache
	public var _positions:Array<Vector3>;
	
	
	/**
	 * The Bias Vector to apply on the bounding elements (box/sphere), 
	 * the max extend is computed as v += v * bias.x + bias.y, the min is computed as v -= v * bias.x + bias.y
	 * @returns The Bias Vector
	 */
	public var boundingBias(get, set):Vector2;
	inline private function get_boundingBias():Vector2 {
		return this._boundingBias;
	}
	private function set_boundingBias(value:Vector2):Vector2 {
		if (this._boundingBias != null && this._boundingBias.equals(value)) {
			return value;
		}
		
		this._boundingBias = value.clone();
		
		this.updateBoundingInfo(true, null);
		
		return value;
	}
	
	/**
	 * Static function used to attach a new empty geometry to a mesh
	 * @param mesh defines the mesh to attach the geometry to
	 * @returns the new {BABYLON.Geometry}
	 */
	public static function CreateGeometryForMesh(mesh:Mesh):Geometry {
		var geometry = new Geometry(Tools.uuid(), mesh.getScene());
		
		geometry.applyToMesh(mesh);
		
		return geometry;
	}
	

	/**
	 * Creates a new geometry
	 * @param id defines the unique ID
	 * @param scene defines the hosting scene
	 * @param vertexData defines the {BABYLON.VertexData} used to get geometry data
	 * @param updatable defines if geometry must be updatable (false by default)
	 * @param mesh defines the mesh that will be associated with the geometry
	 */
	public function new(id:String, scene:Scene, ?vertexData:VertexData, updatable:Bool = false, ?mesh:Mesh) {
		this.id = id;
		this._engine = scene.getEngine();
		this._meshes = [];
		this._scene = scene;		
		//Init vertex buffer cache
		this._vertexBuffers = new Map();
		this._indices = new UInt32Array(0);
		this._updatable = updatable;
		
		// vertexData
		if (vertexData != null) {
			this.setAllVerticesData(vertexData, updatable);
		} 
		else {
			this._totalVertices = 0;
		}
		
		if (this._engine.getCaps().vertexArrayObject) {
			this._vertexArrayObjects = new Map();
		}
		
		// applyToMesh
		if (mesh != null) {
			if (mesh.getClassName() == 'LinesMesh') {
				this.boundingBias = new Vector2(0, cast(mesh, LinesMesh).intersectionThreshold);
				this.updateExtend();
			}
			
			this.applyToMesh(mesh);
			mesh.computeWorldMatrix(true);
		}
	}
	
	/**
	 * Gets the current extend of the geometry
	 */
	public var extend(get, never):BabylonMinMax;
	private function get_extend():BabylonMinMax {
		return this._extend;
	}
	
	/**
	 * Gets the hosting scene
	 * @returns the hosting {BABYLON.Scene}
	 */
	inline public function getScene():Scene {
		return this._scene;
	}

	/**
	 * Gets the hosting engine
	 * @returns the hosting {BABYLON.Engine}
	 */
	inline public function getEngine():Engine {
		return this._engine;
	}

	/**
	 * Defines if the geometry is ready to use
	 * @returns true if the geometry is ready to be used
	 */
	inline public function isReady():Bool {
		return this.delayLoadState == Engine.DELAYLOADSTATE_LOADED || this.delayLoadState == Engine.DELAYLOADSTATE_NONE;
	}
	
	/**
	 * Gets a value indicating that the geometry should not be serialized
	 */
	public var doNotSerialize(get, never):Bool;
	private function get_doNotSerialize():Bool {
		for (index in 0...this._meshes.length) {
			if (!this._meshes[index].doNotSerialize) {
				return false;
			}
		}
		
		return true;
	}
	
	public function _rebuild() {
		if (this._vertexArrayObjects != null) {
			this._vertexArrayObjects = new Map<String, GLVertexArrayObject>();
		}
		
		// Index buffer
		if (this._meshes.length != 0 && this._indices != null) {
			this._indexBuffer = this._engine.createIndexBuffer(this._indices);
		}
		
		// Vertex buffers
		for (key in this._vertexBuffers.keys()) {
			var vertexBuffer:VertexBuffer = this._vertexBuffers[key];
			vertexBuffer._rebuild();
		}
	}

	/**
	 * Affects all gemetry data in one call
	 * @param vertexData defines the geometry data
	 * @param updatable defines if the geometry must be flagged as updatable (false as default)
	 */
	public function setAllVerticesData(vertexData:VertexData, updatable:Bool = false) {
		vertexData.applyToGeometry(this, updatable);
		this.notifyUpdate();
	}

	/**
	 * Set specific vertex data
	 * @param kind defines the data kind (Position, normal, etc...)
	 * @param data defines the vertex data to use
	 * @param updatable defines if the vertex must be flagged as updatable (false as default)
	 * @param stride defines the stride to use (0 by default). This value is deduced from the kind value if not specified
	 */
	public function setVerticesData(kind:String, data:Float32Array, updatable:Bool = false, ?stride:Int) {		
		var buffer = new VertexBuffer(this._engine, data, kind, updatable, this._meshes.length == 0, stride);
		
		this.setVerticesBuffer(buffer);
	}
	
	/**
	 * Removes a specific vertex data
	 * @param kind defines the data kind (Position, normal, etc...)
	 */
	public function removeVerticesData(kind:String) {
		if (this._vertexBuffers[kind] != null) {
			this._vertexBuffers[kind].dispose();
			this._vertexBuffers.remove(kind);
		}
	}
	
	/**
	 * Affect a vertex buffer to the geometry. the vertexBuffer.getKind() function is used to determine where to store the data
	 * @param buffer defines the vertex buffer to use
	 */
	public function setVerticesBuffer(buffer:VertexBuffer) {
		var kind = buffer.getKind();
		if (this._vertexBuffers[kind] != null) {
			this._vertexBuffers[kind].dispose();
		}
		
		this._vertexBuffers[kind] = buffer;
		
		if (kind == VertexBuffer.PositionKind) {
			var data = buffer.getData();
			var stride = buffer.getStrideSize();
			
			this._totalVertices = Std.int(data.length / stride);
			
			this.updateExtend(data, stride);
			this._resetPointsArrayCache();
			
			var meshes = this._meshes;
			var numOfMeshes = meshes.length;
			
			for (index in 0...numOfMeshes) {
				var mesh = meshes[index];
				mesh._resetPointsArrayCache();
				mesh._boundingInfo = new BoundingInfo(this._extend.minimum, this._extend.maximum);
				mesh._createGlobalSubMesh(false);
				mesh.computeWorldMatrix(true);
			}
		}
		
		this.notifyUpdate(kind);
		
		if (this._vertexArrayObjects != null) {
			this._disposeVertexArrayObjects();
			this._vertexArrayObjects = new Map(); // Will trigger a rebuild of the VAO if supported
		}
	}

	/**
	 * Update a specific vertex buffer
	 * This function will directly update the underlying WebGLBuffer according to the passed numeric array or Float32Array
	 * It will do nothing if the buffer is not updatable
	 * @param kind defines the data kind (Position, normal, etc...)
	 * @param data defines the data to use 
	 * @param offset defines the offset in the target buffer where to store the data
	 */
	inline public function updateVerticesDataDirectly(kind:String, data:Float32Array, offset:Int) {
		var vertexBuffer = this.getVertexBuffer(kind);
		
		if (vertexBuffer == null) {
			return;
		}
		
		vertexBuffer.updateDirectly(data, offset);
		this.notifyUpdate();
	}
	
	/**
	 * Update a specific vertex buffer
	 * This function will create a new buffer if the current one is not updatable
	 * @param kind defines the data kind (Position, normal, etc...)
	 * @param data defines the data to use 
	 * @param updateExtends defines if the geometry extends must be recomputed (false by default)
	 */ 
	// BHX: makeItUnique required by IGetSetVerticesData
	public function updateVerticesData(kind:String, data:Float32Array, updateExtends:Bool = false, makeItUnique:Bool = false) {
		var vertexBuffer = this.getVertexBuffer(kind);
		
		if (vertexBuffer == null) {
			return;
		}
		
		vertexBuffer.update(data);
		
		if (kind == VertexBuffer.PositionKind) {			
			var stride = vertexBuffer.getStrideSize();
			this._totalVertices = cast data.length / stride;
			
			this.updateBoundingInfo(updateExtends, data);
		}
		
		this.notifyUpdate(kind);
	}
	
	private function updateBoundingInfo(updateExtends:Bool, ?data:Float32Array) {
		if (updateExtends) {
			this.updateExtend(data);
		}
		
		var meshes = this._meshes;
		var numOfMeshes = meshes.length;
		this._resetPointsArrayCache();
		
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
	
	public function _bind(effect:Effect, indexToBind:WebGLBuffer = null) {
		if (effect == null) {
			return;
		}
		
		if (indexToBind == null) {
			indexToBind = this._indexBuffer;
		}
		var vbs = this.getVertexBuffers();
		
		if (vbs == null) {
			return;
		}
		
		if (indexToBind != this._indexBuffer || this._vertexArrayObjects == null) {
			this._engine.bindBuffers(vbs, indexToBind, effect);
			return;
		}
		
		// Using VAO
		if (this._vertexArrayObjects[effect.key] == null) {
			this._vertexArrayObjects[effect.key] = this._engine.recordVertexArrayObject(vbs, indexToBind, effect);
		}
		
		this._engine.bindVertexArrayObject(this._vertexArrayObjects[effect.key], indexToBind);
	}

	/**
	 * Gets total number of vertices
	 * @returns the total number of vertices
	 */
	public function getTotalVertices():Int {
		if (!this.isReady()) {
			return 0;
		}
		
		return this._totalVertices;
	}

	/**
	 * Gets a specific vertex data attached to this geometry
	 * @param kind defines the data kind (Position, normal, etc...)
	 * @param copyWhenShared defines if the returned array must be cloned upon returning it if the current geometry is shared between multiple meshes
	 * @param forceCopy defines a boolean indicating that the returned array must be cloned upon returning it
	 * @returns a float array containing vertex data
	 */
	public function getVerticesData(kind:String, copyWhenShared:Bool = false, forceCopy:Bool = false):Float32Array {
		var vertexBuffer:VertexBuffer = this.getVertexBuffer(kind);
		if (vertexBuffer == null) {
			return null;
		}
		
		var orig:Float32Array = vertexBuffer.getData();
		if (!forceCopy && (!copyWhenShared || this._meshes.length == 1)) {
			return orig;
		}
		else {
			var len = orig.length;
			var copy:Float32Array = new Float32Array(len);
			for (i in 0...len) {
				copy[i] = orig[i];
			}
			
			return copy;
		}
	}
	
	/**
	 * Returns a boolean defining if the vertex data for the requested `kind` is updatable
	 * @param kind defines the data kind (Position, normal, etc...)
	 * @returns true if the vertex buffer with the specified kind is updatable
	 */       
	public function isVertexBufferUpdatable(kind:String):Bool {
		var vb = this._vertexBuffers[kind];
		
		if (vb == null) {
			return false;
		}
		
		return vb.isUpdatable();
	}

	/**
	 * Gets a specific vertex buffer
	 * @param kind defines the data kind (Position, normal, etc...)
	 * @returns a {BABYLON.VertexBuffer}
	 */
	public function getVertexBuffer(kind:String):VertexBuffer {
		if (!this.isReady()) {
			return null;
		}
		
		return this._vertexBuffers[kind];
	}

	/**
	 * Returns all vertex buffers
	 * @return an object holding all vertex buffers indexed by kind
	 */
	public function getVertexBuffers():Map<String, VertexBuffer> {
		if (!this.isReady()) {
			return null;
		}
		
		return this._vertexBuffers;
	}

	/**
	 * Gets a boolean indicating if specific vertex buffer is present
	 * @param kind defines the data kind (Position, normal, etc...)
	 * @returns true if data is present
	 */
	public function isVerticesDataPresent(kind:String):Bool {
		if (this._vertexBuffers == null) {
			if (this._delayInfo != null) {
				return this._delayInfo.indexOf(kind) != -1;
			}
			
			return false;
		}
		
		return this._vertexBuffers[kind] != null;
	}

	/**
	 * Gets a list of all attached data kinds (Position, normal, etc...)
	 * @returns a list of string containing all kinds
	 */
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
	
	/**
	 * Update index buffer
	 * @param indices defines the indices to store in the index buffer
	 * @param offset defines the offset in the target buffer where to store the data
	 */
	public function updateIndices(indices:UInt32Array, offset:Int = 0) {
        if (this._indexBuffer == null) {
            return;
        }
		
        if (!this._indexBufferIsUpdatable) {
            this.setIndices(indices, -1, true);
        } 
		else {
            this._engine.updateDynamicIndexBuffer(this._indexBuffer, indices, offset);
        }
    }

	/**
	 * Creates a new index buffer
	 * @param indices defines the indices to store in the index buffer
	 * @param totalVertices defines the total number of vertices (could be null)
	 * @param updatable defines if the index buffer must be flagged as updatable (false by default)
	 */
	public function setIndices(indices:UInt32Array, totalVertices:Int = -1, updatable:Bool = false) {
		if (this._indexBuffer != null) {
			this._engine._releaseBuffer(this._indexBuffer);
		}
		
		this._disposeVertexArrayObjects();
		
		this._indices = indices;
		if (this._meshes.length != 0 && this._indices != null) {
			this._indexBuffer = this._engine.createIndexBuffer(this._indices, updatable);
		}
		
		if (totalVertices != -1) {
			this._totalVertices = totalVertices;
		}
		
		var meshes = this._meshes;
		var numOfMeshes = meshes.length;
		
		for (index in 0...numOfMeshes) {
			meshes[index]._createGlobalSubMesh(true);
		}
		
		this.notifyUpdate();
	}

	/**
	 * Return the total number of indices
	 * @returns the total number of indices
	 */
	public function getTotalIndices():Int {
		if (!this.isReady()) {
			return 0;
		}
		
		return this._indices.length;
	}

	/**
	 * Gets the index buffer array
	 * @param copyWhenShared defines if the returned array must be cloned upon returning it if the current geometry is shared between multiple meshes
	 * @returns the index buffer array
	 */
	public function getIndices(copyWhenShared:Bool = false):UInt32Array {
		if (!this.isReady()) {
			return null;
		}
		
		var orig = this._indices;
		
		if (!copyWhenShared || this._meshes.length == 1) {
			return orig;
		}
		else {
			var len = orig.length;
			var copy:UInt32Array = new UInt32Array(len);
			for (i in 0...len) {
				copy[i] = orig[i];
			}
			
			return copy;
		}
	}

	/**
	 * Gets the index buffer
	 * @return the index buffer
	 */
	public function getIndexBuffer():WebGLBuffer {
		if (!this.isReady()) {
			return null;
		}
		
		return this._indexBuffer;
	}
	
	public function _releaseVertexArrayObject(effect:Effect) {
		if (effect == null || this._vertexArrayObjects == null) {
			return;
		}
		
		if (this._vertexArrayObjects[effect.key] != null) {
			this._engine.releaseVertexArrayObject(this._vertexArrayObjects[effect.key]);
			this._vertexArrayObjects.remove(effect.key);
		}
	}

	/**
	 * Release the associated resources for a specific mesh
	 * @param mesh defines the source mesh
	 * @param shouldDispose defines if the geometry must be disposed if there is no more mesh pointing to it
	 */
	public function releaseForMesh(mesh:Mesh, shouldDispose:Bool = false) {
		var meshes = this._meshes;
		var index = meshes.indexOf(mesh);
		
		if (index == -1) {
			return;
		}
		
		meshes.splice(index, 1);
		
		mesh._geometry = null;
		
		if (meshes.length == 0 && shouldDispose) {
			this.dispose();
		}
	}

	/**
	 * Apply current geometry to a given mesh
	 * @param mesh defines the mesh to apply geometry to
	 */
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
	
	private function updateExtend(data:Float32Array = null, ?stride:Int) {
		if (data == null) {
			data = this._vertexBuffers[VertexBuffer.PositionKind].getData();
		}
		
		this._extend = MathTools.ExtractMinAndMax(data, 0, this._totalVertices, this.boundingBias, stride);
	}

	private function _applyToMesh(mesh:Mesh) {
		var numOfMeshes = this._meshes.length;
		
		// vertexBuffers
		for (kind in this._vertexBuffers.keys()) {
			if (numOfMeshes == 1) {
				this._vertexBuffers[kind].create();
			}
			var buffer = this._vertexBuffers[kind].getBuffer();
			if (buffer != null) {
				buffer.references = numOfMeshes;
			}
			
			if (kind == VertexBuffer.PositionKind) {
				if (this._extend == null) {
					this.updateExtend(this._vertexBuffers[kind].getData());
				}
				mesh._boundingInfo = new BoundingInfo(this._extend.minimum, this._extend.maximum);
				
				mesh._createGlobalSubMesh(false);
				
				//bounding info was just created again, world matrix should be applied again.
				mesh._updateBoundingInfo();
			}
		}
		
		// indexBuffer
		if (numOfMeshes == 1 && this._indices != null && this._indices.length > 0) {
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
		
		for (mesh in this._meshes) {
			mesh._markSubMeshesAsAttributesDirty();
		}
	}

	/**
	 * Load the geometry if it was flagged as delay loaded
	 * @param scene defines the hosting scene
	 * @param onLoaded defines a callback called when the geometry is loaded
	 */
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
		
		this._queueLoad(scene, onLoaded);
	}
	
	private function _queueLoad(scene:Scene, onLoaded:Void->Void = null) {
		/*scene._addPendingData(this);
		Tools.LoadFile(this.delayLoadingFile, function(data) {
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
	
	/**
	 * Invert the geometry to move from a right handed system to a left handed one.
	 */
	public function toLeftHanded() {
		// Flip faces
		var tIndices = this.getIndices(false);
		if (tIndices != null && tIndices.length > 0) {
			var i = 0;
			while (i < tIndices.length) {
				var tTemp = tIndices[i + 0];
				tIndices[i + 0] = tIndices[i + 2];
				tIndices[i + 2] = tTemp;
				i += 3;
			}
			this.setIndices(tIndices);
		}
		
		// Negate position.z
		var tPositions = this.getVerticesData(VertexBuffer.PositionKind, false);
		if (tPositions != null && tPositions.length > 0) {
			var i = 0;
			while (i < tPositions.length) {
				tPositions[i + 2] = -tPositions[i + 2];
				i += 3;
			}
			this.setVerticesData(VertexBuffer.PositionKind, tPositions, false);
		}
		
		// Negate normal.z
		var tNormals = this.getVerticesData(VertexBuffer.NormalKind, false);
		if (tNormals != null && tNormals.length > 0) {
			var i = 0;
			while (i < tNormals.length) {
				tNormals[i + 2] = -tNormals[i + 2];
				i += 3;
			}
			this.setVerticesData(VertexBuffer.NormalKind, tNormals, false);
		}
	}
	
	// Cache
	public function _resetPointsArrayCache() {
		this._positions = null;
	}

	public function _generatePointsArray():Bool {
		if (this._positions != null) {
			return true;
		}
		
		this._positions = [];
		
		var data = this.getVerticesData(VertexBuffer.PositionKind);
		
		if (data == null) {
			return false;
		}
		
		var index:Int = 0;
		while (index < data.length) {
			this._positions.push(Vector3.FromFloat32Array(data, index));
			index += 3;
		}
		
		return true;
	}
	
	/**
	 * Gets a value indicating if the geometry is disposed
	 * @returns true if the geometry was disposed
	 */
	inline public function isDisposed():Bool {
		return this._isDisposed;
	}
	
	private function _disposeVertexArrayObjects() {
		if (this._vertexArrayObjects != null) {
			for (kind in this._vertexArrayObjects.keys()) {
				this._engine.releaseVertexArrayObject(this._vertexArrayObjects[kind]);
			}
			this._vertexArrayObjects = new Map();
		}
	}

	/**
	 * Free all associated resources
	 */
	public function dispose() {
		var meshes = this._meshes;
		var numOfMeshes = meshes.length;
		
		for (index in 0...numOfMeshes) {
			this.releaseForMesh(meshes[index]);
		}
		this._meshes = [];
		
		this._disposeVertexArrayObjects();
		
		for (kind in this._vertexBuffers.keys()) {
			this._vertexBuffers[kind].dispose();
		}
		this._vertexBuffers = new Map<String, VertexBuffer>();
		this._totalVertices = 0;
		
		if (this._indexBuffer != null) {
			this._engine._releaseBuffer(this._indexBuffer);
		}
		this._indexBuffer = null;
		this._indices = null;
		
		this.delayLoadState = Engine.DELAYLOADSTATE_NONE;
		this.delayLoadingFile = null;
		this._delayLoadingFunction = null;
		this._delayInfo = [];
		
		this._boundingInfo = null; // todo:.dispose()
		
		this._scene.removeGeometry(this);		
		this._isDisposed = true;
	}

	/**
	 * Clone the current geometry into a new geometry
	 * @param id defines the unique ID of the new geometry
	 * @returns a new geometry object
	 */
	public function copy(id:String):Geometry {
		var indices = this.getIndices();
		
		var vertexData:VertexData = new VertexData();
		vertexData.indices = new UInt32Array(indices.length);		
		for (index in 0...indices.length) {
			vertexData.indices[index] = (indices[index]);
		}
		
		var updatable = false;
		var stopChecking = false;		
		for (kind in this._vertexBuffers.keys()) {
			var data = this.getVerticesData(kind);
			
			//if (Std.is(data, Float32Array)) {
				vertexData.set(new Float32Array(data), kind);
			//} 
			//else {
				//vertexData.set(data.copy(), kind);
			//}
			if (!stopChecking) {
				var vb = this.getVertexBuffer(kind);
				
				if (vb != null) {
					updatable = this.getVertexBuffer(kind).isUpdatable();
					stopChecking = !updatable;
				}
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
	
	/**
	 * Serialize the current geometry info (and not the vertices data) into a JSON object
	 * @return a JSON representation of the current geometry data (without the vertices data)
	 */
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.id = this.id;
		serializationObject.updatable = this._updatable;
		
		if (Tags.HasTags(this)) {
			serializationObject.tags = Tags.GetTags(this);
		}
		
		return serializationObject;
	}

	/*private function toNumberArray(origin:Dynamic):Array<Dynamic> {
		if (Std.is(origin, Array)) {
			return origin;
		} 
		else {
			return Array.prototype.slice.call(origin);
		}
	}*/

	/**
	 * Serialize all vertices data into a JSON oject
	 * @returns a JSON representation of the current geometry data
	 */
	public function serializeVerticeData():Dynamic {
		var serializationObject = this.serialize();
		
		if (this.isVerticesDataPresent(VertexBuffer.PositionKind)) {
			serializationObject.positions = this.getVerticesData(VertexBuffer.PositionKind);
			if (this.getVertexBuffer(VertexBuffer.PositionKind).isUpdatable()) {
				//serializationObject.positions._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			serializationObject.normals = this.getVerticesData(VertexBuffer.NormalKind);
			if (this.getVertexBuffer(VertexBuffer.NormalKind).isUpdatable()) {
				//serializationObject.normals._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.UVKind)) {
			serializationObject.uvs = this.getVerticesData(VertexBuffer.UVKind);
			if (this.getVertexBuffer(VertexBuffer.UVKind).isUpdatable()) {
				//serializationObject.uvs._updatable = true;
			}
		}

		if (this.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
			serializationObject.uv2s = this.getVerticesData(VertexBuffer.UV2Kind);
			if (this.getVertexBuffer(VertexBuffer.UV2Kind).isUpdatable()) {
				//serializationObject.uv2s._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.UV3Kind)) {
			serializationObject.uv3s = this.getVerticesData(VertexBuffer.UV3Kind);
			if (this.getVertexBuffer(VertexBuffer.UV3Kind).isUpdatable()) {
				//serializationObject.uv3s._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.UV4Kind)) {
			serializationObject.uv4s = this.getVerticesData(VertexBuffer.UV4Kind);
			if (this.getVertexBuffer(VertexBuffer.UV4Kind).isUpdatable()) {
				//serializationObject.uv4s._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.UV5Kind)) {
			serializationObject.uv5s = this.getVerticesData(VertexBuffer.UV5Kind);
			if (this.getVertexBuffer(VertexBuffer.UV5Kind).isUpdatable()) {
				//serializationObject.uv5s._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.UV6Kind)) {
			serializationObject.uv6s = this.getVerticesData(VertexBuffer.UV6Kind);
			if (this.getVertexBuffer(VertexBuffer.UV6Kind).isUpdatable()) {
				//serializationObject.uv6s._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.ColorKind)) {
			serializationObject.colors = this.getVerticesData(VertexBuffer.ColorKind);
			if (this.getVertexBuffer(VertexBuffer.ColorKind).isUpdatable()) {
				//serializationObject.colors._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind)) {
			serializationObject.matricesIndices = this.getVerticesData(VertexBuffer.MatricesIndicesKind);
			//serializationObject.matricesIndices._isExpanded = true;
			if (this.getVertexBuffer(VertexBuffer.MatricesIndicesKind).isUpdatable()) {
				//serializationObject.matricesIndices._updatable = true;
			}
		}
		
		if (this.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
			serializationObject.matricesWeights = this.getVerticesData(VertexBuffer.MatricesWeightsKind);
			if (this.getVertexBuffer(VertexBuffer.MatricesWeightsKind).isUpdatable()) {
				//serializationObject.matricesWeights._updatable = true;
			}
		}
		
		serializationObject.indices = this.getIndices();
		
		return serializationObject;
	}

	// Statics
	
	/**
	 * Extracts a clone of a mesh geometry
	 * @param mesh defines the source mesh
	 * @param id defines the unique ID of the new geometry object
	 * @returns the new geometry object
	 */
	public static function ExtractFromMesh(mesh:Mesh, id:String):Geometry {
		var geometry = mesh._geometry;
		
		if (geometry == null) {
			return null;
		}
		
		return geometry.copy(id);
	}
		
	public static function _ImportGeometry(parsedGeometry:Dynamic, mesh:Mesh) {
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
				var matricesIndicesData = new UInt32Array(parsedGeometry, binaryInfo.matricesIndicesAttrDesc.offset, binaryInfo.matricesIndicesAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, matricesIndicesData, false);
			}
			
			if (binaryInfo.matricesWeightsAttrDesc != null && binaryInfo.matricesWeightsAttrDesc.count > 0) {
				var matricesWeightsData = new Float32Array(parsedGeometry, binaryInfo.matricesWeightsAttrDesc.offset, binaryInfo.matricesWeightsAttrDesc.count);
				mesh.setVerticesData(VertexBuffer.MatricesWeightsKind, matricesWeightsData, false);
			}
			
			if (binaryInfo.indicesAttrDesc != null && binaryInfo.indicesAttrDesc.count > 0) {
				var indicesData = new UInt32Array(parsedGeometry, binaryInfo.indicesAttrDesc.offset, binaryInfo.indicesAttrDesc.count);
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
		} */
		else if (parsedGeometry.positions != null && parsedGeometry.normals != null && parsedGeometry.indices != null) {
			var pos:Array<Float> = cast parsedGeometry.positions;	// BHX: otherwise it won't work on cpp
			mesh.setVerticesData(VertexBuffer.PositionKind, new Float32Array(pos), false);
			var nrm:Array<Float> = cast parsedGeometry.normals;		// BHX: otherwise it won't work on cpp
			mesh.setVerticesData(VertexBuffer.NormalKind, new Float32Array(nrm), false);
			
			if (parsedGeometry.uvs != null) {
				var uvs:Array<Float> = cast parsedGeometry.uvs;		// BHX: otherwise it won't work on cpp
				mesh.setVerticesData(VertexBuffer.UVKind, new Float32Array(uvs), false);
			}
			
			if (parsedGeometry.uvs2 != null) {
				var uvs2:Array<Float> = cast parsedGeometry.uvs2;	// BHX: otherwise it won't work on cpp
				mesh.setVerticesData(VertexBuffer.UV2Kind, new Float32Array(uvs2), false);
			}
			
			if (parsedGeometry.uvs3 != null) {
				var uvs3:Array<Float> = cast parsedGeometry.uvs3;	// BHX: otherwise it won't work on cpp
				mesh.setVerticesData(VertexBuffer.UV3Kind, new Float32Array(uvs3), false);
			}
			
			if (parsedGeometry.uvs4 != null) {
				var uvs4:Array<Float> = cast parsedGeometry.uvs4;	// BHX: otherwise it won't work on cpp
				mesh.setVerticesData(VertexBuffer.UV4Kind, new Float32Array(uvs4), false);
			}
			
			if (parsedGeometry.uvs5 != null) {
				var uvs5:Array<Float> = cast parsedGeometry.uvs5;	// BHX: otherwise it won't work on cpp
				mesh.setVerticesData(VertexBuffer.UV5Kind, new Float32Array(uvs5), false);
			}
			
			if (parsedGeometry.uvs6 != null) {
				var uvs6:Array<Float> = cast parsedGeometry.uvs6;	// BHX: otherwise it won't work on cpp
				mesh.setVerticesData(VertexBuffer.UV6Kind, new Float32Array(uvs6), false);
			}
			
			if (parsedGeometry.colors != null) {
				var colors:Array<Float> = cast parsedGeometry.colors;	// BHX: otherwise it won't work on cpp
				mesh.setVerticesData(VertexBuffer.ColorKind, new Float32Array(Color4.CheckColors4(colors, Std.int(parsedGeometry.positions.length / 3))), false);
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
					
					mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, new Float32Array( #if purejs untyped #end floatIndices), false);
				} 
				else {
					parsedGeometry.matricesIndices._isExpanded = null;
					var midc:Array<Int> = cast parsedGeometry.matricesIndices;
					mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, new Float32Array(midc), false);
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
					
					mesh.setVerticesData(VertexBuffer.MatricesIndicesExtraKind, new Float32Array( #if purejs untyped #end floatIndices), false);
				} 
				else {
					parsedGeometry.matricesIndicesExtra._isExpanded = null;
					var midc:Array<Int> = cast parsedGeometry.matricesIndicesExtra;
					mesh.setVerticesData(VertexBuffer.MatricesIndicesExtraKind, new Float32Array(midc), false);
				}
			}
			
			if (parsedGeometry.matricesWeights != null) {
				Geometry._CleanMatricesWeights(parsedGeometry, mesh);
				var mwgh:Array<Float> = cast parsedGeometry.matricesWeights;
                mesh.setVerticesData(VertexBuffer.MatricesWeightsKind, new Float32Array(mwgh), parsedGeometry.matricesWeights._updatable);
			}
			
			if (parsedGeometry.matricesWeightsExtra != null) {
				var mwghe:Array<Float> = cast parsedGeometry.matricesWeightsExtra;
                mesh.setVerticesData(VertexBuffer.MatricesWeightsExtraKind, new Float32Array(mwghe), parsedGeometry.matricesWeights._updatable);
            }
			
			var idc:Array<Int> = cast parsedGeometry.indices; 	
			mesh.setIndices(new UInt32Array(idc));
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
		var sceneOctree = scene.selectionOctree;
		if (sceneOctree != null) {
			sceneOctree.addMesh(mesh);
		}
	}
	
	private static function _CleanMatricesWeights(parsedGeometry:Dynamic, mesh:Mesh) {
		var epsilon:Float = 1e-3;
		if (!SceneLoader.CleanBoneMatrixWeights) {
			return;
		}
		var noInfluenceBoneIndex = 0.0;
		if (parsedGeometry.skeletonId > -1) {
			var skeleton = mesh.getScene().getLastSkeletonByID(parsedGeometry.skeletonId);
			
			if (skeleton == null) {
				return;
			}
			noInfluenceBoneIndex = skeleton.bones.length;
		} 
		else {
			return;
		}
		var matricesIndices = mesh.getVerticesData(VertexBuffer.MatricesIndicesKind);
		var matricesIndicesExtra = mesh.getVerticesData(VertexBuffer.MatricesIndicesExtraKind);
		var matricesWeights:Array<Float> = cast parsedGeometry.matricesWeights;
		var matricesWeightsExtra:Array<Float> = cast parsedGeometry.matricesWeightsExtra;
		var influencers:Int = cast parsedGeometry.numBoneInfluencer;
		var size:Int = matricesWeights.length;
		
		var i:Int = 0;
		while (i < size) {
			var weight = 0.0;
			var firstZeroWeight = -1;
			for (j in 0...4) {
				var w = matricesWeights[i + j];
				weight += w;
				if (w < epsilon && firstZeroWeight < 0) {
					firstZeroWeight = j;
				}
			}
			if (matricesWeightsExtra != null) {
				for (j in 0...4) {
					var w = matricesWeightsExtra[i + j];
					weight += w;
					if (w < epsilon && firstZeroWeight < 0) {
						firstZeroWeight = j + 4;
					}
				}
			}
			if (firstZeroWeight < 0  || firstZeroWeight > (influencers - 1)) {
				firstZeroWeight = influencers - 1;
			}
			if (weight > epsilon) {
				var mweight = 1.0 / weight;
				for (j in 0...4) {
					matricesWeights[i + j] *= mweight;
				}
				if (matricesWeightsExtra != null) {
					for (j in 0...4) {
						matricesWeightsExtra[i + j] *= mweight;
					}    
				}
			} 
			else {
				if (firstZeroWeight >= 4) {
					matricesWeightsExtra[i + firstZeroWeight - 4] = 1.0 - weight;
					matricesIndicesExtra[i + firstZeroWeight - 4] = noInfluenceBoneIndex;
				} 
				else {
					matricesWeights[i + firstZeroWeight] = 1.0 - weight;
					matricesIndices[i + firstZeroWeight] = noInfluenceBoneIndex;
				}
			}
			i += 4;
		}
		
		mesh.setVerticesData(VertexBuffer.MatricesIndicesKind, matricesIndices);
		if (parsedGeometry.matricesWeightsExtra != null) {       
			mesh.setVerticesData(VertexBuffer.MatricesIndicesExtraKind, matricesIndicesExtra);
		}
	}
	
	/**
	 * Create a new geometry from persisted data (Using .babylon file format)
	 * @param parsedVertexData defines the persisted data
	 * @param scene defines the hosting scene
	 * @param rootUrl defines the root url to use to load assets (like delayed data)
	 * @returns the new geometry object
	 */
	public static function Parse(parsedVertexData:Dynamic, scene:Scene, rootUrl:String = ""):Geometry {
        if (scene.getGeometryByID(parsedVertexData.id) != null) {
            return null; // null since geometry could be a primitive
        }
		
        var geometry = new Geometry(parsedVertexData.id, scene, null, parsedVertexData.updatable);
		
		if (parsedVertexData.tags != null) {
			Tags.AddTagsTo(geometry, parsedVertexData.tags);
		}
		
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
