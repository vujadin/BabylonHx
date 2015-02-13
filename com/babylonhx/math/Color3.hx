package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Color3') class Color3 {
	
	public var r:Float;
	public var g:Float;
	public var b:Float;
	
	
	public function new(r:Float = 0, g:Float = 0, b:Float = 0) {
		this.r = r;
		this.g = g;
		this.b = b;
	}

	public function toString():String {
		return "{R:" + this.r + " G:" + this.g + " B:" + this.b + "}";
	}

	// Operators
	public function toArray(array:Array<Float>, index:Int = 0):Color3 {
		array[index] = this.r;
		array[index + 1] = this.g;
		array[index + 2] = this.b;
		
		return this;
	}

	public function toColor4(alpha:Float = 1):Color4 {
		return new Color4(this.r, this.g, this.b, alpha);
	}

	public function asArray():Array<Float> {
		var result:Array<Float> = [];

		this.toArray(result, 0);

		return result;
	}

	inline public function toLuminance():Float {
		return this.r * 0.3 + this.g * 0.59 + this.b * 0.11;
	}

	inline public function multiply(otherColor:Color3):Color3 {
		return new Color3(this.r * otherColor.r, this.g * otherColor.g, this.b * otherColor.b);
	}

	public function multiplyToRef(otherColor:Color3, result:Color3):Color3 {
		result.r = this.r * otherColor.r;
		result.g = this.g * otherColor.g;
		result.b = this.b * otherColor.b;
		
		return this;
	}

	inline public function equals(otherColor:Color3):Bool {
		return otherColor != null && this.r == otherColor.r && this.g == otherColor.g && this.b == otherColor.b;
	}

	public function scale(scale:Float):Color3 {
		return new Color3(this.r * scale, this.g * scale, this.b * scale);
	}

	inline public function scaleToRef(scale:Float, result:Color3):Color3 {
		result.r = this.r * scale;
		result.g = this.g * scale;
		result.b = this.b * scale;
		
		return this;
	}

	public function add(otherColor:Color3):Color3 {
		return new Color3(this.r + otherColor.r, this.g + otherColor.g, this.b + otherColor.b);
	}

	public function addToRef(otherColor:Color3, result:Color3):Color3 {
		result.r = this.r + otherColor.r;
		result.g = this.g + otherColor.g;
		result.b = this.b + otherColor.b;
		
		return this;
	}

	public function subtract(otherColor:Color3):Color3 {
		return new Color3(this.r - otherColor.r, this.g - otherColor.g, this.b - otherColor.b);
	}

	public function subtractToRef(otherColor:Color3, result:Color3):Color3 {
		result.r = this.r - otherColor.r;
		result.g = this.g - otherColor.g;
		result.b = this.b - otherColor.b;
		
		return this;
	}

	public function clone():Color3 {
		return new Color3(this.r, this.g, this.b);
	}

	inline public function copyFrom(source:Color3):Color3 {
		this.r = source.r;
		this.g = source.g;
		this.b = source.b;
		
		return this;
	}

	inline public function copyFromFloats(r:Float, g:Float, b:Float):Color3 {
		this.r = r;
		this.g = g;
		this.b = b;
		
		return this;
	}

	// Statics
	public static function FromArray(array:Array<Float>, offset:Int = 0):Color3 {
		return new Color3(array[0], array[1], array[2]);
	}

	public static function FromInts(r:Float, g:Float, b:Float):Color3 {
		return new Color3(r / 255.0, g / 255.0, b / 255.0);
	}

	inline public static function Lerp(start:Color3, end:Color3, amount:Float):Color3 {
		var r = start.r + ((end.r - start.r) * amount);
		var g = start.g + ((end.g - start.g) * amount);
		var b = start.b + ((end.b - start.b) * amount);

		return new Color3(r, g, b);
	}

	public static function Red():Color3 { return new Color3(1, 0, 0); }
	public static function Green():Color3 { return new Color3(0, 1, 0); }
	public static function Blue():Color3 { return new Color3(0, 0, 1); }
	public static function Black():Color3 { return new Color3(0, 0, 0); }
	public static function White():Color3 { return new Color3(1, 1, 1); }
	public static function Purple():Color3 { return new Color3(0.5, 0, 0.5); }
	public static function Magenta():Color3 { return new Color3(1, 0, 1); }
	public static function Yellow():Color3 { return new Color3(1, 1, 0); }
	public static function Gray():Color3 { return new Color3(0.5, 0.5, 0.5); }
}
