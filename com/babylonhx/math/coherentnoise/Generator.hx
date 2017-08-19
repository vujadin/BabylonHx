package com.babylonhx.math.coherentnoise;

import textures.procedural.coherentnoise.generation.Function;
import textures.procedural.coherentnoise.generation.displacement.Scale;
import textures.procedural.coherentnoise.generation.displacement.Perturb;
import textures.procedural.coherentnoise.generation.displacement.Rotate;
import textures.procedural.coherentnoise.generation.displacement.Translate;
import textures.procedural.coherentnoise.generation.displacement.Turbulence;
import textures.procedural.coherentnoise.generation.combination.Blend;
import textures.procedural.coherentnoise.generation.modification.Modify;
import textures.procedural.coherentnoise.generation.modification.Curve;
import textures.procedural.coherentnoise.generation.modification.Binarize;
import textures.procedural.coherentnoise.generation.modification.Bias;
import textures.procedural.coherentnoise.generation.modification.Gain;

/// <summary>
/// A noise generator. 
/// </summary>
//abstract Generator(Float) from Float from Float to Float to Float {
class Generator {

	public function new() {	}
	
	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param>
	/// <returns>Noise value</returns>
	public function GetValue(x:Float, y:Float, z:Float):Float {
		throw 'override me';
	}

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="v">Point coordinates</param>
	public function GetValueFromVector3(v:Vector3):Float {
		return GetValue(v.x, v.y, v.z);
	}

