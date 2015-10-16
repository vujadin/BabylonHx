package com.babylonhx.utils.engineCapabilities.js;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.engineCapabilities.IGLInstancedArrays;

class GLInstancedArrays implements IGLInstancedArrays {

	public function new () {
		var extension = GL.getExtension('ANGLE_instanced_arrays');

		this.vertexAttribDivisor = extension.vertexAttribDivisorANGLE;
		this.drawElementsInstanced = extension.drawElementsInstancedANGLE;
		this.drawArraysInstanced = extension.drawArraysInstancedANGLE;
	};

	public dynamic function vertexAttribDivisor (offsetLocations:Array<Int>, divisor:Int):Void {}

	public dynamic function drawElementsInstanced (mode, count, type, indices, primcount):Void {}

	public dynamic function drawArraysInstanced (mode, first, count, primcount):Void {}
}