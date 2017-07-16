package com.babylonhx;

import lime.graphics.opengl.GL;

/**
 * ...
 * @author Krtolica Vujadin
 */
class InstancingAttributeInfo {
	
	/**
	 * Index/offset of the attribute in the vertex shader
	 */
	public var index:Int;
	
	/**
	 * size of the attribute, 1, 2, 3 or 4
	 */
	public var attributeSize:Int;

	/**
	 * type of the attribute, gl.BYTE, gl.UNSIGNED_BYTE, gl.SHORT, gl.UNSIGNED_SHORT, gl.FIXED, gl.FLOAT.
	 * default is FLOAT
	 */
	public var attribyteType:Int = GL.FLOAT;

	/**
	 * normalization of fixed-point data. behavior unclear, use FALSE, default is FALSE
	 */
	public var normalized:Bool = false;

	/**
	 * Offset of the data in the Vertex Buffer acting as the instancing buffer
	 */
	public var offset:Int;

	/**
	 * Name of the GLSL attribute, for debugging purpose only
	 */
	public var attributeName:String;
	
	
	inline public function new() { }
	
}
