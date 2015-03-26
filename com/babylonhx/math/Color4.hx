package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Color4') class Color4 {
	
	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;
	
	
	public function new(r:Float, g:Float, b:Float, a:Float = 1.0) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	// Operators
	public function addInPlace(right:Color4):Color4 {
		this.r += right.r;
		this.g += right.g;
		this.b += right.b;
		this.a += right.a;
		
		return this;
	}

	public function asArray():Array<Float> {
		var result:Array<Float> = [];

		this.toArray(result, 0);

		return result;
	}

	public function toArray(array:Array<Float>, index:Int = 0):Color4 {
		array[index] = this.r;
		array[index + 1] = this.g;
		array[index + 2] = this.b;
		array[index + 3] = this.a;
		
		return this;
	}

	public function add(right:Color4):Color4 {
		return new Color4(this.r + right.r, this.g + right.g, this.b + right.b, this.a + right.a);
	}

	public function subtract(right:Color4):Color4 {
		return new Color4(this.r - right.r, this.g - right.g, this.b - right.b, this.a - right.a);
	}

	public function subtractToRef(right:Color4, result:Color4):Color4 {
		result.r = this.r - right.r;
		result.g = this.g - right.g;
		result.b = this.b - right.b;
		result.a = this.a - right.a;
		
		return this;
	}

	public function scale(scale:Float):Color4 {
		return new Color4(this.r * scale, this.g * scale, this.b * scale, this.a * scale);
	}

	public function scaleToRef(scale:Float, result:Color4):Color4 {
		result.r = this.r * scale;
		result.g = this.g * scale;
		result.b = this.b * scale;
		result.a = this.a * scale;
		
		return this;
	}

	public function toString():String {
		return "{R:" + this.r + " G:" + this.g + " B:" + this.b + " A:" + this.a + "}";
	}

	public function clone():Color4 {
		return new Color4(this.r, this.g, this.b, this.a);
	}
	
	public function copyFrom(source:Color4):Color4 {
		this.r = source.r;
		this.g = source.g;
		this.b = source.b;
		this.a = source.a;
		
		return this;
	}

	// Statics
	public static function Lerp(left:Color4, right:Color4, amount:Float):Color4 {
		var result = new Color4(0, 0, 0, 0);
		
		Color4.LerpToRef(left, right, amount, result);
		
		return result;
	}

	public static function LerpToRef(left:Color4, right:Color4, amount:Float, result:Color4):Color4 {
		result.r = left.r + (right.r - left.r) * amount;
		result.g = left.g + (right.g - left.g) * amount;
		result.b = left.b + (right.b - left.b) * amount;
		result.a = left.a + (right.a - left.a) * amount;
		
		return result;
	}

	public static function FromArray(array:Array<Float>, offset:Int = 0):Color4 {
		return new Color4(array[offset], array[offset + 1], array[offset + 2], array[offset + 3]);
	}

	public static function FromInts(r:Float, g:Float, b:Float, a:Float):Color4 {
		return new Color4(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
	}
}
	