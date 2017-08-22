package com.babylonhx.math.coherentnoise.generation.modification;

/// <summary>
/// This generator takes a source generator and applies a function to its output.
/// </summary>
class Modify extends Generator {
	
	private var m_Modifier:Float->Float;
	private var m_Source:Generator;

	///<summary>
	/// Create new generator
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="modifier">Modifier function to apply</param>
	public function new(source:Generator, modifier:Float->Float) {
		super();
		
		m_Source = source;
		m_Modifier = modifier;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		return m_Modifier(m_Source.GetValue(x, y, z));
	}

	// #endregion

}
