package com.babylonhx.mesh;

import com.babylonhx.engine.Engine;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*abstract OneOf<A, B>(Either<A, B>) from Either<A, B> to Either<A, B> {
  @:from inline static function fromA<A, B>(a:A) : OneOf<A, B> return Left(a);
  @:from inline static function fromB<A, B>(b:B) : OneOf<A, B> return Right(b);
    
  @:to inline function toA():Null<A> return switch(this) {case Left(a): a; default: null;}
  @:to inline function toB():Null<B> return switch(this) {case Right(b): b; default: null;}

}*/
 
class Buffer {
	
	private var _engine:Engine;
	
	@:allow(com.babylonhx.mesh.Geometry)
	private var _buffer:WebGLBuffer;	
	
	private var _data:Float32Array;
	private var _updatable:Bool;
	private var _strideSize:Int;
	private var _instanced:Bool;
	private var _instanceDivisor:Int;
	

	public function new(engine:Engine, data:Float32Array, updatable:Bool, stride:Int, postponeInternalCreation:Bool = false, instanced:Bool = false) {
		this._engine = engine;		
		this._updatable = updatable;
		this._data = data;
		this._strideSize = stride;
		
		if (!postponeInternalCreation) { // by default
			this.create();
		}
		
		this._instanced = instanced;
		this._instanceDivisor = instanced ? 1 : 0;
	}

	public function createVertexBuffer(kind:String, offset:Int, size:Int, ?stride:Int):VertexBuffer {
		// a lot of these parameters are ignored as they are overriden by the buffer
		return new VertexBuffer(this._engine, this, kind, this._updatable, true, stride != null ? stride : this._strideSize, this._instanced, offset, size);
	}

	// Properties
	inline public function isUpdatable():Bool {
		return this._updatable;
	}

	inline public function getData():Float32Array {
		return this._data;
	}

	inline public function getBuffer():WebGLBuffer {
		return this._buffer;
	}

	inline public function getStrideSize():Int {
		return this._strideSize;
	}

	inline public function getIsInstanced():Bool {
		return this._instanced;
	}
	
	public var instanceDivisor(get, set):Int;
	inline private function get_instanceDivisor():Int {
		return this._instanceDivisor;
	}
	private function set_instanceDivisor(value:Int):Int {
		this._instanceDivisor = value;
		if (value == 0) {
			this._instanced = false;
		} 
		else {
			this._instanced = true;
		}
		return value;
	}

	// Methods
	public function create(?data:Float32Array) {
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
	
	public function _rebuild() {
		this._buffer = null;
		this.create(this._data);
	}

	inline public function update(data:Float32Array) {
		this.create(data);
	}

	public function updateDirectly(data:Float32Array, offset:Int, ?vertexCount:Int) {
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
