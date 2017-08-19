package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Path2;
import com.babylonhx.math.Rectangle;
import com.babylonhx.math.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PolygonLib {

	public static function Oval(centerX:Float, centerY:Float, xRadius:Float, yRadius:Float, sides:Int):Array<Vector2> {
		var points:Array<Vector2> = [];
		
		for (i in 0...sides) {
			var pointRatio = i / sides;
			var radians = pointRatio * 2 * Math.PI;
			var xSteps = Math.cos(radians);
			var ySteps = Math.sin(radians);
			
			// Change "radius" to "xRadius".
			var pointX = xSteps * xRadius;
			
			// Change "radius" to "yRadius".
			var pointY = ySteps * yRadius;
			
			points.push(new Vector2(centerX + pointX, centerY + pointY));
		}
		
		return points;
	}

	public static function Poly(x:Float, y:Float, sides:Int, radius:Float):Array<Vector2> {
		var pts:Array<Vector2> = [];
		
		// check that sides is sufficient to build
		if (sides <= 2) {
			throw "Parameter 'sides' needs to be atleast 3";
		}
		
		// calculate span of sides	
		var step:Float = (Math.PI * 2) / sides; 
		var dx:Float = 0;
		var dy:Float = 0;	
		
		// draw the polygon
		var n = 1;
		while (n <= sides) {
			dx = Math.cos((step * n)) * radius;
			dy = -Math.sin((step * n)) * radius;				
			pts.push(new Vector2(x + dx, y + dy));
			n++;
		}
		
		return pts;
	}

	public static function RoundPoly(x:Float, y:Float, sides:Int, radius:Float, division:Int = 5):Array<Vector2> {
		var pts:Array<Vector2> = [];
		
		// check that sides is sufficient to build
		if (sides <= 2) {
			throw "Parameter 'sides' needs to be atleast 3";
		}
		
		// calculate span of sides
		var step:Float = (Math.PI * 2) / sides;
		var dx:Float = 0;
		var dy:Float = 0;
		
		var n = 1;
		while (n <= sides) {
			dx = Math.cos(step * n) * radius;
			dy = -Math.sin(step * n) * radius;
			
			pts.push(new Vector2(dx, dy)); 
			
			n++;
		}		
		
		var pp:Array<Vector2> = [];
		var i = 1;
		while (i < pts.length - 1) {
			pp.push(new Vector2(pts[i].x + ((pts[i-1].x - pts[i].x) / division), pts[i].y + ((pts[i-1].y - pts[i].y) / division)));
			pp.push(new Vector2(pts[i].x, pts[i].y));
			pp.push(new Vector2(pts[i].x + ((pts[i+1].x - pts[i].x) / division), pts[i].y + ((pts[i+1].y - pts[i].y) / division)));
			i += 1;
		}
		
		var lastp:Int = pts.length - 1;
		pp.push(new Vector2(pts[lastp].x + (pts[lastp-1].x - pts[lastp].x) / division, pts[lastp].y + (pts[lastp-1].y - pts[lastp].y) / division));
		pp.push(new Vector2(pts[lastp].x, pts[lastp].y));
		pp.push(new Vector2(pts[lastp].x + (pts[0].x - pts[lastp].x) / division, pts[lastp].y + (pts[0].y - pts[lastp].y) / division));
		
		pp.push(new Vector2(pts[0].x + (pts[lastp].x - pts[0].x) / division, pts[0].y + (pts[lastp].y - pts[0].y) / division));
		pp.push(new Vector2(pts[0].x, pts[0].y));
		pp.push(new Vector2(pts[0].x + (pts[1].x - pts[0].x) / division, pts[0].y + (pts[1].y - pts[0].y) / division));
		
		pts = [];
		
		i = 0;
		while(i < pp.length - 2) {
			var abXd = (pp[i + 1].x - pp[i].x) / division;
			var abYd = (pp[i + 1].y - pp[i].y) / division;
			var bcXd = ((i + 2 >= pp.length ? pp[0].x : pp[i + 2].x) - pp[i + 1].x) / division;
			var bcYd = ((i + 2 >= pp.length ? pp[0].y : pp[i + 2].y) - pp[i + 1].y) / division;
			
			for (n in 1...division) {
				var dX = abXd * n + pp[i].x;
				var dY = abYd * n + pp[i].y;
				var eX = bcXd * n + pp[i + 1].x;
				var eY = bcYd * n + pp[i + 1].y;
				
				if (i == 0 && n == 1) {	
					pts.push(new Vector2(x + (eX - dX) / division * n + dX, y + (eY - dY) / division * n + dY));
				} 
				else {	
					pts.push(new Vector2(x + (eX - dX) / division * n + dX, y + (eY - dY) / division * n + dY));
				}							
			}
			
			i += 3;
		}
		
		return pts;
	}
	
	public static function Star(x:Float, y:Float, sides:Int, innerRadius:Float, outerRadius:Float):Array<Vector2> {
		var pts:Array<Vector2> = [];
		
		// check that sides is sufficient to build
		if (sides <= 2) {
			throw "Parameter 'sides' needs to be atleast 3";
		}
		
		// calculate distance between points
		var step:Float = (Math.PI * 2) / sides;
		var halfStep:Float = step / 2;
		var dx:Float = 0;
		var dy:Float = 0;
		
		// draw lines
		var n = 1;
		while (n <= sides) {
			dx = Math.cos((step * n) - halfStep) * innerRadius;
			dy = -Math.sin((step * n) - halfStep) * innerRadius;				
			pts.push(new Vector2(x + dx, y + dy));
			
			dx = Math.cos((step * n)) * outerRadius;
			dy = -Math.sin((step * n)) * outerRadius;				
			pts.push(new Vector2(x + dx, y + dy));
			
			n++;
		}
		
		return pts;		
	}
	
	public static function RoundStar(x:Float, y:Float, sides:Int, innerRadius:Float, outerRadius:Float, division:Int = 5):Array<Vector2> {
		var pts:Array<Vector2> = [];
		// check that points is sufficient to build polygon
		if (sides <= 2) {
			throw "Parameter 'sides' needs to be atleast 3";
		}
		
		// calculate distance between points
		var step:Float = (Math.PI * 2) / sides;
		var halfStep:Float = step / 2;
		var dx:Float = 0;
		var dy:Float = 0;
		
		var n = 1;
		while (n <= sides) {
			dx = Math.cos((step * n) - halfStep) * innerRadius;
			dy = -Math.sin((step * n) - halfStep) * innerRadius;			
			pts.push(new Vector2(dx, dy));
			
			dx = Math.cos((step * n)) * outerRadius;
			dy = -Math.sin((step * n)) * outerRadius;
			pts.push(new Vector2(dx, dy));
			
			n++;			
		}
		
		var pp:Array<Vector2> = [];
		var i = 1;
		while (i < pts.length - 1) {
			pp.push(new Vector2(pts[i].x + ((pts[i-1].x - pts[i].x) / division), pts[i].y + ((pts[i-1].y - pts[i].y) / division)));
			pp.push(new Vector2(pts[i].x, pts[i].y));
			pp.push(new Vector2(pts[i].x + ((pts[i+1].x - pts[i].x) / division), pts[i].y + ((pts[i+1].y - pts[i].y) / division)));
			i += 1;
		}
		
		var lastp:Int = pts.length - 1;
		pp.push(new Vector2(pts[lastp].x + (pts[lastp-1].x - pts[lastp].x) / division, pts[lastp].y + (pts[lastp-1].y - pts[lastp].y) / division));
		pp.push(new Vector2(pts[lastp].x, pts[lastp].y));
		pp.push(new Vector2(pts[lastp].x + (pts[0].x - pts[lastp].x) / division, pts[lastp].y + (pts[0].y - pts[lastp].y) / division));
		
		pp.push(new Vector2(pts[0].x + (pts[lastp].x - pts[0].x) / division, pts[0].y + (pts[lastp].y - pts[0].y) / division));
		pp.push(new Vector2(pts[0].x, pts[0].y));
		pp.push(new Vector2(pts[0].x + (pts[1].x - pts[0].x) / division, pts[0].y + (pts[1].y - pts[0].y) / division));
		
		pts = [];
		
		i = 0;
		while(i < pp.length - 2) {
			var abXd = (pp[i + 1].x - pp[i].x) / division;
			var abYd = (pp[i + 1].y - pp[i].y) / division;
			var bcXd = ((i + 2 >= pp.length ? pp[0].x : pp[i + 2].x) - pp[i + 1].x) / division;
			var bcYd = ((i + 2 >= pp.length ? pp[0].y : pp[i + 2].y) - pp[i + 1].y) / division;											
		
			for (n in 1...division) {
				var dX = abXd * n + pp[i].x;
				var dY = abYd * n + pp[i].y;
				var eX = bcXd * n + pp[i + 1].x;
				var eY = bcYd * n + pp[i + 1].y;
					
				if (i == 0 && n == 1) {	
					pts.push(new Vector2((eX - dX) / division * n + dX, (eY - dY) / division * n + dY));
				} 
				else {	
					pts.push(new Vector2((eX - dX) / division * n + dX, (eY - dY) / division * n + dY));
				}							
			}	
			
			i += 3;
		}
		
		return pts;
	}

	public static function Gear(x:Float, y:Float, sides:Int = 5, innerRadius:Float = 8, outerRadius:Float = 10):Array<Vector2> {
		var pts:Array<Vector2> = [];
		
		// check that sides is sufficient to build polygon
		if (sides <= 2) {
			throw "Parameter 'sides' needs to be atleast 3";
		}
		
		// calculate length of sides
		var step:Float = (Math.PI * 2) / sides;
		var qtrStep:Float = step / 4;
		var dx:Float = 0;
		var dy:Float = 0;
		
		var n = 1;
		while (n <= sides) {
			dx = Math.cos((step * n) - (qtrStep * 3)) * innerRadius;
			dy = -Math.sin((step * n) - (qtrStep * 3)) * innerRadius;			
			pts.push(new Vector2(x + dx, y + dy));
			
			dx = Math.cos((step * n) - (qtrStep * 2)) * innerRadius;
			dy = -Math.sin((step * n) - (qtrStep * 2)) * innerRadius;
			pts.push(new Vector2(x + dx, y + dy));
			
			dx = Math.cos((step * n) - qtrStep) * outerRadius;
			dy = -Math.sin((step * n) - qtrStep) * outerRadius;
			pts.push(new Vector2(x + dx, y + dy));
			
			dx = Math.cos(step * n) * outerRadius;
			dy = -Math.sin(step * n) * outerRadius;
			pts.push(new Vector2(x + dx, y + dy));
			
			n++;
		}
		
		return pts;
	}
	
	public static function RoundGear(x:Float, y:Float, sides:Int = 5, innerRadius:Float = 8, outerRadius:Float = 10, division:Int = 5, angle:Float = 0):Array<Vector2> {
		var pts:Array<Vector2> = [];
		// check that sides is sufficient to build polygon
		if (sides <= 2) {
			throw "Parameter 'sides' needs to be atleast 3";
		}
		
		// calculate length of sides
		var step:Float = (Math.PI * 2) / sides;
		var qtrStep:Float = step / 4;
		var dx:Float = 0;
		var dy:Float = 0;
		
		// calculate starting angle in radians
		var start:Float = (angle / 180) * Math.PI;
		
		var n = 1;
		while (n <= sides) {
			dx = Math.cos(start + (step * n) - (qtrStep * 3)) * innerRadius;
			dy = -Math.sin(start + (step * n) - (qtrStep * 3)) * innerRadius;
			pts.push(new Vector2(dx, dy));
			
			dx = Math.cos(start + (step * n) - (qtrStep * 2)) * innerRadius;
			dy = -Math.sin(start + (step * n) - (qtrStep * 2)) * innerRadius;
			pts.push(new Vector2(dx, dy));
			
			dx = Math.cos(start + (step * n) - qtrStep) * outerRadius;
			dy = -Math.sin(start + (step * n) - qtrStep) * outerRadius;
			pts.push(new Vector2(dx, dy));
			
			dx = Math.cos(start + (step * n)) * outerRadius;
			dy = -Math.sin(start + (step * n)) * outerRadius;
			pts.push(new Vector2(dx, dy));
			
			n++;
		}
		
		var pp:Array<Vector2> = [];
		var i = 1;
		while (i < pts.length - 1) {
			pp.push(new Vector2(pts[i].x + ((pts[i-1].x - pts[i].x) / division), pts[i].y + ((pts[i-1].y - pts[i].y) / division)));
			pp.push(new Vector2(pts[i].x, pts[i].y));
			pp.push(new Vector2(pts[i].x + ((pts[i+1].x - pts[i].x) / division), pts[i].y + ((pts[i+1].y - pts[i].y) / division)));
			i += 1;
		}
		
		var lastp:Int = pts.length - 1;
		pp.push(new Vector2(pts[lastp].x + (pts[lastp-1].x - pts[lastp].x) / division, pts[lastp].y + (pts[lastp-1].y - pts[lastp].y) / division));
		pp.push(new Vector2(pts[lastp].x, pts[lastp].y));
		pp.push(new Vector2(pts[lastp].x + (pts[0].x - pts[lastp].x) / division, pts[lastp].y + (pts[0].y - pts[lastp].y) / division));
		
		pp.push(new Vector2(pts[0].x + (pts[lastp].x - pts[0].x) / division, pts[0].y + (pts[lastp].y - pts[0].y) / division));
		pp.push(new Vector2(pts[0].x, pts[0].y));
		pp.push(new Vector2(pts[0].x + (pts[1].x - pts[0].x) / division, pts[0].y + (pts[1].y - pts[0].y) / division));
		
		pts = [];
		
		i = 0;
		while(i < pp.length - 2) {
			var abXd = (pp[i + 1].x - pp[i].x) / division;
			var abYd = (pp[i + 1].y - pp[i].y) / division;
			var bcXd = ((i + 2 >= pp.length ? pp[0].x : pp[i + 2].x) - pp[i + 1].x) / division;
			var bcYd = ((i + 2 >= pp.length ? pp[0].y : pp[i + 2].y) - pp[i + 1].y) / division;
			
			for (n in 1...division) {
				var dX = abXd * n + pp[i].x;
				var dY = abYd * n + pp[i].y;
				var eX = bcXd * n + pp[i + 1].x;
				var eY = bcYd * n + pp[i + 1].y;
				
				if (i == 0 && n == 1) {	
					pts.push(new Vector2((eX - dX) / division * n + dX, (eY - dY) / division * n + dY));
				} 
				else {
					pts.push(new Vector2((eX - dX) / division * n + dX, (eY - dY) / division * n + dY));
				}							
			}
			
			i += 3;
		}
		
		pts.reverse();
		
		return pts;
	}
	
	static public function Rect(x:Float, y:Float, width:Float, height:Float):Array<Vector2> {
		return [
			new Vector2(x, y),
			new Vector2(width, y),
			new Vector2(width, height),
			new Vector2(x, height)
		];
	}

	static public function RoundRect(x:Float, y:Float, width:Float, height:Float, division:Int = 5):Array<Vector2> {
		var rect:Rectangle = new Rectangle(x, y, width, height);
		
		var pts:Array<Vector2> = [];
		
		pts.push(new Vector2(0, 0));
		pts.push(new Vector2(rect.width, 0));
		pts.push(new Vector2(rect.width, rect.height));
		pts.push(new Vector2(0, rect.height));
		
		if (pts[0].x > pts[1].x && pts[0].y < pts[2].y) {						
			var tempPts = pts.copy();
			pts = [];
			pts.push(tempPts[1]);
			pts.push(tempPts[0]);
			pts.push(tempPts[3]);
			pts.push(tempPts[2]);
		}
		
		if (pts[0].x > pts[1].x && pts[0].y > pts[2].y) {
			var tempPts = pts.copy();
			pts = [];
			pts.push(tempPts[2]);
			pts.push(tempPts[3]);
			pts.push(tempPts[0]);
			pts.push(tempPts[1]);
		}
		
		if (pts[0].x < pts[1].x && pts[0].y > pts[2].y) {
			var tempPts = pts.copy();
			pts = [];
			pts.push(tempPts[3]);
			pts.push(tempPts[2]);
			pts.push(tempPts[1]);
			pts.push(tempPts[0]);
		}
		
		var radLimit:Float = Math.abs(rect.width) > Math.abs(rect.height) ? Math.abs(rect.height) / 8 : Math.abs(rect.width) / 8;
		
		var ptsf:Array<Vector2> = [];
		
		// topLeft corner
		ptsf.push(new Vector2(pts[0].x, pts[0].y + radLimit));
		ptsf.push(new Vector2(pts[0].x, pts[0].y));
		ptsf.push(new Vector2(pts[0].x + radLimit, pts[0].y));
		
		// topRight corner
		ptsf.push(new Vector2(pts[1].x - radLimit, pts[1].y));
		ptsf.push(new Vector2(pts[1].x, pts[1].y));
		ptsf.push(new Vector2(pts[1].x, pts[1].y + radLimit));
		
		// bottomRight corner
		ptsf.push(new Vector2(pts[2].x, pts[2].y - radLimit));
		ptsf.push(new Vector2(pts[2].x, pts[2].y));
		ptsf.push(new Vector2(pts[2].x - radLimit, pts[2].y));
		
		// bottomLeft corner
		ptsf.push(new Vector2(pts[3].x + radLimit, pts[3].y));
		ptsf.push(new Vector2(pts[3].x, pts[3].y));
		ptsf.push(new Vector2(pts[3].x, pts[3].y - radLimit));
		
		pts = [];
		
		var i:Int = 0;
		while(i < ptsf.length - 2) {
			var abXd = (ptsf[i + 1].x - ptsf[i].x) / division;
			var abYd = (ptsf[i + 1].y - ptsf[i].y) / division;
			var bcXd = (ptsf[i + 2].x - ptsf[i + 1].x) / division;
			var bcYd = (ptsf[i + 2].y - ptsf[i + 1].y) / division;
			
			for (n in 1...division) {
				var dX = abXd * n + ptsf[i].x;
				var dY = abYd * n + ptsf[i].y;
				var eX = bcXd * n + ptsf[i + 1].x;
				var eY = bcYd * n + ptsf[i + 1].y;
				
				pts.push(new Vector2(x + (eX - dX) / division * n + dX, y + (eY - dY) / division * n + dY));
			}	
			
			i += 3;
		}
		
		return pts;
	}

	static public function Circle(radius:Float, cx:Float = 0, cy:Float = 0, numberOfSides:Int = 32):Array<Vector2> {
		var result:Array<Vector2> = [];
		
		var angle:Float = 0;
		var increment:Float = (Math.PI * 2) / numberOfSides;
		
		for (i in 0...numberOfSides) {
			result.push(new Vector2(cx + Math.cos(angle) * radius, cy + Math.sin(angle) * radius));
			angle -= increment;
		}
		
		return result;
	}

	static public function SuperShape2(m:Float, n1:Float, n2:Float, n3:Float, rep:Int = 160):Array<Vector2> {
		var result:Array<Vector2> = [];
		
		var r:Float = 0;
		var t1:Float = 0;
		var t2:Float = 0;
		var a:Float = 1;
		var b:Float = 1;
		
		var scale:Float = 30;
		
		for (i in 0...rep) {
			var phi = i * Tools.TWOPI / rep;
			
			t1 = Math.cos(m * phi / 4) / a;
			t1 = Math.abs(t1);
			t1 = Math.pow(t1, n2);
			
			t2 = Math.sin(m * phi / 4) / b;
			t2 = Math.abs(t2);
			t2 = Math.pow(t2, n3);
			
			r = Math.pow(t1 + t2, 1 / n1);
			if (Math.abs(r) == 0) {
				result.push(new Vector2(0, 0));
			} 
			else {
				r = 1 / r;
				result.push(new Vector2(r * Math.cos(phi) * scale, r * Math.sin(phi) * scale));
			}
		}
		
		return result;
	}

	static public function SuperShape(a:Float, b:Float, m:Float, n1:Float, n2:Float, n3:Float, scale:Float):Array<Vector2> {
		var result:Array<Vector2> = [];
		
		var r:Float = 0;
		var p:Float = 0;
		var xp:Float = 0;
		var yp:Float = 0;
		
		while (p <= Tools.TWOPI) {
			var ang = m * p / 4;
			
			r = Math.pow(Math.pow(Math.abs(Math.cos(ang) / a), n2) + Math.pow(Math.abs(Math.sin(ang) / b), n3), -1 / n1);
			xp = r * Math.cos(p);
			yp = r * Math.sin(p);
			
			p += .01;
			result.push(new Vector2(xp * scale, yp * scale));
		}
		
		return result;
	}

	static public inline function Parse(input:String, separator:String = " "):Array<Vector2> {
		//var regx = ~/[^-+eE\.\d]+/i;
		//var floats = regx.split(input).map(Std.parseFloat).filter(function(val):Bool { return !Math.isNaN(val); } );
		var floats = input.split(separator).map(Std.parseFloat);
		var i:Int = 0;
		var result:Array<Vector2> = [];
		while(i < (floats.length & 0x7FFFFFFE)) {
			result.push(new Vector2(floats[i], floats[i + 1]));
			i += 2;
		}
		
		return result;
	}

	static public inline function StartingAt(x:Float, y:Float):Path2 {
		return Path2.StartingAt(x, y);
	}

	public static function SmoothMcMaster(points:Array<Vector2>):Array<Vector2> {
		var nL:Array<Vector2> = [];
		var len:Int = points.length;
		if (len < 5) { 
			return points;
		}
		
		var j:Int = 0;
		var avX:Float = 0;
		var avY:Float = 0;
		var i:Int = len;
		while (i-- > 0) {
			if (i == len - 1 || i == len - 2 || i == 1 || i == 0) {
				nL[i] = new Vector2(points[i].x, points[i].y);
			}
			else {
				j = 5;
				avX = 0;
				avY = 0;
				while (j-- > 0) {
					avX += points[i + 2 - j].x; 
					avY += points[i + 2 - j].y;
				}
				avX = avX / 5; 
				avY = avY / 5;
				nL[i] = new Vector2((points[i].x + avX) / 2, (points[i].y + avY) / 2);
			}
		}
		
		return nL;
	}
	
}
