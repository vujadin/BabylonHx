package com.babylonhx.math.coherentnoise.generation.patterns;

class Helpers {

	/// <summary>
	/// Saw function that is equal to 1 in odd points and -1 at even points
	/// </summary>
	/// <param name="x"></param>
	/// <returns></returns>
	inline public static function Saw(x:Float):Float {
		var i = Math.floor(x);
		
		return (i % 2 == 0) ? 2 * (x - i) - 1 : 2 * (1 - (x - i)) - 1;
	}

}
