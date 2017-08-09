package com.babylonhx.mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BufferPointer {
	
	public var active:Bool;
	public var index:Int;
	public var size:Int;
	public var type:Int;
	public var normalized:Bool;
	public var stride:Int;
	public var offset:Int;
	public var buffer:WebGLBuffer;
	

	inline public function new(active:Bool = false, index:Int = -1, size:Int = -1, type:Int = -1, normalized:Bool = false, stride:Int = -1, offset:Int = -1, buffer:WebGLBuffer = null) {
		this.active = active;
		this.index = index;
		this.size = size;
		this.type = type;
		this.normalized = normalized;
		this.stride = stride;
		this.offset = offset;
		this.buffer = buffer;
	}
	
}
