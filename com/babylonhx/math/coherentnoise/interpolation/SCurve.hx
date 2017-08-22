package com.babylonhx.math.coherentnoise.interpolation;

/// <summary>
/// Base class for all S-curves. S-curves determine the interpolation algorithm. Using different curves, quality-speed balance may be tweaked,
/// as better algorithms tend to be slower.
/// </summary>
class SCurve {

	/// <summary>
	/// Maps a value between 0 and 1 to some S-shaped curve.
	/// Interpolated value equals to 0 when <paramref name="t"/>==0 and to 1 when <paramref name="t"/>==1
	/// Values outside of [0,1] range are illegal
	/// 
	/// Good interpolation also has derivatives of result equal to 0 when <paramref name="t"/> is 0 or 1 (the higher order derivatives are zeroed, the better).
	/// </summary>
	/// <param name="t">Interpolation value (0 to 1)</param>
	/// <returns>Mapped value</returns>

	///<summary>
	/// Linear interpolator is the fastest and has the lowest quality, only ensuring continuity of noise values, not their derivatives.
	///</summary>
	static inline public function LinearInterpolate(t:Float):Float {
		return t;
	}

	///<summary>
	/// Cubic interpolation is a good compromise between speed and quality. It's slower than linear, but ensures continuity of 1-st order derivatives, making noise smooth.
	///</summary>
	static inline public function CubicInterpolate(t:Float):Float {
		return t * t * (3 - 2 * t);
	}

	///<summary>
	/// Quintic interpolation is the most smooth, guaranteeing continuinty of second-order derivatives. it is slow, however.
	///</summary>
	static inline public function QuinticInterpolate(t:Float):Float {
		var t3 = t * t * t;
		var t4 = t3 * t;
		var t5 = t4 * t;
		
		return 6 * t5 - 15 * t4 + 10 * t3;
	}

	///<summary>
	/// Cosine interpolation uses cosine function instead of power curve, resulting in somewhat smoother noise than cubic interpolation, but still only achieving first-order continuity.
	/// Depending on target machine, it may be faster than quintic interpolation.
	///</summary>
	inline static public function CosineInterpolate(t:Float):Float {
		return ((1 - Math.cos(t * 3.1415927)) * .5);
	}

	///<summary>
	/// Default interpolator. Noise generators will use this one if you don't supply concrete interlpolator in the constructor. 
	///</summary>
	static public var DefaultInterpolate:Float->Float = CubicInterpolate;

}
