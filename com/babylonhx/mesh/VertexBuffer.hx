package com.babylonhx.mesh;

import com.babylonhx.utils.typedarray.Float32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.VertexBuffer') class VertexBuffer {
	
	// Enums
	public static inline var PositionKind:String = "position";
	public static inline var NormalKind:String = "normal";
	public static inline var UVKind:String = "uv";
	public static inline var UV2Kind:String = "uv2";
	public static inline var UV3Kind:String = "uv3";
    public static inline var UV4Kind:String = "uv4";
    public static inline var UV5Kind:String = "uv5";
    public static inline var UV6Kind:String = "uv6";
	public static inline var ColorKind:String = "color";
	public static inline var MatricesIndicesKind:String = "matricesIndices";
	public static inline var MatricesWeightsKind:String = "matricesWeights";
	public static inline var MatricesIndicesExtraKind:String = "matricesIndicesExtra";
    public static inline var MatricesWeightsExtraKind:String = "matricesWeightsExtra";
	
	private var _mesh:Mesh;
	private var _engine:Engine;
	public var _buffer:WebGLBuffer;
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
				
			case VertexBuffer.UVKind, VertexBuffer.UV2Kind, VertexBuffer.UV3Kind, 
				 VertexBuffer.UV4Kind, VertexBuffer.UV5Kind, VertexBuffer.UV6Kind:
				this._strideSize = 2;
				
			case VertexBuffer.ColorKind:
				this._strideSize = 4;
				
			case VertexBuffer.MatricesIndicesKind, VertexBuffer.MatricesIndicesExtraKind:
				this._strideSize = 4;
				
			case VertexBuffer.MatricesWeightsKind, VertexBuffer.MatricesWeightsExtraKind:
				this._strideSize = 4;
				
		}
	}

	// Properties
	inline public function isUpdatable():Bool {
		return this._updatable;
	}

	inline public function getData():Array<Float> {
		return this._data;
	}

	inline public function getBuffer():WebGLBuffer {
		return this._buffer;
	}

	inline public function getStrideSize():Int {
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
			} 
			else {
				this._buffer = this._engine.createVertexBuffer(data);
			}
		}
		
		if (this._updatable) { // update buffer
			this._engine.updateDynamicVertexBuffer(this._buffer, data);
			this._data = data;
		}
	}

	inline public function update(data:Array<Float>) {
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

	inline public function dispose() {
		if (this._buffer != null) {
			if (this._engine._releaseBuffer(this._buffer)) {
				this._buffer = null;
			}
		}		
	}	
	
}
