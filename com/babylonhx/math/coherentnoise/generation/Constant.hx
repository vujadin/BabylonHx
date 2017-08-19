package com.babylonhx.math.coherentnoise.generation;

///<summary>
/// Constant "noise". This generator returns constant value, ignoring input coordinates. Used for arithmetic operations on noise generators
///</summary>
class Constant extends Generator {

	private var m_Value:Float;

	///<summary>
	/// Create new constant generator
	///</summary>
	///<param name="value">Value returned by generator</param>
	public function new(value:Float) {
		super(value);
		
		m_Value = value;
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
		return m_Value;
	}

	// #endregion
	
}
