package com.babylonhx.math.coherentnoise.generation.combination;

/// <summary>
/// This generator blends two noises together, using third as a blend weight. Note that blend weight's value is clamped to [0,1] range
/// </summary>
class Blend extends Generator {
	
	private var m_A:Generator;
	private var m_B:Generator;
	private var m_Weight:Generator;

	///<summary>
	/// Create new blend generator
	///</summary>
	///<param name="a">First generator to blend (this is returned if weight==0)</param>
	///<param name="b">Second generator to blend (this is returned if weight==1)</param>
	///<param name="weight">Blend weight source</param>
	public function new(a:Generator, b:Generator, weight:Generator) {
		super();
		
		m_A = a;
		m_Weight = weight;
		m_B = b;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var w = math.Tools.Clamp(m_Weight.GetValue(x, y, z));
		
		return m_A.GetValue(x, y, z) * (1 - w) + m_B.GetValue(x, y, z) * w;
	}

	// #endregion

}
