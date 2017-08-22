package com.babylonhx.math.coherentnoise.generation.fractal;

/// <summary>
/// This generator adds samples with weight decreasing with frequency, like Perlin noise; however, each signal is taken as absolute value, and weighted by previous (i.e. lower-frequency) signal,
/// creating a sort of feedback loop. Resulting noise has sharp ridges, somewhat resembling cliffs. This is useful for terrain generation.
/// </summary>
class RidgeNoise extends FractalNoiseBase {

	private var m_Exponent:Float;
	private var m_SpectralWeights:Array<Float>;
	private var m_Weight:Float;

	///<summary>
	/// Create new ridge generator using seed (seed is used to create a <see cref="GradientNoise"/> source)
	///</summary>
	///<param name="seed">seed value</param>
	public function new(seed:Int) {
		super(seed);
		Offset = 1;
		Gain = 2;
		Exponent = 1;
	}

	///<summary>
	/// Create new ridge generator with user-supplied source. Usually one would use this with <see cref="ValueNoise"/> or gradient noise with less dimensions, but 
	/// some weird effects may be achieved with other generators.
	///</summary>
	///<param name="source">noise source</param>
	public static function FromNoiseSource(source:Generator):RidgeNoise {
		var rn:RidgeNoise = cast FractalNoiseBase.FromNoiseSource(source);
		rn.Offset = 1;
		rn.Gain = 2;
		rn.Exponent = 1;
		
		return rn;
	}

	/// <summary>
	/// Exponent defines how fast weights decrease with frequency. The higher the exponent, the less weight is given to high frequencies. 
	/// Default value is 1
	/// </summary>
	public var Exponent(get, set):Float;
	inline private function get_Exponent():Float { 
		return m_Exponent; 
	}
	inline private function	set_Exponent(value:Float):Float {
		m_Exponent = value;
		OnParamsChanged();
		
		return value;
	}

	/// <summary>
	/// Offset is applied to signal at every step. Default value is 1
	/// </summary>
	public var Offset:Float;

	/// <summary>
	/// Gain is the weight factor for previous-step signal. Higher gain means more feedback and noisier ridges. 
	/// Default value is 2.
	/// </summary>
	public var Gain:Float;

	// #region Overrides of FractalNoiseBase

	/// <summary>
	/// Returns new resulting noise value after source noise is sampled. 
	/// </summary>
	/// <param name="curOctave">Octave at which source is sampled (this always starts with 0</param>
	/// <param name="signal">Sampled value</param>
	/// <param name="value">Resulting value from previous step</param>
	/// <returns>Resulting value adjusted for this sample</returns>
	override public function CombineOctave(curOctave:Int, signal:Float, value:Float):Float {
		if (curOctave == 0) {
			m_Weight = 1;
		}
		// Make the ridges.
		signal = Offset - Math.Abs(signal);
		
		// Square the signal to increase the sharpness of the ridges.
		signal *= signal;
		
		// The weighting from the previous octave is applied to the signal.
		// Larger values have higher weights, producing sharp points along the
		// ridges.
		signal *= m_Weight;
		
		// Weight successive contributions by the previous signal.
		m_Weight = signal * Gain;
		if (m_Weight > 1) {
			m_Weight = 1;
		}
		if (m_Weight < 0) {
			m_Weight = 0;
		}
		
		// Add the signal to the output value.
		return value + (signal * m_SpectralWeights[curOctave]);
	}

	/// <summary>
	/// This method is called whenever any generator's parameter is changed (i.e. Lacunarity, Frequency or OctaveCount). Override it to precalculate any values used in generation.
	/// </summary>
	override public function OnParamsChanged() {
		PrecalculateWeights();
	}

	// #endregion

	private function PrecalculateWeights() {
		var frequency:Float = 1;
		m_SpectralWeights = [];
		for (ii in 0...OctaveCount) {
			// Compute weight for each frequency.
			m_SpectralWeights[ii] = Math.Pow(frequency, -Exponent);
			frequency *= Lacunarity;
		}
	}

}
