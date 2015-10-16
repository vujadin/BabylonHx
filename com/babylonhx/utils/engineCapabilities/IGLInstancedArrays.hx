package com.babylonhx.utils.engineCapabilities;


interface IGLInstancedArrays {
  
	public dynamic function vertexAttribDivisor (offsetLocations:Array<Int>, divisor:Int):Void;

	public dynamic function drawElementsInstanced (mode:Int, count:Int, type:Int, indices:Int, primcount:Int):Void;

	public dynamic function drawArraysInstanced (mode:Int, first:Int, count:Int, primcount:Int):Void;
	
}
