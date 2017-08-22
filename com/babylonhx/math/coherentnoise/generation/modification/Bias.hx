package com.babylonhx.math.coherentnoise.generation.modification;

/// <summary>
/// Bias generator is used to "shift" mean value of source noise. Source is assumed to have values between -1 and 1; after Bias is applied,
/// the result is still between -1 and 1, but the points that were equal to 0 are shifted by <i>bias value</i>.
/// </summary>
class Bias extends Generator {

	private var m_Bias:Float;
	private var m_Source:Generator;

	///<summary>
	/// Create new generator
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="bias">Bias value</param>
	public function new(source:Generator, bias:Float) {
		super();
		
		if (m_Bias <= -1 || m_Bias >= 1) {
			throw "Bias must be between -1 and 1";
		}
		
		m_Source = source;
		m_Bias = bias / (1 + bias);
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
		// clamp f to [-1,1] so that we don't ever get a division by 0 error
		if (f < -1) {
			f = -1;
		}
		if (f > 1) {
			f = 1;
		}
		
		return (f + 1.0) / (1.0 - m_Bias * (1.0 - f) * 0.5) - 1.0;
	}

	// #endregion

}
