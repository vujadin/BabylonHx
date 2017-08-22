package com.babylonhx.math.coherentnoise.generation.patterns;


///<summary>
/// Generates concentric spheres centered in (0,0,0). Resulting "noise" has value -1 in the center, 1 at radius, -1 at 2*radius etc. 
///</summary>
class Spheres extends Function {

	///<summary>
	/// Create new spheres pattern
	///</summary>
	///<param name="radius">radius</param>
	///<exception cref="ArgumentException">When radius &lt;=0 </exception>
	public function new(radius:Float) {
		super(function(x:Float, y:Float, z:Float):Float {
			var d = new Vector3(x, z, y).length();
			return Helpers.Saw(d / radius);
		});
		
		if (radius <= 0) {
			throw "Radius must be > 0";
		}
	}
	
}
