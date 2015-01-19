package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BezierCurve') class BezierCurve {

	inline public static function interpolate(t:Float, x1:Float, y1:Float, x2:Float, y2:Float):Float {
		// Extract X (which is equal to time here)
		var f0 = 1 - 3 * x2 + 3 * x1;
		var f1 = 3 * x2 - 6 * x1;
		var f2 = 3 * x1;
		
		var refinedT = t;
		for (i in 0...5) {
			var refinedT2 = refinedT * refinedT;
			var refinedT3 = refinedT2 * refinedT;
			
			var x = f0 * refinedT3 + f1 * refinedT2 + f2 * refinedT;
			var slope = 1.0 / (3.0 * f0 * refinedT2 + 2.0 * f1 * refinedT + f2);
			refinedT -= (x - t) * slope;
			refinedT = Math.min(1, Math.max(0, refinedT));
		}
		
		// Resolve cubic bezier for the given x
		return 3 * Math.pow(1 - refinedT, 2) * refinedT * y1 +
			   3 * (1 - refinedT) * Math.pow(refinedT, 2) * y2 +
			   Math.pow(refinedT, 3);
			   
	}
	
}
