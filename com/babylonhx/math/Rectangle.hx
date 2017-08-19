package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Rectangle {

	public var bottom(get, set):Float;
	public var bottomRight(get, set):Vector2;
	public var height:Float;
	public var left(get, set):Float;
	public var right(get, set):Float;
	public var size(get, set):Vector2;
	public var top(get, set):Float;
	public var topLeft(get, set):Vector2;
	public var width:Float;
	public var x:Float;
	public var y:Float;
	
	
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {		
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;		
	}	
	
	public function clone():Rectangle {		
		return new Rectangle (x, y, width, height);		
	}	
	
	public function contains(x:Float, y:Float):Bool {		
		return x >= this.x && y >= this.y && x < right && y < bottom;		
	}	
	
	public function containsPoint(point:Vector2):Bool {		
		return contains(point.x, point.y);		
	}	
	
	public function containsRect(rect:Rectangle):Bool {		
		if (rect.width <= 0 || rect.height <= 0) {			
			return rect.x > x && rect.y > y && rect.right < right && rect.bottom < bottom;			
		} 
		else {			
			return rect.x >= x && rect.y >= y && rect.right <= right && rect.bottom <= bottom;			
		}		
	}	
	
	public function copyFrom(sourceRect:Rectangle) {		
		x = sourceRect.x;
		y = sourceRect.y;
		width = sourceRect.width;
		height = sourceRect.height;		
	}	
	
	public function equals(toCompare:Rectangle):Bool {		
		return toCompare != null && x == toCompare.x && y == toCompare.y && width == toCompare.width && height == toCompare.height;		
	}
	
	public function intersection(toIntersect:Rectangle):Rectangle {		
		var x0 = x < toIntersect.x ? toIntersect.x : x;
		var x1 = right > toIntersect.right ? toIntersect.right : right;
		
		if (x1 <= x0) {			
			return new Rectangle();			
		}
		
		var y0 = y < toIntersect.y ? toIntersect.y : y;
		var y1 = bottom > toIntersect.bottom ? toIntersect.bottom : bottom;
		
		if (y1 <= y0) {			
			return new Rectangle();			
		}
		
		return new Rectangle(x0, y0, x1 - x0, y1 - y0);		
	}
	
	
	public function intersects(toIntersect:Rectangle):Bool {		
		var x0 = x < toIntersect.x ? toIntersect.x : x;
		var x1 = right > toIntersect.right ? toIntersect.right : right;
		
		if (x1 <= x0) {			
			return false;			
		}
		
		var y0 = y < toIntersect.y ? toIntersect.y : y;
		var y1 = bottom > toIntersect.bottom ? toIntersect.bottom : bottom;
		
		return y1 > y0;		
	}
	
	public function setTo(xa:Float, ya:Float, widtha:Float, heighta:Float) {		
		x = xa;
		y = ya;
		width = widtha;
		height = heighta;		
	}
	
	public function union(toUnion:Rectangle):Rectangle {		
		if (width == 0 || height == 0) {			
			return toUnion.clone();			
		} 
		else if (toUnion.width == 0 || toUnion.height == 0) {			
			return clone();			
		}
		
		var x0 = x > toUnion.x ? toUnion.x : x;
		var x1 = right < toUnion.right ? toUnion.right : right;
		var y0 = y > toUnion.y ? toUnion.y : y;
		var y1 = bottom < toUnion.bottom ? toUnion.bottom : bottom;
		
		return new Rectangle(x0, y0, x1 - x0, y1 - y0);		
	}
	
	inline private function get_bottom():Float { return y + height; }
	inline private function set_bottom(b:Float):Float { height = b - y; return b; }
	inline private function get_bottomRight():Vector2 { return new Vector2(x + width, y + height); }
	inline private function set_bottomRight(p:Vector2):Vector2 { width = p.x - x; height = p.y - y; return p.clone(); }
	inline private function get_left():Float { return x; }
	inline private function set_left(l:Float):Float { width -= l - x; x = l; return l; }
	inline private function get_right():Float { return x + width; }
	inline private function set_right(r:Float):Float { width = r - x; return r; }
	inline private function get_size():Vector2 { return new Vector2(width, height); }
	inline private function set_size(p:Vector2):Vector2 { width = p.x; height = p.y; return p.clone(); }
	inline private function get_top():Float { return y; }
	inline private function set_top(t:Float):Float { height -= t - y; y = t; return t; }
	inline private function get_topLeft():Vector2 { return new Vector2(x, y); }
	inline private function set_topLeft(p:Vector2):Vector2 { x = p.x; y = p.y; return p.clone(); }
	
}
