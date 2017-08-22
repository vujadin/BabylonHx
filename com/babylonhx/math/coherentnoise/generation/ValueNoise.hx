package com.babylonhx.math.coherentnoise.generation;

import com.babylonhx.math.coherentnoise.interpolation.SCurve;

/// <summary>
/// Most basic coherent noise: value noise. This algorithm generates random values in integer coordinates and smoothly interpolates between them.
/// Generated noise has no special characteristics except that it's noisy. 
/// 
/// Values returned range from -1 to 1.
/// </summary>
class ValueNoise extends Generator {

	private var m_Source:LatticeNoise;
	private var m_SCurve:SCurve;

	/// <summary>
	/// Noise period. Used for repeating (seamless) noise.
	/// When Period &gt;0 resulting noise pattern repeats exactly every Period, for all coordinates.
	/// </summary>
	public int Period { get { return m_Source.Period; } set { m_Source.Period = value; } }

	/// <summary>
	/// Create new generator with specified seed and interpolation algorithm. Different interpolation algorithms can make noise smoother at the expense of speed.
	/// </summary>
	/// <param name="seed">noise seed</param>
	/// <param name="sCurve">Interpolator to use. Can be null, in which case default will be used</param>
	public function new(seed:Int, sCurve:SCurve) {
		m_Source = new LatticeNoise(seed);
		m_SCurve = sCurve;
	}

	public var SCurve(get, never):SCurve;
	inline private function get_SCurve():SCcurve { 
		return m_SCurve != null ? m_SCurve : SCurve.Default; 
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
		var iz = Math.floor(z);
		
		// interpolate the coordinates instead of values - it's way faster
		var xs = SCurve.Interpolate(x - ix);
		var ys = SCurve.Interpolate(y - iy);
		var zs = SCurve.Interpolate(z - iz);
		
		// THEN we can use linear interp to find our value - triliear actually
		
		var n0 = m_Source.GetValue(ix, iy, iz);
		var n1 = m_Source.GetValue(ix + 1, iy, iz);
		var ix0 = Tools.Lerp(n0, n1, xs);
		
		n0 = m_Source.GetValue(ix, iy + 1, iz);
		n1 = m_Source.GetValue(ix + 1, iy + 1, iz);
		var ix1 = Tools.Lerp(n0, n1, xs);
		
		var iy0 = Tools.Lerp(ix0, ix1, ys);
		
		n0 = m_Source.GetValue(ix, iy, iz + 1);
		n1 = m_Source.GetValue(ix + 1, iy, iz + 1);
		ix0 = Tools.Lerp(n0, n1, xs); // on y=0, z=1 edge
		
		n0 = m_Source.GetValue(ix, iy + 1, iz + 1);
		n1 = m_Source.GetValue(ix + 1, iy + 1, iz + 1);
		ix1 = Tools.Lerp(n0, n1, xs); // on y=z=1 edge
		
		var iy1 = Tools.Lerp(ix0, ix1, ys);
		
		return Tools.Lerp(iy0, iy1, zs); // inside cube
	}

	// #endregion

}
