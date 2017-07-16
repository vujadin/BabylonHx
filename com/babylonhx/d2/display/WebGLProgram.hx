package com.babylonhx.d2.display;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;


/**
 * ...
 * @author Krtolica Vujadin
 */
class WebGLProgram {
	
	public var prog:GLProgram;
	
	public var vpa:Int;
	public var tca:Int;
	public var tMatUniform:GLUniformLocation;
	public var cMatUniform:GLUniformLocation;
	public var cVecUniform:GLUniformLocation;
	public var samplerUniform:GLUniformLocation;
	public var useTex:GLUniformLocation;
	public var color:GLUniformLocation;
	

	public function new() {
		
	}
	
}
