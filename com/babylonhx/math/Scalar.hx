package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Scalar {

	/**
	 * Creates a new scalar with values linearly interpolated of "amount" between the start scalar and the end scalar.
	 */
	inline public static function Lerp(start:Float, end:Float, amount:Float):Float {
		return start + ((end - start) * amount);
	}

	/**
	 * Returns a new scalar located for "amount" (float) on the Hermite spline defined by the scalars "value1", "value3", "tangent1", "tangent2".
	 */
	public static function Hermite(value1:Float, tangent1:Float, value2:Float, tangent2:Float, amount:Float):Float {
		var squared = amount * amount;
		var cubed = amount * squared;
		var part1 = ((2.0 * cubed) - (3.0 * squared)) + 1.0;
		var part2 = (-2.0 * cubed) + (3.0 * squared);
		var part3 = (cubed - (2.0 * squared)) + amount;
		var part4 = cubed - squared;
		
		return (((value1 * part1) + (value2 * part2)) + (tangent1 * part3)) + (tangent2 * part4);
	}
	
}
