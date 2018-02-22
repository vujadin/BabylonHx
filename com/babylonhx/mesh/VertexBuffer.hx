package com.babylonhx.mesh;

import com.babylonhx.engine.Engine;

import com.babylonhx.utils.typedarray.Float32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.VertexBuffer') class VertexBuffer {
	
	// Enums
	public static inline var PositionKind:String = "position";
	public static inline var NormalKind:String = "normal";
	public static inline var TangentKind:String = "tangent";
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
	
	@:allow(com.babylonhx.mesh.Geometry)
	private var _buffer:Buffer;
	private var _kind:String;
	private var _offset:Int;
	private var _size:Int;
	private var _stride:Int;
	private var _ownsBuffer:Bool;
	private var _instanced:Bool;        
	private var _instanceDivisor:Int;
	
	public var instanceDivisor(get, set):Int;
	/**
	 * Gets or sets the instance divisor when in instanced mode
	 */
	inline function get_instanceDivisor():Int {
		return this._instanceDivisor;
	}
	function set_instanceDivisor(value:Int):Int {
		this._instanceDivisor = value;
		if (value == 0) {
			this._instanced = false;
		} 
		else {
			this._instanced = true;
		}
		return value;
	} 
	
	
	public function new(engine:Engine, data:Dynamic, kind:String, updatable:Bool, postponeInternalCreation:Bool = false, ?stride:Int, ?instanced:Bool, offset:Int = 0, ?size:Int) {		
		if (Std.is(data, Buffer)) {
			if (stride == null) {
				stride = untyped data.getStrideSize();
			}
			
			this._buffer = cast data;
			this._ownsBuffer = false;
		} 
		else {
			if (stride == null) {
				stride = VertexBuffer.DeduceStride(kind);
			}
			this._buffer = new Buffer(engine, data, updatable, stride, postponeInternalCreation, instanced);			
			this._ownsBuffer = true;
		}
		
		this._stride = stride;
		this._instanced = instanced != null ? instanced : false;
		this._instanceDivisor = instanced ? 1 : 0;
		
		this._offset = offset;
		this._size = size != null ? size : stride;
		
		this._kind = kind;
	}
	
	public function _rebuild() {
        if (this._buffer == null) {
            return;
        }
		
		this._buffer._rebuild();
    }
	
	inline public function getKind():String {
		return this._kind;
	}

	// Properties
	inline public function isUpdatable():Bool {
		return this._buffer.isUpdatable();
	}

	inline public function getData():Float32Array {
		return this._buffer.getData();
	}

	inline public function getBuffer():WebGLBuffer {
		return this._buffer.getBuffer();
	}

	inline public function getStrideSize():Int {
		return this._stride;
	}
	
	inline public function getOffset():Int {
		return this._offset;
	}
	
	inline public function getSize():Int {
		return this._size;
	}
	
	inline public function getIsInstanced():Bool {
		return this._instanced;
	}
	
	/**
     * Returns the instancing divisor, zero for non-instanced (integer).  
     */
    public function getInstanceDivisor():Int {
        return this._instanceDivisor;
    }

	// Methods
	/**
	 * Creates the underlying WebGLBuffer from the passed numeric array or Float32Array.  
	 * Returns the created WebGLBuffer.   
	 */
	public function create(?data:Float32Array) {		
		return this._buffer.create(data);
	}

	/**
	 * Updates the underlying WebGLBuffer according to the passed numeric array or Float32Array.  
     * This function will create a new buffer if the current one is not updatable
     * Returns the updated WebGLBuffer.  
     */
	inline public function update(data:Float32Array) {
		this.create(data);
	}

	/**
	 * Updates directly the underlying WebGLBuffer according to the passed numeric array or Float32Array.  
	 * Returns the directly updated WebGLBuffer. 
	 */
	inline public function updateDirectly(data:Float32Array, offset:Int) {
		return this._buffer.updateDirectly(data, offset);		
	}

	/** 
	 * Disposes the VertexBuffer and the underlying WebGLBuffer.  
	 */
	public function dispose() {
		if (this._ownsBuffer) {
			this._buffer.dispose();
		}		
	}	
	
	/**
	 * Deduces the stride given a kind.
	 * @param kind The kind string to deduce
	 * @returns The deduced stride
	 */
	public static function DeduceStride(kind:String):Int {
		switch (kind) {
			case VertexBuffer.UVKind, VertexBuffer.UV2Kind, VertexBuffer.UV3Kind, VertexBuffer.UV4Kind, VertexBuffer.UV5Kind, VertexBuffer.UV6Kind:
				return 2;
				
			case VertexBuffer.NormalKind, VertexBuffer.PositionKind:
				return 3;
				
			case VertexBuffer.ColorKind, VertexBuffer.MatricesIndicesKind, VertexBuffer.MatricesIndicesExtraKind, 
					VertexBuffer.MatricesWeightsKind, VertexBuffer.MatricesWeightsExtraKind, VertexBuffer.TangentKind:
				return 4;
				
			default:
				throw ("Invalid kind '" + kind + "'");
		}
	}
	
}
