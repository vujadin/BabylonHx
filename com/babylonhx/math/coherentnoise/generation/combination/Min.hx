package com.babylonhx.math.coherentnoise.generation.combination;

/// <summary>
/// This generator returns minimum value of its two source generators
/// </summary>
class Min extends Generator {
	
	private var m_A:Generator;
	private var m_B:Generator;

	///<summary>
	/// Create new generator
	///</summary>
	///<param name="a">First generator</param>
	///<param name="b">Second generator</param>
	public function new(a:Generator, b:Generator) {
		super(0);
		
		m_A = a;
		m_B = b;
	}

	// #region Implementation of Noise

	/// <summary>
	/// Returns noise value at given point. 
	/// </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param>
	/// <returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		return Math.min(m_A.GetValue(x, y, z), m_B.GetValue(x, y, z));
	}

	// #endregion

}
