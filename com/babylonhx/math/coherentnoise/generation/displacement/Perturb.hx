package com.babylonhx.math.coherentnoise.generation.displacement;


/// <summary>
/// This generator perturbs its source, using a user-supplied function to obtain displacement values. In other words, <see cref="Perturb"/> nonuniformly displaces each value of
/// its source.
/// </summary>
class Perturb extends Generator {
	
	private var m_Source:Generator;
	private var m_DisplacementSource:Vector3->Vector3;

	///<summary>
	/// Create new perturb generator
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="displacementSource">Displacement generator</param>
	public function new(source:Generator, displacementSource:Vector3->Vector3) {
		super();
		
		m_Source = source;
		m_DisplacementSource = displacementSource;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var displacement = m_DisplacementSource(new Vector3(x, y, z));
		
		return m_Source.GetValue(x + displacement.x, y + displacement.y, z + displacement.z);
	}

	// #endregion

}
