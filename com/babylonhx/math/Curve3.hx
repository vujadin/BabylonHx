package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Curve3') class Curve3 {

	private var _points:Array<Vector3>;
	private var _length:Float = 0;
	

	public function new(points:Array<Vector3>) {
		this._points = points;
		this._length = this._computeLength(points);
	}

	public function getPoints():Array<Vector3> {
		return this._points;
	}
	
	public function length():Float {
		return this._length;
	}
	
	public function _continue(curve:Curve3):Curve3 {
		var lastPoint = this._points[this._points.length - 1];
		var continuedPoints = this._points.copy();
		var curvePoints = curve.getPoints();
		for (i in 1...curvePoints.length) {
			continuedPoints.push(curvePoints[i].subtract(curvePoints[0]).add(lastPoint));
		}
		return new Curve3(continuedPoints);
	}
	
	private function _computeLength(path:Array<Vector3>):Float {
		var l = 0.0;
		for (i in 1...path.length) {
			l += (path[i].subtract(path[i - 1])).length();
		}
		return l;
	}
	
	// QuadraticBezier(origin_V3, control_V3, destination_V3, nbPoints)
	public static function CreateQuadraticBezier(v0:Vector3, v1:Vector3, v2:Vector3, nbPoints:Int = 3):Curve3 {
		nbPoints = nbPoints > 2 ? nbPoints : 3;
		var bez:Array<Vector3> = [];
		
		var equation = function(t:Float, val0:Float, val1:Float, val2:Float):Float {
			var res:Float = (1 - t) * (1 - t) * val0 + 2 * t * (1 - t) * val1 + t * t * val2;
			return res;
		};
		
		for (i in 0...nbPoints+1) {
			bez.push(new Vector3(equation(i / nbPoints, v0.x, v1.x, v2.x), equation(i / nbPoints, v0.y, v1.y, v2.y), equation(i / nbPoints, v0.z, v1.z, v2.z)));
		}
		
		return new Curve3(bez);
	}

	// CubicBezier(origin_V3, control1_V3, control2_V3, destination_V3, nbPoints)
	public static function CreateCubicBezier(v0:Vector3, v1:Vector3, v2:Vector3, v3:Vector3, nbPoints:Int = 4):Curve3 {
		nbPoints = nbPoints > 3 ? nbPoints : 4;
		var bez:Array<Vector3> = [];
		var step:Float = 1 / nbPoints;
		
		var equation = function(t:Float, val0:Float, val1:Float, val2:Float, val3:Float):Float {
			var res:Float = (1 - t) * (1 - t) * (1 - t) * val0 + 3 * t * (1 - t) * (1 -t) * val1  + 3 * t * t * (1 - t) * val2 + t * t * t * val3;
			return res;
		};
		
		for (i in 0...nbPoints+1) {
			bez.push(new Vector3(equation(i / nbPoints, v0.x, v1.x, v2.x, v3.x), equation(i / nbPoints, v0.y, v1.y, v2.y, v3.y), equation(i / nbPoints, v0.z, v1.z, v2.z, v3.z)));
		}
		
		return new Curve3(bez);
	}
	
	// HermiteSpline(origin_V3, originTangent_V3, destination_V3, destinationTangent_V3, nbPoints)
	public static function CreateHermiteSpline(p1:Vector3, t1:Vector3, p2:Vector3, t2:Vector3, nbPoints:Int):Curve3 {
		var hermite:Array<Vector3> = [];
		var step = Std.int(1 / nbPoints);
		for(i in 0...nbPoints+1) {
			hermite.push(Vector3.Hermite(p1, t1, p2, t2, i * step));
		}
		return new Curve3(hermite);
	}
	
}
