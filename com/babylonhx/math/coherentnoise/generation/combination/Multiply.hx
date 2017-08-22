package com.babylonhx.math.coherentnoise.generation.combination;

/// <summary>
/// Generator that multiplies two noise values
/// </summary>
class Multiply extends Generator {

	private var m_A:Generator;
	private var m_B:Generator;

	///<summary>
	/// Create new generator
	///</summary>
	///<param name="a">First generator to multiply</param>
	///<param name="b">Second generator to multiply</param>
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
		return m_A.GetValue(x, y, z) * m_B.GetValue(x, y, z);
	}

	// #endregion
	
}
