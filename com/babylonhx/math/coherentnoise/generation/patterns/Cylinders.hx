package com.babylonhx.math.coherentnoise.generation.patterns;


///<summary>
/// Generates concentric cylinders centered in (0,0,0) and parallel to Z axis. Resulting "noise" has value -1 in the center, 1 at radius, -1 at 2*radius etc. 
///</summary>
class Cylinders extends Function {

	///<summary>
	/// Create new cylinders pattern
	///</summary>
	///<param name="radius">radius</param>
	///<exception cref="ArgumentException">When radius &lt;=0 </exception>
	public function new(radius:Float) {
		if (radius <= 0) {
			throw "Radius must be > 0";
		}
		
		super(function(x:Float, y:Float, z:Float):Float {
			var d = new Vector2(x, y).length();
			
			return Helpers.Saw(d / radius);
		});
	}
	
}
