package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Point;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Line {
	
	public var begin:Int;
	public var end:Int;
	public var width:Float;
	public var color:Float32Array;
	

	public function new(begin:Int, conf:Dynamic) {
		this.begin = begin;	// index to first point
		this.end   = -1;	// index to last point
		this.width = conf.lwidth;
		this.color = conf.lcolor;
		
		//this.dirty = true;
	}
	
	public function Set(begin:Int, conf:Dynamic) {
		this.begin = begin;	// index to first point
		this.end   = -1;	// index to last point
		this.width = conf.lwidth;
		this.color = conf.lcolor;
	}
	
	inline public function isEmpty():Bool {
		return this.begin == this.end;
	}
	
	
	static public function GetTriangles(ps:Array<Float>, lbeg:Int, lend:Int, line:Line, close:Bool, ind:Array<Int>, vrt:Array<Float>) {
		var vnum = Std.int(vrt.length / 3);
		var l = lend - lbeg - 2;
		
		if (close) {
			Line.AddJoint(ps, lend, lbeg, lbeg + 2, line.width, vrt);
		}
		else {
			Line.AddEnd(ps, lbeg, lbeg + 2, true, line.width, vrt);
		}
		
		var i:Int = 0;
		while (i < l) {
			Line.AddJoint(ps, lbeg + i, lbeg + i + 2, lbeg + i + 4, line.width, vrt);
			ind.push(vnum + i + 0);
			ind.push(vnum + i + 1);
			ind.push(vnum + i + 2);
			ind.push(vnum + i + 1);
			ind.push(vnum + i + 2);
			ind.push(vnum + i + 3);
			i += 2;
		}
		
		if (close) {
			Line.AddJoint(ps, lbeg + l, lbeg + l + 2, lbeg, line.width, vrt);
			ind.push(vnum + l + 0);
			ind.push(vnum + l + 1);
			ind.push(vnum + l + 2);
			ind.push(vnum + l + 1);
			ind.push(vnum + l + 2);
			ind.push(vnum + l + 3);
			ind.push(vnum + l + 2);
			ind.push(vnum + l + 3);
			ind.push(vnum + 0);
			ind.push(vnum + l + 3);
			ind.push(vnum + 0);
			ind.push(vnum + 1);
		}
		else {
			Line.AddEnd(ps, lbeg + l, lbeg + l + 2, false, line.width, vrt);
			ind.push(vnum + 0 + l);
			ind.push(vnum + 1 + l);
			ind.push(vnum + 2 + l);
			ind.push(vnum + 1 + l);
			ind.push(vnum + 2 + l);
			ind.push(vnum + 3 + l);
		}
	}
	
	static public function AddEnd(ps:Array<Float>, i0:Int, i1:Int, start:Bool, width:Float, vrt:Array<Float>) {
		var x1 = ps[i0], y1 = ps[i0 + 1];
		var x2 = ps[i1], y2 = ps[i1 + 1];
		
		var il = 0.5 * width / Graphics.len(x1 - x2, y1 - y2);
		var dx =  il * (y1 - y2); 
		var dy = -il * (x1 - x2);
		
		if (start) {
			vrt.push(x1 + dx);
			vrt.push(y1 + dy);
			vrt.push(0);
			vrt.push(x1 - dx);
			vrt.push(y1 - dy);
			vrt.push(0);
		}
		else {
			vrt.push(x2 + dx);
			vrt.push(y2 + dy);
			vrt.push(0);
			vrt.push(x2 - dx);
			vrt.push(y2 - dy);
			vrt.push(0);
		}
	}
	
	static public function AddJoint(ps:Array<Float>, i0:Int, i1:Int, i2:Int, width:Float, vrt:Array<Float>) {
		var a1 = new Point(), a2 = new Point(), b1 = new Point(), b2 = new Point(), c = new Point();
		
		var x1 = ps[i0], y1 = ps[i0 + 1];
		var x2 = ps[i1], y2 = ps[i1 + 1];
		var x3 = ps[i2], y3 = ps[i2 + 1];
		
		var ilA = 0.5 * width / Graphics.len(x1 - x2, y1 - y2);
		var ilB = 0.5 * width / Graphics.len(x2 - x3, y2 - y3);
		var dxA =  ilA * (y1 - y2), dyA = -ilA * (x1 - x2);
		var dxB =  ilB * (y2 - y3), dyB = -ilB * (x2 - x3);
		
		if (Math.abs(dxA - dxB) + Math.abs(dyA - dyB) < 0.0000001) {
			vrt.push(x2 + dxA);
			vrt.push(y2 + dyA);
			vrt.push(0);
			vrt.push(x2 - dxA);
			vrt.push(y2 - dyA);
			vrt.push(0);
			return;
		}
		
		a1.setTo(x1 + dxA, y1 + dyA);   
		a2.setTo(x2 + dxA, y2 + dyA);
		b1.setTo(x2 + dxB, y2 + dyB);   
		b2.setTo(x3 + dxB, y3 + dyB);
		PolyK._GetLineIntersection(a1, a2, b1, b2, c);
		vrt.push(c.x);
		vrt.push(c.y);
		vrt.push(0);
		
		a1.setTo(x1 - dxA, y1 - dyA);   
		a2.setTo(x2 - dxA, y2 - dyA);
		b1.setTo(x2 - dxB, y2 - dyB);   
		b2.setTo(x3 - dxB, y3 - dyB);
		PolyK._GetLineIntersection(a1, a2, b1, b2, c);
		vrt.push(c.x);
		vrt.push(c.y);
		vrt.push(0);
	}
	
}
