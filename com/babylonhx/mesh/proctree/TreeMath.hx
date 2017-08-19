package com.babylonhx.mesh.proctree;

/**
 * ...
 * @author Krtolica Vujadin
 */

// ported from https://github.com/supereggbert/proctree.js
class TreeMath {

	static public inline function dot(v1:Array<Float>, v2:Array<Float>) {
		return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
	}
	
	static public inline function cross(v1:Array<Float>, v2:Array<Float>) {
		return [v1[1] * v2[2] - v1[2] * v2[1], v1[2] * v2[0] - v1[0] * v2[2], v1[0] * v2[1] - v1[1] * v2[0]];
	}
	
	static public inline function length(v:Array<Float>) {
		return Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
	}

	static public inline function normalize(v:Array<Float>) {
		var l = length(v);
		
		return scaleVec(v, 1 / l);
	}
	static public inline function scaleVec(v:Array<Float>, s:Float):Array<Float> {
		return [v[0] * s, v[1] * s, v[2] * s];
	}

	static public inline function subVec(v1:Array<Float>, v2:Array<Float>):Array<Float> {
		return [v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2]];
	}
	
	static public inline function addVec(v1:Array<Float>, v2:Array<Float>):Array<Float> {
		return [v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]];
	}

	static public inline function vecAxisAngle(vec:Array<Float>, axis:Array<Float>, angle:Float):Array<Float> {
		//v cos(T) + (axis x v) * sin(T) + axis*(axis . v)(1-cos(T)
		var cosr = Math.cos(angle);
		var sinr = Math.sin(angle);
		return addVec(addVec(scaleVec(vec, cosr), scaleVec(cross(axis, vec), sinr)), scaleVec(axis, dot(axis, vec) * (1 - cosr)));
	}
	
	static public inline function scaleInDirection(vector:Array<Float>, direction:Array<Float>, scale:Float):Array<Float> {
		var currentMag = dot(vector, direction);		
		var change = scaleVec(direction, currentMag * scale - currentMag);
		
		return addVec(vector, change);
	}

	static public function flattenArray<T>(input:Array<Array<T>>):Array<T> {
        var retArray:Array<T> = [];
    	for (i in 0...input.length) {
    		for (j in 0...input[i].length) {
    			retArray.push(input[i][j]);
    		}
    	}
		
    	return retArray;
    }

}