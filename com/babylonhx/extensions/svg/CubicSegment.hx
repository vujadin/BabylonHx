package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg
class CubicSegment  extends PathSegment {
	
	public var cx1:Float;
	public var cy1:Float;
	public var cx2:Float;
	public var cy2:Float;
   

	public function new(inCX1:Float, inCY1:Float, inCX2:Float, inCY2:Float, inX:Float, inY:Float) {
		super(inX, inY);
		cx1 = inCX1;
		cy1 = inCY1;
		cx2 = inCX2;
		cy2 = inCY2;
	}

	override public function prevCX() {
		return cx2;
	}
	override public function prevCY() {
		return cy2;
	}

	function Interp(a:Float, b:Float, frac:Float) {
		return a + (b - a) * frac;
	}

	public function toQuadratics(tx0:Float,ty0:Float):Array<QuadraticSegment> {
		var result = new Array<QuadraticSegment>();
		// from http://www.timotheegroleau.com/Flash/articles/cubic_bezier/bezier_lib.as
		
		var pa_x = Interp(tx0, cx1, 0.75);
		var pa_y = Interp(ty0, cy1, 0.75);
		var pb_x = Interp(x, cx2, 0.75);
		var pb_y = Interp(y, cy2, 0.75);
		
		// get 1/16 of the [P3, P0] segment
		var dx = (x - tx0) / 16;
		var dy = (y - ty0) / 16;
		
		// calculates control point 1
		var pcx_1 = Interp(tx0, cx1, 3 / 8);
		var pcy_1 = Interp(ty0, cy1, 3 / 8);
		
		// calculates control point 2
		var pcx_2 = Interp(pa_x, pb_x, 3 / 8) - dx;
		var pcy_2 = Interp(pa_y, pb_y, 3 / 8) - dy;
		
		// calculates control point 3
		var pcx_3 = Interp(pb_x, pa_x, 3 / 8) + dx;
		var pcy_3 = Interp(pb_y, pa_y, 3 / 8) + dy;
		
		// calculates control point 4
		var pcx_4 = Interp(x, cx2, 3 / 8);
		var pcy_4 = Interp(y, cy2, 3 / 8);
		
		// calculates the 3 anchor points
		var pax_1 = (pcx_1 + pcx_2) * 0.5;
		var pay_1 = (pcy_1 + pcy_2) * 0.5;
		
		var pax_2 = (pa_x + pb_x) * 0.5;
		var pay_2 = (pa_y + pb_y) * 0.5;
		
		var pax_3 = (pcx_3 + pcx_4) * 0.5;
		var pay_3 = (pcy_3 + pcy_4) * 0.5;
		
		// draw the four quadratic subsegments
		result.push(new QuadraticSegment(pcx_1, pcy_1, pax_1, pay_1));
		result.push(new QuadraticSegment(pcx_2, pcy_2, pax_2, pay_2));
		result.push(new QuadraticSegment(pcx_3, pcy_3, pax_3, pay_3));
		result.push(new QuadraticSegment(pcx_4, pcy_4, x, y));
		
		return result;
	}

	override public function getType():Int {
		return PathSegment.CUBIC; 
	}
	
}
