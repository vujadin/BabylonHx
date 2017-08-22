package com.babylonhx.math.coherentnoise.generation;

/// <summary>
/// This generator creates "noise" that is actually a function of coordinates. Use it to create regular patterns that are then perturbed by noise
/// </summary>
class Function extends Generator {

	private var m_Func:Float->Float->Float->Float;

	/// <summary>
	/// Create new function generator
	/// </summary>
	/// <param name="func">Value function</param>
	public function new(func:Float->Float->Float->Float) {
		super();
		
		m_Func = func;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		return m_Func(x, y, z);
	}

	// #endregion
	
}
