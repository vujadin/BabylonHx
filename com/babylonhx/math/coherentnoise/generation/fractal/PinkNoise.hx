package com.babylonhx.math.coherentnoise.generation.fractal;

/// <summary>
/// Pink noise is a fractal noise that adds together weighted signals sampled at different frequencies, with weight inversely proportional to frequency. .
/// When source noise is <see cref="GradientNoise"/>, this becomes Perlin noise.
/// </summary>
class PinkNoise extends FractalNoiseBase {

	private var m_CurPersistence:Float;

	///<summary>
	/// Create new pink noise generator using seed. Seed is used to create a <see cref="GradientNoise"/> source. 
	///</summary>
	///<param name="seed">seed value</param>
	public function new(param:Dynamic) {
		super(param);
		Persistence = 0.5;
	}

	///<summary>
	/// Create new pink noise generator with user-supplied source. Usually one would use this with 
	/// <see cref="ValueNoise"/> or gradient noise with less dimensions, but 
	/// some weird effects may be achieved with other generators.
	///</summary>
	///<param name="source">noise source</param>
/*	public static function FromNoiseSource(source:Generator):PinkNoise {
		var pn:PinkNoise = new FractalNoiseBase(source);
		pn.Persistence = 0.5;

		return pn;
	}
*/
	// #region Overrides of FractalNoiseBase

	/// <summary>
	/// Returns new resulting noise value after source noise is sampled. Perlin generator adds signal, 
	/// multiplied by current persistence value. Persistence value
	/// is then decreased, so that higher frequencies will have less impact on resulting value.
	/// </summary>
	/// <param name="curOctave">Octave at which source is sampled (this always starts with 0)</param>
	/// <param name="signal">Sampled value</param>
	/// <param name="value">Resulting value from previous step</param>
	/// <returns>Resulting value adjusted for this sample</returns>
	override public function CombineOctave(curOctave:Int, signal:Float, value:Float):Float {
		if (curOctave == 0) {
			m_CurPersistence = 1;
		}
		value = value + signal * m_CurPersistence;
		m_CurPersistence *= Persistence;
		
		return value;
	}

	// #endregion

	/// <summary>
	/// Persistence value determines how fast signal diminishes with frequency. 
	/// i-th octave signal will be multiplied by presistence to the i-th power.
	/// Note that persistence values >1 are possible, but will not produce interesting noise (lower frequencies will just drown out)
	/// 
	/// Default value is 0.5
	/// </summary>
	public var Persistence:Float;
	
}
