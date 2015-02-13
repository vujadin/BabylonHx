package com.babylonhx.mesh;

#if nme
import nme.utils.Float32Array;
#elseif openfl
import openfl.utils.Float32Array;
#elseif snow
import snow.utils.Float32Array;
#elseif kha

#end


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.VertexBuffer') class VertexBuffer {
	
	// Enums
	public static var PositionKind:String = "position";
	public static var NormalKind:String = "normal";
	public static var UVKind:String = "uv";
	public static var UV2Kind:String = "uv2";
	public static var ColorKind:String = "color";
	public static var MatricesIndicesKind:String = "matricesIndices";
	public static var MatricesWeightsKind:String = "matricesWeights";
	
	
	private var _mesh:Mesh;
	private var _engine:Engine;
	public var _buffer:BabylonBuffer;
	private var _data:Array<Float>;
	private var _updatable:Bool;
	private var _kind:String;
	private var _strideSize:Int;

	public static var count:Int = 0;
	public function new(engine:Engine, data:Array<Float>, kind:String, updatable:Bool, postponeInternalCreation:Bool = false, ?stride:Int) {
		this._engine = engine;
		this._updatable = updatable;
		this._data = data;
		
		if (!postponeInternalCreation) { // by default
			this.create();
		}
				
		this._kind = kind;
		
		if (stride != null) {
			this._strideSize = stride;
			return;
		}
		
		// Deduce stride from kind
		switch (kind) {
			case VertexBuffer.PositionKind:
				this._strideSize = 3;
				
			case VertexBuffer.NormalKind:
				this._strideSize = 3;
				
			case VertexBuffer.UVKind:
				this._strideSize = 2;
				
			case VertexBuffer.UV2Kind:
				this._strideSize = 2;
				
			case VertexBuffer.ColorKind:
				this._strideSize = 4;
				
			case VertexBuffer.MatricesIndicesKind:
				this._strideSize = 4;
				
			case VertexBuffer.MatricesWeightsKind:
				this._strideSize = 4;
				
		}
	}

	// Properties
	public function isUpdatable():Bool {
		return this._updatable;
	}

	public function getData():Array<Float> {
		return this._data;
	}

	public function getBuffer():BabylonBuffer {
		return this._buffer;
	}

	public function getStrideSize():Int {
		return this._strideSize;
	}

	// Methods
	public function create(?data:Array<Float>) {
		if (data == null && this._buffer != null) {
			return; // nothing to do
		}
		
		data = data != null ? data : this._data;
		
		if (this._buffer == null) { // create buffer
			if (this._updatable) {
				this._buffer = this._engine.createDynamicVertexBuffer(data.length * 4);
			} else {
				this._buffer = this._engine.createVertexBuffer(data);
			}
		}
		
		if (this._updatable) { // update buffer
			this._engine.updateDynamicVertexBuffer(this._buffer, data);
			this._data = data;
		}
	}

	public function update(data:Array<Float>) {
		this.create(data);
	}

	public function updateDirectly(data:Float32Array, offset:Int) {
		if (this._buffer == null) {
			return;
		}
		
		if (this._updatable) { // update buffer
			this._engine.updateDynamicVertexBuffer(this._buffer, data, offset);
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
