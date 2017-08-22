package com.babylonhx.math.coherentnoise.generation.fractal;


///<summary>
/// base class for fractal noise generators. Fractal generators use a source noise, that is sampled at several frequencies. 
/// These sampled values are then combined into a result using some algorithm. 
///</summary>
class FractalNoiseBase extends Generator {

	private static var s_Rotation:Quaternion = Quaternion.Euler(new Vec3(30, 30, 30));

	private var m_Noise:Generator;
	private var m_Frequency:Float;
	private var m_Lacunarity:Float;
	private var m_OctaveCount:Int;

	public function new(param:Dynamic) {
		super();
		
		if (Std.is(param, Int)) {
			m_Noise = new GradientNoise(param);
		}
		else {
			m_Noise = param;
		}
		
		Lacunarity = 2.17;
		OctaveCount = 6;
		Frequency = 1;
	}

	///<summary>
	/// Frequency coefficient. Sampling frequency is multiplied by lacunarity value with each octave.
	/// Default value is 2, so that every octave doubles sampling frequency
	///</summary>
	public var Lacunarity(get, set):Float;
	inline private function get_Lacunarity():Float { 
		return m_Lacunarity; 
	}
	inline private function set_Lacunarity(value:Float):Float {
		m_Lacunarity = value;
		OnParamsChanged();
		
		return value;
	}

	/// <summary>
	/// Number of octaves to sample. Default is 6.
	/// </summary>
	public var OctaveCount(get, set):Int;
	inline private function get_OctaveCount():Int { 
		return m_OctaveCount; 
	}
	inline private function	set_OctaveCount(value:Int):Int {
		m_OctaveCount = value;
		OnParamsChanged();
		
		return value;
	}

	/// <summary>
	/// Initial frequency.
	/// </summary>
	public var Frequency(get, set):Float;
	inline private function get_Frequency():Float { 
		return m_Frequency; 
	}
	inline private function	set_Frequency(value:Float):Float {
		m_Frequency = value;
		OnParamsChanged();
		
		return value;
	}

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var value:Float = 0;
		var signal:Float = 0;
		
		x *= Frequency;
		y *= Frequency;
		z *= Frequency;
		
		for (curOctave in 0...OctaveCount) {
			// Get the coherent-noise value from the input value and add it to the
			// final result.
			signal = m_Noise.GetValue(x, y, z);
			// 
			value = CombineOctave(curOctave, signal, value);
			
			// Prepare the next octave.
			// scale coords to increase frequency, then rotate to break up lattice pattern
			var rotated = s_Rotation.multVector(new Vector3(x, y, z).scaleInPlace(Lacunarity));
			x = rotated.x;
			y = rotated.y;
			z = rotated.z;
		}
		
		return value;
	}

	/// <summary>
	/// Returns new resulting noise value after source noise is sampled. 
	/// </summary>
	/// <param name="curOctave">Octave at which source is sampled (this always starts with 0</param>
	/// <param name="signal">Sampled value</param>
	/// <param name="value">Resulting value from previous step</param>
	/// <returns>Resulting value adjusted for this sample</returns>
	public function CombineOctave(curOctave:Int, signal:Float, value:Float):Float {
		throw('override me');
	}

	/// <summary>
	/// This method is called whenever any generator's parameter is changed (i.e. Lacunarity, Frequency or OctaveCount). 
	/// Override it to precalculate any values used in generation.
	/// </summary>
	public function OnParamsChanged() { }

}
