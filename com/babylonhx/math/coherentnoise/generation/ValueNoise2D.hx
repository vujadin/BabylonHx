package com.babylonhx.math.coherentnoise.generation;

import com.babylonhx.math.coherentnoise.interpolation.SCurve;

/// <summary>
/// This is the same noise as <see cref="ValueNoise"/>, but it does not change in Z direction. This is more efficient if you're only interested in 2D noise anyway.
/// </summary>
class ValueNoise2D extends Generator {

	private var m_Source:LatticeNoise;
	private var m_SCurve:SCurve;

	/// <summary>
	/// Create new generator with specified seed and interpolation algorithm. Different interpolation algorithms can make noise smoother at the expense of speed.
	/// </summary>
	/// <param name="seed">noise seed</param>
	/// <param name="sCurve">Interpolator to use. Can be null, in which case default will be used</param>
	public function new(seed:Int, ?sCurve:SCurve) {
		m_Source = new LatticeNoise(seed);
		m_SCurve = sCurve;
	}

	public var SCurve(get, never):SCurve;
	inline private function get_SCurve():SCurve { 
		return m_SCurve != null ? m_SCurve : SCurve.Default;
	}

	/// <summary>
	/// Noise period. Used for repeating (seamless) noise.
	/// When Period &gt;0 resulting noise pattern repeats exactly every Period, for all coordinates.
	/// </summary>
	public var Period(get, set):Int;
	inline private function get_Period():Int { 
		return m_Source.Period; 
	} 
	inline private function set_Period(value:Int):Int { 
		m_Source.Period = value; 
	}

	// #region Implementation of Noise

	/// <summary>
	/// Returns noise value at given point. 
	/// </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param>
	/// <returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var ix = Math.floor(x);
		var iy = Math.floor(y);
		
		// interpolate the coordinates instead of values - it's way faster
		var xs = SCurve.Interpolate(x - ix);
		var ys = SCurve.Interpolate(y - iy);
		
		// THEN we can use linear interp to find our value - biliear actually
		
		var n0 = m_Source.GetValue(ix, iy, 0);
		var n1 = m_Source.GetValue(ix + 1, iy, 0);
		var ix0 = Tools.Lerp(n0, n1, xs);
		
		n0 = m_Source.GetValue(ix, iy + 1, 0);
		n1 = m_Source.GetValue(ix + 1, iy + 1, 0);
		var ix1 = Tools.Lerp(n0, n1, xs);
		
		return Tools.Lerp(ix0, ix1, ys);
	}

	// #endregion
	
}
