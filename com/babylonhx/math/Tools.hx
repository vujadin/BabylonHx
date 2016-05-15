package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.MathTools') class Tools {
	
	static public inline var Epsilon:Float = 0.001;
	static public inline var LOG2E:Float = 1.4426950408889634;
	

	public static function ToHex(i:Int):String {
		var str:String = StringTools.hex(i, 16); 
		
		if (i <= 15) {
			var ret:String = "0" + str;
			return ret.toUpperCase();
		}
		
		return str.toUpperCase();
	}
	
	inline public static function Clamp(value:Float, min:Float = 0, max:Float = 1):Float {
		return Math.min(max, Math.max(min, value));
	}
	
	inline public static function Clamp2(x:Float, a:Float, b:Float):Float {
		return (x < a) ? a : ((x > b) ? b : x);
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

	inline public static function GetExponentOfTwo(value:Int, max:Int):Int {
		var count = 1;
		
		do {
			count *= 2;
		} while (count < value);
		
		if (count > max) {
			count = max;
		}
		
		return count;
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
