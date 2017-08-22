package com.babylonhx.math.coherentnoise.generation.modification;

///<summary>
/// This generator modifies source noise by applying a curve transorm to it. Curves can be edited using Unity editor's CurveFields, or created procedurally.
///</summary>
class Curve extends Generator {

	private var m_Source:Generator;
	private var m_Curve:AnimationCurve;

	///<summary>
	/// Create a new curve generator
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="curve">Curve to use</param>
	public function new(source:Generator, curve:AnimationCurve) {
		super();
		
		m_Source = source;
		m_Curve = curve;
	}

	// #region Overrides of NoiseGen

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var v = m_Source.GetValue(x, y, z);
		
		return m_Curve.Evaluate(v);
	}

	// #endregion

}
