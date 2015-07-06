package com.babylonhx.mesh;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.GLBuffer;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.WebGLBuffer') class WebGLBuffer {
	
	// TODO: this will depend on backend we use (Kha, OpenFL, Snow...)
	public var buffer:GLBuffer;	
	public var references:Int;
	public var capacity:Int = 0;
	public var is32Bits:Bool = false;
	
	
	public function new(buffer:GLBuffer) {
		this.buffer = buffer;
		this.references = 1;
	}
	
}
