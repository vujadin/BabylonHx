package com.babylonhx.math;

import lime.utils.Float32Array;
import lime.utils.Int32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BabylonMinMax') typedef BabylonMinMax = {
	minimum: Vector3,
	maximum: Vector3
}
 
@:expose('BABYLON.MathTools') class Tools {
	
	static public inline var ToLinearSpace:Float = 2.2;
	static public inline var Epsilon:Float = 0.001;
	static public inline var LOG2E:Float = 1.4426950408889634;
	static public var TWOPI:Float = Math.PI * 2;
	
	public static function ExtractMinAndMaxIndexed(positions:Float32Array, indices:Int32Array, indexStart:Int, indexCount:Int, bias:Vector2 = null):BabylonMinMax {
		var minimum = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var maximum = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		
		for (index in indexStart...indexStart + indexCount) {
			var current = new Vector3(positions[indices[index] * 3], positions[indices[index] * 3 + 1], positions[indices[index] * 3 + 2]);
			minimum = Vector3.Minimize(current, minimum);
			maximum = Vector3.Maximize(current, maximum);
		}
		
		if (bias != null) {
			minimum.x -= minimum.x * bias.x + bias.y;
			minimum.y -= minimum.y * bias.x + bias.y;
			minimum.z -= minimum.z * bias.x + bias.y;
			maximum.x += maximum.x * bias.x + bias.y;
			maximum.y += maximum.y * bias.x + bias.y;
			maximum.z += maximum.z * bias.x + bias.y;
		}
		
		return {
			minimum: minimum,
			maximum: maximum
		};
	}

	public static function ExtractMinAndMax(positions:Float32Array, start:Int, count:Int, bias:Vector2 = null, stride:Int = 3):BabylonMinMax {
		var minimum = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		var maximum = new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		
		var current:Vector3 = Vector3.Zero();
		for (index in start...start + count) {
			current = new Vector3(positions[index * stride], positions[index * stride + 1], positions[index * stride + 2]);
			
			minimum = Vector3.Minimize(current, minimum);
			maximum = Vector3.Maximize(current, maximum);
		}
		
		if (bias != null) {
			minimum.x -= minimum.x * bias.x + bias.y;
			minimum.y -= minimum.y * bias.x + bias.y;
			minimum.z -= minimum.z * bias.x + bias.y;
			maximum.x += maximum.x * bias.x + bias.y;
			maximum.y += maximum.y * bias.x + bias.y;
			maximum.z += maximum.z * bias.x + bias.y;
		}
		
		return {
			minimum: minimum,
			maximum: maximum
		};
	}
	

	public static function ToHex(i:Int):String {
		var str:String = StringTools.hex(i, 16); 
		
		if (i <= 15) {
			var ret:String = "0" + str;
			return ret.toUpperCase();
		}
		
		return str.toUpperCase();
	}
	
	/**
     * Returns the log2 of value.
     */
    inline public static function Log2(value:Float):Float {
        return Math.log(value) * LOG2E;
    }
	
	/**
	 * Loops the value, so that it is never larger than length and never smaller than 0.
	 * 
	 * This is similar to the modulo operator but it works with floating point numbers. 
	 * For example, using 3.0 for t and 2.5 for length, the result would be 0.5. 
	 * With t = 5 and length = 2.5, the result would be 0.0. 
	 * Note, however, that the behaviour is not defined for negative numbers as it is for the modulo operator
	 */
	inline public static function Repeat(value:Float, length:Float):Float {
		return value - Math.floor(value / length) * length;
	}
	
	/**
	 * Normalize the value between 0.0 and 1.0 using min and max values
	 */
	inline public static function Normalize(value:Float, min:Float, max:Float):Float {
		return (value - min) / (max - min);
	}

	/**
	 * Denormalize the value from 0.0 and 1.0 using min and max values
	 */
	public static function Denormalize(normalized:Float, min:Float, max:Float):Float {
		return (normalized * (max - min) + min);
	}
	
	inline public static function Clamp(value:Float, min:Float = 0, max:Float = 1):Float {
		return Math.min(max, Math.max(min, value));
	}
	
	inline public static function Clamp2(x:Float, a:Float, b:Float):Float {
		return (x < a) ? a : ((x > b) ? b : x);
	}
	
	/**
		Uses Math.round to fix a floating point number to a set precision.
	**/
	inline public static function Round(number:Float, precision:Int = 2):Float {
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}
	
	// Returns -1 when value is a negative number and
	// +1 when value is a positive number. 
	inline public static function Sign(value:Dynamic):Int {
		if (value == 0) {
			return 0;
		}
			
		return value > 0 ? 1 : -1;
	}
	
	inline public static function IsExponentOfTwo(value:Int):Bool {
		var count = 1;
		
		do {
			count *= 2;
		} while (count < value);
		
		return count == value;
	}
	
	/**
	 * Interpolates between a and b via alpha
	 * @param a The lower value (returned when alpha = 0)
	 * @param b The upper value (returned when alpha = 1)
	 * @param alpha The interpolation-factor
	 * @return The mixed value
	 */
	inline public static function Mix(a:Float, b:Float, alpha:Float):Float {
		return a * (1 - alpha) + b * alpha;
	}
	
	/**
	 * Find the next highest power of two.
	 * @param x Number to start search from.
	 * @return Next highest power of two.
	 */
	public static function CeilingPOT(x:Int):Int {
		x--;
		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;
		x++;
		return x;
	}

	/**
	 * Find the next lowest power of two.
	 * @param x Number to start search from.
	 * @return Next lowest power of two.
	 */
	public static function FloorPOT(x:Int):Int {
		x = x | (x >> 1);
		x = x | (x >> 2);
		x = x | (x >> 4);
		x = x | (x >> 8);
		x = x | (x >> 16);
		return x - (x >> 1);
	}

	/**
	 * Find the nearest power of two.
	 * @param x Number to start search from.
	 * @return Next nearest power of two.
	 */
	public static function NearestPOT(x:Int):Int {
		var c = Tools.CeilingPOT(x);
		var f = Tools.FloorPOT(x);
		return (c - x) > (x - f) ? f : c;
	} 

	public static function GetExponentOfTwo(value:Int, max:Int, mode:Int = Engine.SCALEMODE_NEAREST):Int {
		var pot:Int = 0;
		
		switch (mode) {
			case Engine.SCALEMODE_FLOOR:
				pot = Tools.FloorPOT(value);
			
			case Engine.SCALEMODE_NEAREST:
				pot = Tools.NearestPOT(value);
			
			case Engine.SCALEMODE_CEILING:
				pot = Tools.CeilingPOT(value);
			
		}
		
		return Std.int(Math.min(pot, max));
	}
	
	inline public static function Lerp(v0:Float, v1:Float, t:Float):Float {
		return (1 - t) * v0 + t * v1;
	}
	
	inline public static function ToDegrees(angle:Float):Float {
		return angle * 180 / Math.PI;
	}

	inline public static function ToRadians(angle:Float):Float {
		return angle * Math.PI / 180;
	}
	
	inline public static function CheckExtends(v:Vector3, min:Vector3, max:Vector3) {
		if (v.x < min.x)
			min.x = v.x;
		if (v.y < min.y)
			min.y = v.y;
		if (v.z < min.z)
			min.z = v.z;
			
		if (v.x > max.x)
			max.x = v.x;
		if (v.y > max.y)
			max.y = v.y;
		if (v.z > max.z)
			max.z = v.z;
	}

	inline public static function WithinEpsilon(a:Float, b:Float, epsilon:Float = 1.401298E-45):Bool {
		var num = a - b;
		return -epsilon <= num && num <= epsilon;
	}
	
	inline public static function randomInt(from:Int, to:Int):Int {
		return from + Math.floor(((to - from + 1) * Math.random()));
	}
	
	inline public static function randomFloat(from:Float, to:Float):Float {
		return from + ((to - from + 1) * Math.random());
	}
	
}
