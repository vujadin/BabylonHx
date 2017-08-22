package com.babylonhx.math.coherentnoise.generation.modification;

/// <summary>
/// This generator is used to "sharpen" noise, shifting extreme values closer to -1 and 1, while leaving 0 in place. Source noise is
/// clamped to [-1,1], as values outside of this range may result in division by 0. Resulting noise is between -1 and 1, with values that
/// were equal to 0.5 shifted to 0.5+gain/2, and those that were equal to -0.5 shifted to -0.5-gain/2.
/// </summary>
class Gain extends Generator {

	private var m_Gain:Float;
	private var m_Source:Generator;

	///<summary>
	/// Create new generator
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="gain">Gain value</param>
	public function new(source:Generator, gain:Float) {
		super();
		
		if (m_Gain <= -1 || m_Gain >= 1) {
			throw "Gain must be between -1 and 1";
		}
		
		m_Source = source;
		m_Gain = gain;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var f = m_Source.GetValue(x, y, z);
		if (f >= 0) {
			return BiasFunc(f);
		}
		else {
			return -BiasFunc(-f);
		}
	}

	// #endregion

	inline private function BiasFunc(f:Float):Float {
		// clamp f to [0,1] so that we don't ever get a division by 0 error
		if (f < 0) {
			f = 0;
		}
		if (f > 1) {
			f = 1;
		}
		
		// Bias curve that makes a "half" of gain
		return f * (1.0 + m_Gain) / (1.0 + m_Gain - (1.0 - f) * 2.0 * m_Gain);
	}

}
