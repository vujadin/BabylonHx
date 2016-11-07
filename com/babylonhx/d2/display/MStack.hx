package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Point;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MStack {
	
	public var mats:Array<Float32Array>;
	public var size:Int;
	

	public function new() {
		this.mats = [];
		this.size = 1;
		for (i in 0...30) {
			this.mats.push(Point._m4_Create());
		}
	}
	
	inline public function clear() {
		this.size = 1;
	}

	inline public function push(m:Float32Array) {
		var s = this.size++;
		Point._m4_Multiply(this.mats[s - 1], m, this.mats[s]);
	}
	
	inline public function pop() {
		this.size--;
	}
	
	inline public function top():Float32Array {
		return this.mats[this.size - 1];
	}
	
}
