package com.babylonhx.math.coherentnoise.generation.displacement;

import com.babylonhx.math.coherentnoise.generation.fractal.PinkNoise;

///<summary>
/// Turbulence is a case of Perturb generator, that uses 3 Perlin noise generators as displacement source.
///</summary>
class Turbulence extends Generator {
	
	private var m_Seed:Int;
	private var m_Source:Generator;
	private var m_DisplacementX:PinkNoise;
	private var m_DisplacementY:PinkNoise;
	private var m_DisplacementZ:PinkNoise;
	private var m_Frequency:Float;
	private var m_OctaveCount:Int;

	///<summary>
	/// Create new perturb generator
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="seed">Seed value for perturbation noise</param>
	public function new(source:Generator, seed:Int) {
		super();
		
		m_Source = source;
		m_Seed = seed;
		Power = 1;
		Frequency = 1;
		OctaveCount = 6;
	}

	///<summary>
	/// Turbulence power, in other words, amount by which source will be perturbed.
	/// 
	/// Default value is 1.
	///</summary>
	public var Power:Float;

	///<summary>
	/// Frequency of perturbation noise. 
	/// 
	/// Default value is 1.
	///</summary>
	public var Frequency(get, set):Float;
	inline private function get_Frequency():Float {
		return m_Frequency; 
	}
	inline private function set_Frequency(value:Float):Float {
		m_Frequency = value;
		CreateDisplacementSource();
		
		return value;
	}

	/// <summary>
	/// Octave count of perturbation noise
	/// 
	/// Default value is 6
	/// </summary>
	public var OctaveCount(get, set):Int;
	inline private function get_OctaveCount():Int { 
		return m_OctaveCount; 
	}
	inline private function	set_OctaveCount(value:Int):Int {
		m_OctaveCount = value;
		CreateDisplacementSource();
		
		return value;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var displacement = new Vector3(
			m_DisplacementX.GetValue(x, y, z),
			m_DisplacementY.GetValue(x, y, z),
			m_DisplacementZ.GetValue(x, y, z)).scale(Power);
			
		return m_Source.GetValue(x + displacement.x, y + displacement.y, z + displacement.z);
	}

	// #endregion

	private function CreateDisplacementSource() {
		m_DisplacementX = new PinkNoise(m_Seed);
		m_DisplacementX.Frequency = Frequency;
		m_DisplacementX.OctaveCount = OctaveCount;
		
		m_DisplacementY = new PinkNoise(m_Seed + 1);
		m_DisplacementY.Frequency = Frequency;
		m_DisplacementY.OctaveCount = OctaveCount;
		
		m_DisplacementZ = new PinkNoise(m_Seed + 2);
		m_DisplacementZ.Frequency = Frequency;
		m_DisplacementZ.OctaveCount = OctaveCount;
	}

}
