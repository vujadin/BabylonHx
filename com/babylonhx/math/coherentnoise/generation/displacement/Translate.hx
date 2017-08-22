package com.babylonhx.math.coherentnoise.generation.displacement;

///<summary>
/// This generator translates its source by given vector.
///</summary>
class Translate extends Generator {
	
	private var m_Source:Generator;
	private var m_X:Float;
	private var m_Y:Float;
	private var m_Z:Float;

	///<summary>
	/// Create new translation
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="x">Translate amount along X axis</param>
	///<param name="y">Translate amount along Y axis</param>
	///<param name="z">Translate amount along Z axis</param>
	public function new(source:Generator, x:Float, y:Float, z:Float) {
		super();
		
		m_Source = source;
		m_Z = z;
		m_Y = y;
		m_X = x;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		return m_Source.GetValue(x + m_X, y + m_Y, z + m_Z);
	}

	// #endregion

}
