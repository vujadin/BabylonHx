package com.babylonhx.math.coherentnoise.generation.patterns;

///<summary>
/// Generates planes parallel to YZ plane. Resulting "noise" has value -1 on YZ plane, 1 at step distance, -1 at 2*step etc. 
///</summary>
class Planes extends Function {

	///<summary>
	/// Create new planes pattern
	///</summary>
	///<param name="step">step</param>
	///<exception cref="ArgumentException">When step &lt;=0 </exception>
	public function new(step:Float) {
		super(function(x:Float, y:Float, z:Float):Float {
			return Helpers.Saw(x / step));
		});
		
		if (step <= 0) {
			throw "Step must be > 0";
		}
	}

}
