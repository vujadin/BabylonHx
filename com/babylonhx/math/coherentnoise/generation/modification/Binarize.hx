package com.babylonhx.math.coherentnoise.generation.modification;

/// <summary>
/// This generator binarizes its source noise, returning only value 0 and 1. A constant treshold value is user for binarization. I.e. result will be 0 where source value is less than treshold,
/// and 1 elsewhere.
/// </summary>
class Binarize extends Generator {

	private var m_Source:Generator;
	private var m_Treshold:Float;

	///<summary>
	/// Create new binarize generator
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="treshold">Treshold value</param>
	public function new(source:Generator, treshold:Float) {
		super();
		
		m_Source = source;
		m_Treshold = treshold;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		return m_Source.GetValue(x, y, z) > m_Treshold ? 1 : 0;
	}

	// #endregion

}
