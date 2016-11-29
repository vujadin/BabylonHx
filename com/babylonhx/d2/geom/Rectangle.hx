package com.babylonhx.d2.geom;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A basic class for representing an axis-aligned rectangle
 * @author Ivan Kuckir
 *
 */
class Rectangle {
	
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	
	private var _temp = new Float32Array(2);
	
	
	inline public function new(x:Float = 0, y:Float = 0, w:Float = 1, h:Float = 1) {	
		this.x = x;
		this.y = y;
		this.width = w;
		this.height = h;		
	}
	
	inline public function clone():Rectangle {
		return new Rectangle(this.x, this.y, this.width, this.height);
	}
	
	inline public function contains(x:Float, y:Float):Bool {
		return (x >= this.x && x <= this.x + this.width) && (y >= this.y && y <= this.y + this.height);
	}
	
	inline public function containsPoint(p:Point):Bool {
		return this.contains(p.x, p.y);
	}
	
	inline public function containsRect(r:Rectangle):Bool {
		return (this.x <= r.x && this.y <= r.y && r.x + r.width <= this.x + this.width && r.y + r.height <= this.y + this.height);
	}
	
	inline public function copyFrom(r:Rectangle) {
		this.x = r.x; 
		this.y = r.y; 
		this.width = r.width; 
		this.height = r.height;
	}
	
	inline public function equals(r:Rectangle):Bool {
		return(this.x == r.x && this.y == r.y && this.width == r.width && this.height == r.height);
	}
	
	inline public function inflate(dx:Float, dy:Float) {
		this.x -= dx;
		this.y -= dy;
		this.width  += 2 * dx;
		this.height += 2 * dy;
	}
	
	inline public function inflatePoint(p:Point) {
		this.inflate(p.x, p.y);
	}
	
	public function intersection(rec:Rectangle):Rectangle {
		var l = Math.max(this.x, rec.x);
		var u = Math.max(this.y, rec.y);
		var r = Math.min(this.x + this.width , rec.x + rec.width);
		var d = Math.min(this.y + this.height, rec.y + rec.height);
		
		if (r < l || d < u) {
			return new Rectangle();
		}
		else {
			return new Rectangle(l, u, r - l, d - u);
		}
	}
	
	public function intersects(r:Rectangle):Bool {	// : Boolean
		if (r.y + r.height < this.y || r.x > this.x + this.width || r.y > this.y + this.height || r.x + r.width < this.x) {
			return false;
		}
		
		return true;
	}
	
	inline public function isEmpty():Bool {
		return (this.width <= 0 || this.height <= 0);
	}
	
	inline public function offset(dx:Float, dy:Float) {
		this.x += dx; 
		this.y += dy;
	}
	
	inline public function offsetPoint(p:Point) {
		this.offset(p.x, p.y);
	}
	
	inline public function setEmpty() {
		this.x = 0;
		this.y = 0;
		this.width = 0;
		this.height = 0;
	}
	
	inline public function setTo(x:Float, y:Float, w:Float, h:Float) {
		this.x = x; 
		this.y = y; 
		this.width = w; 
		this.height = h;
	}
		
	inline public function union(r:Rectangle):Rectangle {	// : Rectangle
		if (this.isEmpty()) {
			return r.clone();
		}
		if (r.isEmpty()) {
			return this.clone();
		}
		var nr = this.clone();
		nr._unionWith(r);
		
		return nr;
	}
	
	inline public function _unionWith(r:Rectangle) { // : void
		if (r.isEmpty()) {
			return;
		}
		if (this.isEmpty()) { 
			this.copyFrom(r); 
			return; 
		}
		
		this._unionWP(r.x, r.y);
		this._unionWP(r.x + r.width, r.y + r.height);
	}
	
	inline public function _unionWP(x:Float, y:Float) {	// union with point
		var minx = Math.min(this.x, x);
		var miny = Math.min(this.y, y);
		this.width  = Math.max(this.x + this.width , x) - minx;
		this.height = Math.max(this.y + this.height, y) - miny;
		this.x = minx; 
		this.y = miny;
	}
	
	inline public function _unionWL(x0:Float, y0:Float, x1:Float, y1:Float) {	// union with point
		if (this.width == 0 && this.height == 0) {
			this._setP(x0, y0);
		}
		else {
			this._unionWP(x0, y0);
		}
		
		this._unionWP(x1, y1);
	}	
	
	inline public function _setP(x:Float, y:Float) {
		this.x = x; 
		this.y = y;
		this.width = 0;
		this.height = 0;
	}
	
}
