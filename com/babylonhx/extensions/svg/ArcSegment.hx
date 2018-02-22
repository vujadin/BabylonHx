package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg
class ArcSegment extends PathSegment {
	
	var phi:Float;
	var x1:Float;
	var y1:Float;
	var rx:Float;
	var ry:Float;
	
	var fA:Bool;
	var fS:Bool;
	

	public function new(
		inX1:Float, 
		inY1:Float, 
		inRX:Float, 
		inRY:Float, 
		inRotation:Float,
		inLargeArc:Bool, 
		inSweep:Bool, 
		x:Float, 
		y:Float
	) {
		x1 = inX1;
		y1 = inY1;
		super(x,y);
		rx = inRX;
		ry = inRY;
		phi = inRotation;
		fA = inLargeArc;
		fS = inSweep;
	}

	override public function getType():Int {
		return PathSegment.ARC; 
	}
	
	override public function toGfx(inGfx:SVGDataToPointsArray, ioContext:RenderContext) {
		if (x1 == x && y1 == y) {
			return;
		}
		
		if (rx == 0 || ry == 0) {
			inGfx.lineTo(ioContext.lastX, ioContext.lastY);
			return;
		}
		if (rx < 0) {
			rx = -rx;
		}
		if (ry < 0) {
			ry = -ry;
		}
		
		// See:  http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
		var p = phi * Math.PI / 180.0;
		var cos = Math.cos(p);
		var sin = Math.sin(p);
		
		// Step 1, compute x', y'
		var dx = (x1 - x) * 0.5;
		var dy = (y1 - y) * 0.5;
		var x1_ = cos * dx + sin * dy;
		var y1_ = -sin * dx + cos * dy;	
		
		// Step 2, compute cx', cy'
		var rx2 = rx * rx;
		var ry2 = ry * ry;
		var x1_2 = x1_ * x1_;
		var y1_2 = y1_ * y1_;
		var s = (rx2 * ry2 - rx2 * y1_2 - ry2 * x1_2) / (rx2 * y1_2 + ry2 * x1_2);
		if (s < 0) {	
			s = 0;
		}
		else if (fA == fS) {
			s = -Math.sqrt(s);
		}
		else {
			s = Math.sqrt(s);
		}
		
		var cx_ = s * rx * y1_ / ry;
		var cy_ = -s * ry * x1_ / rx;
		
		// Step 3, compute cx,cy from cx',cy'
		// Something not quite right here.
		
		var xm = (x1 + x) * 0.5;
		var ym = (y1 + y) * 0.5;
		
		var cx = cos * cx_ - sin * cy_ + xm;
		var cy = sin * cx_ + cos * cy_ + ym;
		
		var theta = Math.atan2((y1_ -cy_) / ry, (x1_ -cx_) / rx);
		var dtheta = Math.atan2((-y1_ -cy_) / ry, (-x1_ -cx_) / rx) - theta;
		
		if (fS && dtheta < 0) {
			dtheta += 2.0 * Math.PI;
		}
		else if (!fS && dtheta > 0) {
			dtheta -= 2.0 * Math.PI;
		}
		
		var Txc:Float;
		var Txs:Float;
		var Tx0:Float;
		var Tyc:Float;
		var Tys:Float;
		var Ty0:Float;
		
		Txc = rx;
		Txs = 0;
		Tx0 = cx;
		Tyc = 0;
		Tys = ry;
		Ty0 = cy;
		
		var len = Math.abs(dtheta) * Math.sqrt(Txc * Txc + Txs * Txs + Tyc * Tyc + Tys * Tys);
		// TODO: Do as series of quadratics ...
		len *= 5;
		var steps = Math.round(len);
		
		if (steps > 1) {
			dtheta /= steps;
			for (i in 1...steps - 1) {
				var c = Math.cos(theta);
				var s = Math.sin(theta);
				theta += dtheta;
				inGfx.lineTo(Txc * c + Txs * s + Tx0,   Tyc * c + Tys * s + Ty0);
			}
		}
		inGfx.lineTo(ioContext.lastX, ioContext.lastY);
	}
	
}
