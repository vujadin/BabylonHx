package com.babylonhx.d2.geom;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A class for representing a 2D Vector3D
 * @author Ivan Kuckir
 */
class Vector3D {
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	
	
	inline public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0) {		
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	inline public function add(p:Vector3D):Vector3D {
		return new Vector3D(this.x + p.x, this.y + p.y, this.z + p.z, this.w + p.w);
	}

	inline public function clone():Vector3D {
		return new Vector3D(this.x, this.y, this.z, this.w);
	}
	
	inline public function copyFrom(p:Vector3D) {
		this.x = p.x; 
		this.y = p.y; 
		this.z = p.z; 
		this.w = p.w;
	}
	
	inline public function equals(p:Vector3D):Bool {
		return (this.x == p.x && this.y == p.y && this.z == p.z);
	}
	
	inline public function normalize():Float {
		var l = Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
		this.x *= 1 / l;
		this.y *= 1 / l;
		this.z *= 1 / l;
		
		return l;
	}

	inline public function setTo(xa:Float, ya:Float, za:Float) {
		this.x = xa; 
		this.y = ya; 
		this.z = za;
	}
	
	inline public function subtract(p:Vector3D):Vector3D {
		return new Vector3D(this.x - p.x, this.y - p.y, this.z - p.z, 0);
	}

	inline static public function distance(a:Vector3D, b:Vector3D):Float {
		return Vector3D._distance(a.x, a.y, a.z, b.x, b.y, b.z);
	}
	
	inline static private function _distance(x1:Float, y1:Float, z1:Float, x2:Float, y2:Float, z2:Float):Float {
		return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1));
	}
	
}
