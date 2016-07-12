package com.babylonhx.mesh;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Buffer {
	
	private var _engine:Engine;
	
	@:allow(com.babylonhx.mesh.Geometry)
	private var _buffer:WebGLBuffer;	
	
	//private var _data:Either<Array<Float>, Float32Array>;
	private var _data:Array<Float>;
	private var _updatable:Bool;
	private var _strideSize:Int;
	private var _instanced:Bool;
	

	public function new(engine:Engine, data:Array<Float>, updatable:Bool, stride:Int, postponeInternalCreation:Bool = false, instanced:Bool = false) {
		this._engine = engine;		
		this._updatable = updatable;
		this._data = data;
		this._strideSize = stride;
		
		if (!postponeInternalCreation) { // by default
			this.create();
		}
		
		this._instanced = instanced;
	}

	public function createVertexBuffer(kind:String, offset:Int, size:Int, ?stride:Int):VertexBuffer {
		// a lot of these parameters are ignored as they are overriden by the buffer
		return new VertexBuffer(this._engine, this, kind, this._updatable, true, stride != null ? stride : this._strideSize, this._instanced, offset, size);
	}

	// Properties
	public function isUpdatable():Bool {
		return this._updatable;
	}

	public function getData():Array<Float> {
		return this._data;
	}

	public function getBuffer():WebGLBuffer {
		return this._buffer;
	}

	public function getStrideSize():Int {
		return this._strideSize;
	}

	public function getIsInstanced():Bool {
		return this._instanced;
	}

	// Methods
	public function create(?data:Array<Float>) {
		if (data == null && this._buffer != null) {
			return; // nothing to do
		}
		
		if (data == null) {
			data = this._data;
		}
		
		if (this._buffer == null) { // create buffer
			if (this._updatable) {
				this._buffer = this._engine.createDynamicVertexBuffer(data);
				this._data = data;
			} 
			else {
				this._buffer = this._engine.createVertexBuffer(data);
			}
		} 
		else if (this._updatable) { // update buffer
			this._engine.updateDynamicVertexBuffer(this._buffer, data);
			this._data = data;
		}
	}

	public function update(data:Array<Float>) {
		this.create(data);
	}

	public function updateDirectly(data:Array<Float>, offset:Int, ?vertexCount:Int) {
		if (this._buffer == null) {
			return;
		}
		
		if (this._updatable) { // update buffer
			this._engine.updateDynamicVertexBuffer(this._buffer, data, offset, (vertexCount != null ? vertexCount * this.getStrideSize() : 0));
			this._data = null;
		}
	}

	public function dispose() {
		if (this._buffer == null) {
			return;
		}
		
		if (this._engine._releaseBuffer(this._buffer)) {
			this._buffer = null;
		}
	}
	
}
