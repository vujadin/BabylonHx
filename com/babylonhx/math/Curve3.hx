package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Curve3') class Curve3 {

	private var _points:Array<Vector3>;
	

	public function new(points:Array<Vector3>) {
		this._points = points;
	}

	public function getPoints() {
		return this._points;
	}
	
	public function _continue(curve:Curve3):Curve3 {
		var lastPoint = this._points[this._points.length - 1];
		var continuedPoints = this._points.slice();
		var curvePoints = curve.getPoints();
		for (i in 1...curvePoints.length) {
			continuedPoints.push(curvePoints[i].add(lastPoint));
		}
		return new Curve3(continuedPoints);
	}
	
	// QuadraticBezier(origin_V3, control_V3, destination_V3 )
	public static function CreateQuadraticBezier(v0:Vector3, v1:Vector3, v2:Vector3, nbPoints:Int = 3):Curve3 {
		nbPoints = nbPoints > 2 ? nbPoints : 3;
		var bez:Array<Vector3> = [];
		var step:Float = 1 / nbPoints;
		
		var equation = function(t:Float, val0:Float, val1:Float, val2:Float):Float {
			var res:Float = (1 - t) * (1 - t) * val0 + 2 * t * (1 - t) * val1 + t * t * val2;
			return res;
		};
		
		var i:Float = 0.0;
		while (i <= 1) {
			bez.push(new Vector3(equation(i, v0.x, v1.x, v2.x), equation(i, v0.y, v1.y, v2.y), equation(i, v0.z, v1.z, v2.z)));
			i += step;
		}
		
		return new Curve3(bez);
	}

	// CubicBezier(origin_V3, control1_V3, control2_V3, destination_V3)
	public static function CreateCubicBezier(v0:Vector3, v1:Vector3, v2:Vector3, v3:Vector3, nbPoints:Int = 4):Curve3 {
		nbPoints = nbPoints > 3 ? nbPoints : 4;
		var bez:Array<Vector3> = [];
		var step:Float = 1 / nbPoints;
		
		var equation = function(t:Float, val0:Float, val1:Float, val2:Float, val3:Float):Float {
			var res:Float = (1 - t) * (1 - t) * (1 - t) * val0 + 3 * t * (1 - t) * (1 -t) * val1  + 3 * t * t * (1 - t) * val2 + t * t * t * val3;
			return res;
		};
		
		var i:Float = 0.0;
		while(i <= 1) {
			bez.push(new Vector3(equation(i, v0.x, v1.x, v2.x, v3.x), equation(i, v0.y, v1.y, v2.y, v3.y), equation(i, v0.z, v1.z, v2.z, v3.z)));
			i += step;
		}
		
		return new Curve3(bez);
	}
	
}