	///<summary>
	/// Overloaded + 
	/// Returns new generator that sums these two
	///</summary>
	///<param name="g1"></param>
	///<param name="g2"></param>
	///<returns></returns>
	public static function Add(g1:Generator, g2:Generator):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) + g2.GetValue(x, y, z); });
	}
	///<summary>
	/// Overloaded + 
	/// Returns new generator that adds a constant value
	///</summary>
	///<param name="g1"></param>
	///<param name="f"></param>
	///<returns></returns>
	public static function AddConst(g1:Generator, f:Float):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) + f; });
	}
	///<summary>
	/// Overloaded unary - 
	/// Returns inverse of argument generator
	///</summary>
	///<param name="g1"></param>
	///<returns></returns>
	public static function Negate(g1:Generator):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) + -1; });
	}
	///<summary>
	/// Overloaded - 
	/// Returns new generator that subtracts second argument from first
	///</summary>
	///<param name="g1"></param>
	///<param name="g2"></param>
	///<returns></returns>
	public static function Sub(g1:Generator, g2:Generator):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) - g2.GetValue(x, y, z); });
	}
	///<summary>
	/// Overloaded - 
	/// Returns new generator that subtracts a constant value
	///</summary>
	///<param name="g1"></param>
	///<param name="f"></param>
	///<returns></returns>
	public static function SubConst(g1:Generator, f:Float):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) - f; });
	}
	///<summary>
	/// Overloaded - 
	/// Returns new generator that subtracts generator from a constant value
	///</summary>
	///<param name="g1"></param>
	///<param name="f"></param>
	///<returns></returns>
	public static function SubFromConst(f:Float, g1:Generator):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return f - g1.GetValue(x, y, z); });
	}
	///<summary>
	/// Overloaded *
	/// Returns new generator that multiplies these two
	///</summary>
	///<param name="g1"></param>
	///<param name="g2"></param>
	///<returns></returns>
	public static function Mul(g1:Generator, g2:Generator):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) * g2.GetValue(x, y, z); });
	}
	///<summary>
	/// Overloaded *
	/// Returns new generator that multiplies noise by a constant value
	///</summary>
	///<param name="g1"></param>
	///<param name="f"></param>
	///<returns></returns>
	public static function MulConst(g1:Generator, f:Float):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) * f; });
	}
	///<summary>
	/// Overloaded /
	/// Returns new generator that divides values of argument generators. Beware of zeroes!
	///</summary>
	///<param name="g1"></param>
	///<param name="g2"></param>
	///<returns></returns>
	public static function Div(g1:Generator, g2:Generator):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) / g2.GetValue(x, y, z); });
	}
	///<summary>
	/// Overloaded /
	/// Returns new generator that divides noise by a constant value
	///</summary>
	///<param name="g1"></param>
	///<param name="f"></param>
	///<returns></returns>
	public static function DivConst(g1:Generator, f:Float):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return g1.GetValue(x, y, z) / f; });
	}
	///<summary>
	/// Overloaded /
	/// Returns new generator that divides constant value by noise values
	///</summary>
	///<param name="g1"></param>
	///<param name="f"></param>
	///<returns></returns>
	public static function DivFromConst(f:Float, g1:Generator):Generator {
		return new Function(function(x:Float, y:Float, z:Float):Float { return f / g1.GetValue(x, y, z); });
	}


	// extension methods that apply common noise transformations

	///<summary>
	/// Stretch/squeeze noise generator (<see cref="CoherentNoise.Generation.Displacement.Scale"/>)
	///</summary>
	///<param name="source">Source noise</param>
	///<param name="x">Squeeze in X direction</param>
	///<param name="y">Squeeze in Y direction</param>
	///<param name="z">Squeeze in Z direction</param>
	///<returns></returns>
	public function Scale(x:Float, y:Float, z:Float):Generator {
		return new Scale(this, x, y, z);
	}

	///<summary>
	/// Translate (move) noise <see cref="CoherentNoise.Generation.Displacement.Translate"/>
	///</summary>
	///<param name="source">Source noise</param>
	///<param name="x">Distance in X direction</param>
	///<param name="y">Distance in Y direction</param>
	///<param name="z">Distance in Z direction</param>
	///<returns></returns>
	public function Translate(x:Float, y:Float, z:Float):Generator {
		return new Translate(this, x, y, z);
	}

	///<summary>
	/// Roate noise (<see cref="CoherentNoise.Generation.Displacement.Rotate"/>)
	///</summary>
	///<param name="source">Noise source</param>
	///<param name="x">Angle around X axis</param>
	///<param name="y">Angle around Y axis</param>
	///<param name="z">Angle around Z axis</param>
	///<returns></returns>
	public function Rotate(x:Float, y:Float, z:Float):Generator {
		return new Rotate(this, Quaternion.Euler(new Vector3(x, y, z)));
	}

	///<summary>
	/// Apply turbulence transform to noise (<see cref="CoherentNoise.Generation.Displacement.Turbulence"/>)
	///</summary>
	///<param name="source">Noise source</param>
	///<param name="frequency">Turbulence base frequency</param>
	///<param name="power">Turbulence power</param>
	///<param name="seed">Turbulence seed</param>
	///<returns></returns>
	public function Turbulence(frequency:Float, power:Float, seed:Int):Generator {
		var tb = new Turbulence(this, seed);
		tb.Frequency = frequency;
		tb.Power = power;
		tb.OctaveCount = 6;
		
		return tb;
	}

	///<summary>
	/// Apply turbulence transform to noise (<see cref="CoherentNoise.Generation.Displacement.Turbulence"/>) with random seed
	///</summary>
	///<param name="source">Noise source</param>
	///<param name="frequency">Turbulence base frequency</param>
	///<param name="power">Turbulence power</param>
	///<returns></returns>
	public function Turbulence2(frequency:Float, power:Float):Generator {
		var tb = new Turbulence(this, cast math.Tools.RandomInt(0, 9999999));
		tb.Frequency = frequency;
		tb.Power = power;
		tb.OctaveCount = 6;
		
		return tb;
	}

	///<summary>
	/// Blend two noise generators using third one as weight
	///</summary>
	///<param name="source">Source noise</param>
	///<param name="other">Noise to blend</param>
	///<param name="weight">Blend weight</param>
	///<returns></returns>
	public function Blend(other:Generator, weight:Generator):Generator {
		return new Blend(this, other, weight);
	}

	///<summary>
	/// Apply modification function to noise
	///</summary>
	///<param name="source">Source noise</param>
	///<param name="modifier">Function to apply</param>
	///<returns></returns>
	public function Modify(modifier:Float->Float):Generator {
		return new Modify(this, modifier);
	}

	///<summary>
	/// Multiply noise by AnimationCurve value
	///</summary>
	///<param name="source">Source noise</param>
	///<param name="curve">Curve</param>
	///<returns></returns>
	public function Curve(curve:AnimationCurve):Generator {
		return new Curve(this, curve);
	}

	///<summary>
	/// Binarize noise 
	///</summary>
	///<param name="source">Source noise</param>
	///<param name="treshold">Treshold value</param>
	///<returns></returns>
	public function Binarize(treshold:Float):Generator {
		return new Binarize(this, treshold);
	}

	/// <summary>
	/// Apply bias to noise
	/// </summary>
	/// <param name="source">Source noise</param>
	/// <param name="b">Bias value</param>
	/// <returns></returns>
	public function Bias(b:Float):Generator {
		return new Bias(this, b);
	}

	/// <summary>
	/// Apply gain to noise
	/// </summary>
	/// <param name="source">Source noise</param>
	/// <param name="g">Gain value</param>
	/// <returns></returns>
	public function Gain(g:Float):Generator {
		return new Gain(this, g);
	}

	///<summary>
	/// Apply a linear transform to noise. The same as <code>noise.Modify(f=>a*f+b)</code>
	///</summary>
	///<param name="source">Source noise</param>
	///<param name="a">Scale value</param>
	///<param name="b">Shift value</param>
	///<returns></returns>
	public function ScaleShift(a:Float, b:Float):Generator {
		return new Modify(this, function(f:Float):Float { return a*f + b; });
	}
	
}
