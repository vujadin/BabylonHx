package com.babylonhx.tools.hdr;

import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CMGBoundinBox {
	
	public var min:Vector3;
	public var max:Vector3;
	
	
	public function new() {
		this.min = new Vector3(0, 0, 0);
		this.max = new Vector3(0, 0, 0);
		
		this.clear();
	}
	
	public function clear() {
		this.min.x = Math.POSITIVE_INFINITY;
		this.min.y = Math.POSITIVE_INFINITY;
		this.min.z = Math.POSITIVE_INFINITY;
		
		this.max.x = Math.NEGATIVE_INFINITY;
		this.max.y = Math.NEGATIVE_INFINITY;
		this.max.z = Math.NEGATIVE_INFINITY;
	}
	
	public function augment(x:Float, y:Float, z:Float) {
		this.min.x = Math.min(this.min.x, x);
		this.min.y = Math.min(this.min.y, y);
		this.min.z = Math.min(this.min.z, z);
		this.max.x = Math.max(this.max.x, x);
		this.max.y = Math.max(this.max.y, y);
		this.max.z = Math.max(this.max.z, z);
	}
	
	public function clampMin(x:Float, y:Float, z:Float) {
		this.min.x = Math.max(this.min.x, x);
		this.min.y = Math.max(this.min.y, y);
		this.min.z = Math.max(this.min.z, z);
	}
	
	public function clampMax(x:Float, y:Float, z:Float) {
		this.max.x = Math.min(this.max.x, x);
		this.max.y = Math.min(this.max.y, y);
		this.max.z = Math.min(this.max.z, z);
	}
	
	public function empty():Bool {
		if( (this.min.x > this.max.y) ||
			(this.min.y > this.max.y) ||
			(this.min.z > this.max.y) )
		{
			return true;
		}
		else {
			return false;    
		}
	}
	
}
