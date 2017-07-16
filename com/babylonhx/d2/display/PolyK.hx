package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Point;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PolyK {

	static public function Triangulate(p:Array<Float>):Array<Int> {
		var n = p.length >> 1;
		if (n < 3) {
			return [];
		}
		
		var tgs:Array<Int> = [];
		
		if (PolyK.IsConvex(p)) { 
			for (i in 1...n - 1) {
				tgs.push(0);
				tgs.push(i);
				tgs.push(i + 1);  
			}
			
			return tgs; 
		}
		
		var avl:Array<Int> = [];
		for (i in 0...n) {
			avl.push(i);
		}
		
		var i:Int = 0;
		var al:Int = n;
		while (al > 3) {
			var i0 = avl[(i + 0) % al];
			var i1 = avl[(i + 1) % al];
			var i2 = avl[(i + 2) % al];
			
			var ax = p[2 * i0],  ay = p[2 * i0 + 1];
			var bx = p[2 * i1],  by = p[2 * i1 + 1];
			var cx = p[2 * i2],  cy = p[2 * i2 + 1];
			
			var earFound = false;
			if (PolyK._convex(ax, ay, bx, by, cx, cy)) {
				earFound = true;
				for (j in 0...al) {
					var vi = avl[j];
					if (vi == i0 || vi == i1 || vi == i2) {
						continue;
					}
					if (PolyK._PointInTriangle(p[2 * vi], p[2 * vi + 1], ax, ay, bx, by, cx, cy)) {
						earFound = false; 
						break;
					}
				}
			}
			
			if (earFound) {
				tgs.push(i0);
				tgs.push(i1);
				tgs.push(i2);
				avl.splice((i + 1) % al, 1);
				al--;
				i = 0;
			}
			else if (i++ > 3 * al) {
				break;		// no convex angles :(
			}
		}
		
		tgs.push(avl[0]);
		tgs.push(avl[1]);
		tgs.push(avl[2]);
		
		return tgs;
	}
	
	static public function IsConvex(p:Array<Float>):Bool {
		if (p.length < 6) {
			return true;
		}
		var l = p.length - 4;
		var i:Int = 0;
		while (i < l) {
			if (!PolyK._convex(p[i], p[i + 1], p[i + 2], p[i + 3], p[i + 4], p[i + 5])) {
				return false;
			}
			i += 2;
		}
		if (!PolyK._convex(p[l  ], p[l + 1], p[l + 2], p[l + 3], p[0], p[1])) {
			return false;
		}
		if (!PolyK._convex(p[l + 2], p[l + 3], p[0  ], p[1  ], p[2], p[3])) {
			return false;
		}
		
		return true;
	}
	
	inline static public function _convex(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float):Bool {
		return (ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0;
	}
	
	static public function _PointInTriangle(px:Float, py:Float, ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float):Bool {
		var v0x = cx - ax, v0y = cy - ay;
		var v1x = bx - ax, v1y = by - ay;
		var v2x = px - ax, v2y = py - ay;
		
		var dot00 = v0x * v0x + v0y * v0y;
		var dot01 = v0x * v1x + v0y * v1y;
		var dot02 = v0x * v2x + v0y * v2y;
		var dot11 = v1x * v1x + v1y * v1y;
		var dot12 = v1x * v2x + v1y * v2y;
		
		var invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
		var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
		var v = (dot00 * dot12 - dot01 * dot02) * invDenom;
		
		// Check if point is in triangle
		return (u >= 0) && (v >= 0) && (u + v < 1);
	}
	
	static public function _GetLineIntersection(a1:Point, a2:Point, b1:Point, b2:Point, c:Point) {
		var dax = (a1.x - a2.x), dbx = (b1.x - b2.x);
		var day = (a1.y - a2.y), dby = (b1.y - b2.y);
		
		var Den = dax * dby - day * dbx;
		if (Den == 0) {
			return;	// parallel
		}
		
		var A = (a1.x * a2.y - a1.y * a2.x);
		var B = (b1.x * b2.y - b1.y * b2.x);
		
		c.x = (A * dbx - dax * B) / Den;
		c.y = (A * dby - day * B) / Den;
	}
	
	static public function GetArea(p:Array<Float>):Float {
		if (p.length < 6) {
			return 0;
		}
		var l:Int = p.length - 2;
		var sum:Float = 0;
		var i:Int = 0;
		while (i < l) {
			sum += (p[i + 2] - p[i]) * (p[i + 1] + p[i + 3]);
			i += 2;
		}		
		sum += (p[0] - p[l]) * (p[l + 1] + p[1]);
		
		return - sum * 0.5;
	}
	
	inline static public function Reverse(p:Array<Float>):Array<Float> {
		var np:Array<Float> = [];
		var j:Int = p.length - 2;
		while (j >= 0) {
			np.push(p[j]);
			np.push(p[j + 1]);
			j -= 2;
		}
		
		return np;
	}
	
}
