package com.babylonhx.math;

import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Color4') class Color4 implements IColor {
	
	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;
	
	
	inline public function new(r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 1.0) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
	
	inline public function getClassName():String {
        return "Color4";
    }

	// Operators
	public function addInPlace(right:Color4):Color4 {
		this.r += right.r;
		this.g += right.g;
		this.b += right.b;
		this.a += right.a;
		
		return this;
	}
	
	public function getHashCode():Int {
        var hash = Std.int(this.r);
        hash = Std.int(hash * 397) ^ Std.int(this.g);
        hash = Std.int(hash * 397) ^ Std.int(this.b);
        hash = Std.int(hash * 397) ^ Std.int(this.a);
		
        return hash;
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
	
	/**
     * Multipy an RGBA Color4 value by another and return a new Color4 object
     * @param color The Color4 (RGBA) value to multiply by
     * @returns A new Color4.
     */
    public function multiply(color:Color4):Color4 {
        return new Color4(this.r * color.r, this.g * color.g, this.b * color.b, this.a * color.a);
    }
	
	/**
     * Multipy an RGBA Color4 value by another and push the result in a reference value
     * @param color The Color4 (RGBA) value to multiply by
     * @param result The Color4 (RGBA) to fill the result in 
     * @returns the result Color4.
     */
    public function multiplyToRef(color:Color4, result:Color4):Color4 {
        result.r = this.r * color.r;
        result.g = this.g * color.g;
        result.b = this.b * color.b;
        result.a = this.a * color.a;
        
        return result;
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

	public function toHexString():String {
		var intR = Std.int(this.r * 255);
		var intG = Std.int(this.g * 255);
		var intB = Std.int(this.b * 255);
		var intA = Std.int(this.a * 255);
		
		return "#" + Scalar.ToHex(intR) + Scalar.ToHex(intG) + Scalar.ToHex(intB) + Scalar.ToHex(intA);
	}
	
	/**
	 * Returns a new Color4 converted to linear space.  
	 */
	public function toLinearSpace():Color4 {
		var convertedColor = new Color4();
		this.toLinearSpaceToRef(convertedColor);
		return convertedColor;
	}

	/**
	 * Converts the Color4 values to linear space and stores the result in "convertedColor".  
	 * Returns the unmodified Color4.  
	 */
	public function toLinearSpaceToRef(convertedColor:Color4):Color4 {
		convertedColor.r = Math.pow(this.r, Color3.ToLinearSpace);
		convertedColor.g = Math.pow(this.g, Color3.ToLinearSpace);
		convertedColor.b = Math.pow(this.b, Color3.ToLinearSpace);
		convertedColor.a = this.a;
		return this;
	}

	/**
	 * Returns a new Color4 converted to gamma space.  
	 */
	public function toGammaSpace():Color4 {
		var convertedColor = new Color4();
		this.toGammaSpaceToRef(convertedColor);
		return convertedColor;
	}

	/**
	 * Converts the Color4 values to gamma space and stores the result in "convertedColor".  
	 * Returns the unmodified Color4.  
	 */
	public function toGammaSpaceToRef(convertedColor:Color4):Color4 {
		convertedColor.r = Math.pow(this.r, Color3.ToGammaSpace);
		convertedColor.g = Math.pow(this.g, Color3.ToGammaSpace);
		convertedColor.b = Math.pow(this.b, Color3.ToGammaSpace);
		convertedColor.a = this.a;
		return this;
	}

	// Statics
	public static function FromHexString(hex:String):Color4 {
		if (hex.substring(0, 1) != "#" || hex.length != 9) {
			trace("Color4.FromHexString must be called with a string like #FFFFFFFF");
			return new Color4(0, 0, 0, 0);
		}
		
		var r = Std.parseInt("0x" + hex.substring(1, 3));
		var g = Std.parseInt("0x" + hex.substring(3, 5));
		var b = Std.parseInt("0x" + hex.substring(5, 7));
		var a = Std.parseInt("0x" + hex.substring(7, 9));
		
		return Color4.FromInts(r, g, b, a);
	}
		
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
		return new Color4(array[offset], array[offset + 1], array[offset + 2], array.length == 4 ? array[offset + 3] : 1.0);
	}

	public static function FromInts(r:Float, g:Float, b:Float, a:Float):Color4 {
		return new Color4(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
	}
	
	public static function FromColor3(color3:Color3, alpha:Float = 1.0):Color4 {
		return new Color4(color3.r, color3.g, color3.b, alpha);
	}
	
	public static function CheckColors4(colors:Array<Float>, count:Int):Array<Float> {
		// Check if color3 was used
		if (colors.length == count * 3) {
			var colors4:Array<Float> = [];
			var index:Int = 0;
			while (index < colors.length) {
				var newIndex = Std.int((index / 3) * 4);
				colors4[newIndex] = colors[index];
				colors4[newIndex + 1] = colors[index + 1];
				colors4[newIndex + 2] = colors[index + 2];
				colors4[newIndex + 3] = 1.0;
				
				index += 3;
			}
			
			return colors4;
		}
		
		return colors;
	}
	
}
	
