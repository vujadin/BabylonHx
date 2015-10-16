package com.babylonhx.utils.engineCapabilities.native;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.engineCapabilities.IGLInstancedArrays;

class GLInstancedArrays implements IGLInstancedArrays{
	
	public function new () {
		this.vertexAttribDivisor = GL.getExtension('glVertexAttribDivisorARB');
		this.drawElementsInstanced = GL.getExtension('glDrawElementsInstancedARB');
		this.drawArraysInstanced = GL.getExtension('glDrawArraysInstancedARB');
	};

	public dynamic function vertexAttribDivisor (offsetLocations:Array<Int>, divisor:Int):Void {}

	public dynamic function drawElementsInstanced (mode, count, type, indices, primcount):Void {}

	public dynamic function drawArraysInstanced (mode, first, count, primcount):Void {}
}