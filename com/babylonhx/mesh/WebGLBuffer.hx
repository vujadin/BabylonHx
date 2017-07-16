package com.babylonhx.mesh;

import com.babylonhx.tools.Tools;

import lime.graphics.opengl.GLBuffer;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.WebGLBuffer') class WebGLBuffer {
	
	public var id:String;
	public var buffer:GLBuffer;	
	public var references:Int;
	public var capacity:Int = 0;
	public var is32Bits:Bool = false;
	
	
	public function new(buffer:GLBuffer) {
		id = Tools.uuid();
		this.buffer = buffer;
		this.references = 1;
	}
	
}
