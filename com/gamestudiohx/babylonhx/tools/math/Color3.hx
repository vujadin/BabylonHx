package com.gamestudiohx.babylonhx.tools.math;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Color3 {

	public var r:Float;		
	public var g:Float;
	public var b:Float;

	public function new(initialR:Float = 0, initialG:Float = 0, initialB:Float = 0) {
		this.r = initialR;
        this.g = initialG;
        this.b = initialB;
	}

	inline public function equals(otherColor:Color3):Bool {
		return this.r == otherColor.r && this.g == otherColor.g && this.b == otherColor.b;
	}
	
	public function toString():String {
		return "{R: " + this.r + " G:" + this.g + " B:" + this.b + "}";
	}
	
	inline public function clone():Color3 {
		return new Color3(this.r, this.g, this.b);
	}
	
	inline public function asArray():Array<Float> {
        var result = []; 
        this.toArray(result, 0); 
        return result;
    }
 
    inline public function toArray(array:Array<Float>, index:Int = 0) { 
        array[index] = this.r;
        array[index + 1] = this.g;
        array[index + 2] = this.b;
    }
	
	inline public function multiply(otherColor:Color3):Color3 {
		return new Color3(this.r * otherColor.r, this.g * otherColor.g, this.b * otherColor.b);
	}
	
	inline public function multiplyToRef(otherColor:Color3, result:Color3) {
		result.r = this.r * otherColor.r;
        result.g = this.g * otherColor.g;
        result.b = this.b * otherColor.b;
	}
	
	inline public function scale(scale:Float):Color3 {
		return new Color3(this.r * scale, this.g * scale, this.b * scale);
	}
	
	inline public function scaleToRef(scale:Float, result:Color3) {
		result.r = this.r * scale;
        result.g = this.g * scale;
        result.b = this.b * scale;
	}
	
	inline public function copyFrom(source:Color3) {
		this.r = source.r;
        this.g = source.g;
        this.b = source.b;
	}
	
	inline public function copyFromFloats(r:Float, g:Float, b:Float) {
		this.r = r;
        this.g = g;
        this.b = b;
	}
	
	
	inline public static function FromArray(array:Array<Float>):Color3 {
		return new Color3(array[0], array[1], array[2]);
	}
	
}
