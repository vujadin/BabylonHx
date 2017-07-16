package com.babylonhx.mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BufferPointer {
	
	public var indx:Int;
	public var size:Int;
	public var type:Int;
	public var normalized:Bool;
	public var stride:Int;
	public var offset:Int;
	public var buffer:WebGLBuffer;
	

	inline public function new(indx:Int, size:Int, type:Int, normalized:Bool, stride:Int, offset:Int, buffer:WebGLBuffer) {
		this.indx = indx;
		this.size = size;
		this.type = type;
		this.normalized = normalized;
		this.stride = stride;
		this.offset = offset;
		this.buffer = buffer;
	}
	
}
