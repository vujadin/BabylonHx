package com.babylonhx.math.coherentnoise;


class LatticeNoise {

	private var m_Seed:Int;
	

	public function new(seed:Int) {
		m_Seed = seed;
	}

	/// <summary>
	/// Lattice period. Used for periodic (seamless) generators.
	/// Noise is non-periodic if Period &lt;= 0
	/// </summary>
	public var Period:Int;

	/// <summary>
	/// Noise value at integer coordinates. Used as a source for interpolated coherent noise
	/// </summary>
	/// <param name="x"></param>
	/// <param name="y"></param>
	/// <param name="z"></param>
	/// <returns></returns>
	public function GetValue(x:Int, y:Int, z:Int):Float {
		if (Period > 0) {
			// make periodic lattice. Repeat every Period cells
			x = x % Period; 
			if (x < 0) {
				x += Period;
			}
			y = y % Period; 
			if (y < 0) {
				y += Period;
			}
			z = z % Period; 
			if (z < 0) {
				z += Period;
			}
		}
		
		// All constants are primes and must remain prime in order for this noise
		// function to work correctly.
		// These constant values are lifted directly from libnoise
		var n:Int = Std.int(
			Constants.MultiplierX * x
			+ Constants.MultiplierY * y
			+ Constants.MultiplierZ * z
			+ Constants.MultiplierSeed * m_Seed)
			& 0x7fffffff;
			
		n = (n >> 13) ^ n;
		n = Std.int(n * (n * n * 60493 + 19990303) + 1376312589) & 0x7fffffff;
		
		return 1 - (n / 1073741824f); // normalize for [-1,1]
	}

}
