package com.babylonhx.math;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Color3') class Color3 implements IColor {
	
	static public inline var ToGammaSpace:Float = 1 / 2.2;
	static public inline var ToLinearSpace:Float = 2.2;
	
	public var r:Float;
	public var g:Float;
	public var b:Float;
	
	
	inline public function new(r:Float = 0, g:Float = 0, b:Float = 0) {
		this.r = r;
		this.g = g;
		this.b = b;
	}

	public function toString():String {
		return "{R:" + this.r + " G:" + this.g + " B:" + this.b + "}";
	}
	
	public function getClassName():String {
        return "Color3";
    }
	
	public function getHashCode():Int {
        var hash = Std.int(this.r);
        hash = Std.int(hash * 397) ^ Std.int(this.g);
        hash = Std.int(hash * 397) ^ Std.int(this.b);
		
        return hash;
    }
	
	inline public function set(r:Float = 0, g:Float = 0, b:Float = 0) {
		this.r = r;
		this.g = g;
		this.b = b;
	}

	// Operators
	inline public function toArray(array:Array<Float>, index:Int = 0):Color3 {
		array[index] = this.r;
		array[index + 1] = this.g;
		array[index + 2] = this.b;
		
		return this;
	}
	
	inline public function toFloat32Array(array:Float32Array, index:Int = 0):Color3 {
		array[index] = this.r;
		array[index + 1] = this.g;
		array[index + 2] = this.b;
		
		return this;
	}

	inline public function toColor4(alpha:Float = 1):Color4 {
		return new Color4(this.r, this.g, this.b, alpha);
	}

	inline public function asArray():Array<Float> {
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

	inline public function multiplyToRef(otherColor:Color3, result:Color3):Color3 {
		result.r = this.r * otherColor.r;
		result.g = this.g * otherColor.g;
		result.b = this.b * otherColor.b;
		
		return this;
	}

	inline public function equals(otherColor:Color3):Bool {
		return otherColor != null && this.r == otherColor.r && this.g == otherColor.g && this.b == otherColor.b;
	}
	
	inline public function equalsFloats(r:Float, g:Float, b:Float):Bool {
		return this.r == r && this.g == g && this.b == b;
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

	inline public function add(otherColor:Color3):Color3 {
		return new Color3(this.r + otherColor.r, this.g + otherColor.g, this.b + otherColor.b);
	}

	inline public function addToRef(otherColor:Color3, result:Color3):Color3 {
		result.r = this.r + otherColor.r;
		result.g = this.g + otherColor.g;
		result.b = this.b + otherColor.b;
		
		return this;
	}

	inline public function subtract(otherColor:Color3):Color3 {
		return new Color3(this.r - otherColor.r, this.g - otherColor.g, this.b - otherColor.b);
	}

	inline public function subtractToRef(otherColor:Color3, result:Color3):Color3 {
		result.r = this.r - otherColor.r;
		result.g = this.g - otherColor.g;
		result.b = this.b - otherColor.b;
		
		return this;
	}

	inline public function clone():Color3 {
		return new Color3(this.r, this.g, this.b);
	}

	inline public function copyFrom(source:Color3):Color3 {
		this.r = source.r;
		this.g = source.g;
		this.b = source.b;
		
		return this;
	}
	
	inline public function copyFromColor4(source:Color4):Color3 {
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
	
	public function toHexString():String {
		var intR = Std.int(this.r * 255);
		var intG = Std.int(this.g * 255);
		var intB = Std.int(this.b * 255);
		
		return "#" + Scalar.ToHex(intR) + Scalar.ToHex(intG) + Scalar.ToHex(intB);
	}
	
	inline public function toLinearSpace():Color3 {
        var convertedColor:Color3 = new Color3();
        this.toLinearSpaceToRef(convertedColor);
		
        return convertedColor;
    }

    inline public function toLinearSpaceToRef(convertedColor:Color3):Color3 {
        convertedColor.r = Math.pow(this.r, ToLinearSpace);
        convertedColor.g = Math.pow(this.g, ToLinearSpace);
        convertedColor.b = Math.pow(this.b, ToLinearSpace);
		
        return this;
    }

    inline public function toGammaSpace():Color3 {
        var convertedColor = new Color3();
        this.toGammaSpaceToRef(convertedColor);
		
        return convertedColor;
    }

    inline public function toGammaSpaceToRef(convertedColor:Color3):Color3 {
        convertedColor.r = Math.pow(this.r, ToGammaSpace);
        convertedColor.g = Math.pow(this.g, ToGammaSpace);
        convertedColor.b = Math.pow(this.b, ToGammaSpace);
		
        return this;
    }

	// Statics
	public static function FromHexString(hex:String):Color3 {
		if (hex.substring(0, 1) != "#" || hex.length != 7) {
			trace("Color3.FromHexString must be called with a string like #FFFFFF");
			return new Color3(0, 0, 0);
		}
		
		var r = Std.parseInt("0x" + hex.substring(1, 3));
		var g = Std.parseInt("0x" + hex.substring(3, 5));
		var b = Std.parseInt("0x" + hex.substring(5, 7));
		
		return Color3.FromInts(r, g, b);
	}

	inline public static function FromArray(array:Array<Float>, offset:Int = 0):Color3 {
		return new Color3(array[0], array[1], array[2]);
	}
	
	inline public static function FromInt(rgb:Int):Color3 {
		return Color3.FromInts((rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
	}

	inline public static function FromInts(r:Int, g:Int, b:Int):Color3 {
		return new Color3(r / 255.0, g / 255.0, b / 255.0);
	}

	inline public static function Lerp(start:Color3, end:Color3, amount:Float):Color3 {
		var r = start.r + ((end.r - start.r) * amount);
		var g = start.g + ((end.g - start.g) * amount);
		var b = start.b + ((end.b - start.b) * amount);
		
		return new Color3(r, g, b);
	}

	inline public static function Red():Color3 { return new Color3(1, 0, 0); }
	inline public static function Green():Color3 { return new Color3(0, 1, 0); }
	inline public static function Blue():Color3 { return new Color3(0, 0, 1); }
	inline public static function Black():Color3 { return new Color3(0, 0, 0); }
	inline public static function White():Color3 { return new Color3(1, 1, 1); }
	inline public static function Purple():Color3 { return new Color3(0.5, 0, 0.5); }
	inline public static function Magenta():Color3 { return new Color3(1, 0, 1); }
	inline public static function Yellow():Color3 { return new Color3(1, 1, 0); }
	inline public static function Gray():Color3 { return new Color3(0.5, 0.5, 0.5); }
	inline public static function Teal():Color3 { return new Color3(0, 1.0, 1.0); }
	inline public static function Random():Color3 { return new Color3(Math.random(), Math.random(), Math.random()); }
	
}
