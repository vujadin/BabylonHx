package com.babylonhx.math.coherentnoise.generation;

/// <summary>
/// This generator returns its source unchanged. However, it caches last returned value, and does not recalculate it if called several times for the same point.
/// This is handy if you use same noise generator in different places.
/// 
/// Note that displacement, fractal and Voronoi generators call GetValue at different points for their respective source generators.  
/// This wil trash the Cache and negate any performance benefit, so there's no point in using Cache with these generators.
/// </summary>
class Cache extends Generator {

	private var m_X:Float;
	private var m_Y:Float;
	private var m_Z:Float;
	private var m_Cached:Float;
	private var m_Source:Generator;

	///<summary>
	///Create new caching generator
	///</summary>
	///<param name="source">Source generator</param>
	public function new(source:Generator) {
		m_Source = source;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		if (x == m_X && y == m_Y && z == m_Z) {
			return m_Cached;
		}
		else {
			m_X = x;
			m_Y = y;
			m_Z = z;
			
			return m_Cached = m_Source.GetValue(x, y, z);
		}
	}

	// #endregion
	
}
