package com.gamestudiohx.babylonhx.tools.math;
import openfl.utils.Float32Array;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Vector3 {
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	
	public function new(initialX:Float, initialY:Float, initialZ:Float) {
		this.x = initialX;
		this.y = initialY;
		this.z = initialZ;
	}

	public function toString():String {
		return "{X:" + this.x + " Y:" + this.y + " Z:" + this.z + "}";
	}
	
	inline public function asArray():Array<Float> {
        var result = [];
        this.toArray(result, 0);
        return result;
    }
	
	inline public function toArray(array:Array<Float>, index:Int = 0):Array<Float> {
		array[index] = this.x;
        array[index + 1] = this.y;
        array[index + 2] = this.z;
		return array;
	}

	inline public function addInPlace(otherVector:Vector3) {
		this.x += otherVector.x;
		this.y += otherVector.y;
		this.z += otherVector.z;
	}
	
	inline public function add(otherVector:Vector3):Vector3 {
		return new Vector3(this.x + otherVector.x, this.y + otherVector.y, this.z + otherVector.z);
	}
	
	inline public function addToRef(otherVector:Vector3, result:Vector3):Vector3 {
		result.x = this.x + otherVector.x;
        result.y = this.y + otherVector.y;
        result.z = this.z + otherVector.z;
		return result;
	}
	
	inline public function subtractInPlace(otherVector:Vector3) {
		this.x -= otherVector.x;
		this.y -= otherVector.y;
		this.z -= otherVector.z;
	}
	
	inline public function subtract(otherVector:Vector3):Vector3 {
		return new Vector3(this.x - otherVector.x, this.y - otherVector.y, this.z - otherVector.z);
	}
	
	inline public function subtractToRef(otherVector:Vector3, result:Vector3) {
		result.x = this.x - otherVector.x;
        result.y = this.y - otherVector.y;
        result.z = this.z - otherVector.z;
	}
	
	inline public function subtractFromFloats(x:Float, y:Float, z:Float):Vector3 {
		return new Vector3(this.x - x, this.y - y, this.z - z);
	}
	
	inline public function subtractFromFloatsToRef(x:Float, y:Float, z:Float, result:Vector3) {
		result.x = this.x - x;
        result.y = this.y - y;
        result.z = this.z - z;
	}
	
	inline public function negate():Vector3 {
		return new Vector3( -this.x, -this.y, -this.z);
	}
	
	inline public function scaleInPlace(scale:Float) {
		this.x *= scale;
        this.y *= scale;
        this.z *= scale;
	}
	
	inline public function scale(scale:Float):Vector3 {
		return new Vector3(this.x * scale, this.y * scale, this.z * scale);
	}
	
	inline public function scaleToRef(scale:Float, result:Vector3) {
		result.x = this.x * scale;
        result.y = this.y * scale;
        result.z = this.z * scale;
	}
	
	inline public function equals(otherVector:Vector3):Bool {
		return this.x == otherVector.x && this.y == otherVector.y && this.z == otherVector.z;
	}
	
	inline public function equalsToFloats(x:Float, y:Float, z:Float):Bool {
		return this.x == x && this.y == y && this.z == z;
	}
	
	inline public function multiplyInPlace(otherVector:Vector3) {
		this.x *= otherVector.x;
        this.y *= otherVector.y;
        this.z *= otherVector.z;
	}
	
	inline public function multiply(otherVector:Vector3):Vector3 {
		return new Vector3(this.x * otherVector.x, this.y * otherVector.y, this.z * otherVector.z);
	}
	
	inline public function multiplyToRef(otherVector:Vector3, result:Vector3) {
		result.x = this.x * otherVector.x;
        result.y = this.y * otherVector.y;
        result.z = this.z * otherVector.z;
	}
	
	inline public function multiplyByFloats(x:Float, y:Float, z:Float):Vector3 {
		return new Vector3(this.x * x, this.y * y, this.z * z);
	}
	
	inline public function divide(otherVector:Vector3):Vector3 {
		return new Vector3(this.x / otherVector.x, this.y / otherVector.y, this.z / otherVector.z);
	}
	
	inline public function divideToRef(otherVector:Vector3, result:Vector3) {
		result.x = this.x / otherVector.x;
        result.y = this.y / otherVector.y;
        result.z = this.z / otherVector.z;
	}
	
	inline public function length():Float {
		return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
	}
	
	inline public function lengthSquared():Float {
		return (this.x * this.x + this.y * this.y + this.z * this.z);
	}
	
	inline public function normalize() {
		var len = this.length();

        if (len != 0) {
			var num = 1.0 / len;

			this.x *= num;
			this.y *= num;
			this.z *= num;
		}
	}
	
	inline public function clone():Vector3 {
		return new Vector3(this.x, this.y, this.z);
	}
	
	inline public function copyFrom(source:Vector3) {
		this.x = source.x;
        this.y = source.y;
        this.z = source.z;
	}
	
	inline public function copyFromFloats(x:Float, y:Float, z:Float) {
		this.x = x;
        this.y = y;
        this.z = z;
	}
	

	inline public static function FromArray(array:Array<Float>, offset:Int = 0) {
        return new Vector3(array[offset], array[offset + 1], array[offset + 2]);
	}
	
	inline public static function FromArrayToRef(array: #if html5 Float32Array #else Array<Float> #end , offset:Int = 0, result:Vector3) {
		result.x = array[offset];
        result.y = array[offset + 1];
        result.z = array[offset + 2];
	}
	
	inline public static function FromFloatsToRef(x:Float, y:Float, z:Float, result:Vector3) {
		result.x = x;
        result.y = y;
        result.z = z;
	}
	
	public static function Zero():Vector3 {
		return new Vector3(0.0, 0.0, 0.0);
	}
	
	public static function Up():Vector3 {
		return new Vector3(0, 1.0, 0);
	}
	
	inline public static function TransformCoordinates(vector:Vector3, transformation:Matrix):Vector3 {
		var result = Vector3.Zero();

        Vector3.TransformCoordinatesToRef(vector, transformation, result);

        return result;
	}
	
	inline public static function TransformCoordinatesToRef(vector:Vector3, transformation:Matrix, result:Vector3) {
		var x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4]) + (vector.z * transformation.m[8]) + transformation.m[12];
        var y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5]) + (vector.z * transformation.m[9]) + transformation.m[13];
        var z = (vector.x * transformation.m[2]) + (vector.y * transformation.m[6]) + (vector.z * transformation.m[10]) + transformation.m[14];
        var w = (vector.x * transformation.m[3]) + (vector.y * transformation.m[7]) + (vector.z * transformation.m[11]) + transformation.m[15];

        result.x = x / w;
        result.y = y / w;
        result.z = z / w;
	}
	
	inline public static function TransformCoordinatesFromFloatsToRef(x:Float, y:Float, z:Float, transformation:Matrix, result:Vector3):Vector3 {
		var rx = (x * transformation.m[0]) + (y * transformation.m[4]) + (z * transformation.m[8]) + transformation.m[12];
        var ry = (x * transformation.m[1]) + (y * transformation.m[5]) + (z * transformation.m[9]) + transformation.m[13];
        var rz = (x * transformation.m[2]) + (y * transformation.m[6]) + (z * transformation.m[10]) + transformation.m[14];
        var rw = (x * transformation.m[3]) + (y * transformation.m[7]) + (z * transformation.m[11]) + transformation.m[15];

        result.x = rx / rw;
        result.y = ry / rw;
        result.z = rz / rw;
		
		return result;
	}
	
	inline public static function TransformNormal(vector:Vector3, transformation:Matrix):Vector3 {
		var result = Vector3.Zero();

        Vector3.TransformNormalToRef(vector, transformation, result);

        return result;
	}
	
	inline public static function TransformNormalToRef(vector:Vector3, transformation:Matrix, result:Vector3) {
		result.x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4]) + (vector.z * transformation.m[8]);
        result.y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5]) + (vector.z * transformation.m[9]);
        result.z = (vector.x * transformation.m[2]) + (vector.y * transformation.m[6]) + (vector.z * transformation.m[10]);
	}
	
	inline public static function TransformNormalFromFloatsToRef(x:Float, y:Float, z:Float, transformation:Matrix, result:Vector3) {
		result.x = (x * transformation.m[0]) + (y * transformation.m[4]) + (z * transformation.m[8]);
        result.y = (x * transformation.m[1]) + (y * transformation.m[5]) + (z * transformation.m[9]);
        result.z = (x * transformation.m[2]) + (y * transformation.m[6]) + (z * transformation.m[10]);
	}
	

	inline public static function CatmullRom(value1:Vector3, value2:Vector3, value3:Vector3, value4:Vector3, amount:Float):Vector3 {
		var squared = amount * amount;
        var cubed = amount * squared;

        var x = 0.5 * ((((2.0 * value2.x) + ((-value1.x + value3.x) * amount)) +
                (((((2.0 * value1.x) - (5.0 * value2.x)) + (4.0 * value3.x)) - value4.x) * squared)) +
            ((((-value1.x + (3.0 * value2.x)) - (3.0 * value3.x)) + value4.x) * cubed));

        var y = 0.5 * ((((2.0 * value2.y) + ((-value1.y + value3.y) * amount)) +
                (((((2.0 * value1.y) - (5.0 * value2.y)) + (4.0 * value3.y)) - value4.y) * squared)) +
            ((((-value1.y + (3.0 * value2.y)) - (3.0 * value3.y)) + value4.y) * cubed));

        var z = 0.5 * ((((2.0 * value2.z) + ((-value1.z + value3.z) * amount)) +
                (((((2.0 * value1.z) - (5.0 * value2.z)) + (4.0 * value3.z)) - value4.z) * squared)) +
            ((((-value1.z + (3.0 * value2.z)) - (3.0 * value3.z)) + value4.z) * cubed));

        return new Vector3(x, y, z);
	}
	
	inline public static function Clamp(value:Vector3, min:Vector3, max:Vector3):Vector3 {
		var x = value.x;
        x = (x > max.x) ? max.x : x;
        x = (x < min.x) ? min.x : x;

        var y = value.y;
        y = (y > max.y) ? max.y : y;
        y = (y < min.y) ? min.y : y;

        var z = value.z;
        z = (z > max.z) ? max.z : z;
        z = (z < min.z) ? min.z : z;

        return new Vector3(x, y, z);
	}
	
	inline public static function Hermite(value1:Vector3, tangent1:Vector3, value2:Vector3, tangent2:Vector3, amount:Float):Vector3 {
		var squared = amount * amount;
        var cubed = amount * squared;
        var part1 = ((2.0 * cubed) - (3.0 * squared)) + 1.0;
        var part2 = (-2.0 * cubed) + (3.0 * squared);
        var part3 = (cubed - (2.0 * squared)) + amount;
        var part4 = cubed - squared;

        var x = (((value1.x * part1) + (value2.x * part2)) + (tangent1.x * part3)) + (tangent2.x * part4);
        var y = (((value1.y * part1) + (value2.y * part2)) + (tangent1.y * part3)) + (tangent2.y * part4);
        var z = (((value1.z * part1) + (value2.z * part2)) + (tangent1.z * part3)) + (tangent2.z * part4);

        return new Vector3(x, y, z);
	}
	
	inline public static function Lerp(start:Vector3, end:Vector3, amount:Float):Vector3 {
		var x = start.x + ((end.x - start.x) * amount);
        var y = start.y + ((end.y - start.y) * amount);
        var z = start.z + ((end.z - start.z) * amount);

        return new Vector3(x, y, z);
	}
	
	inline public static function Dot(left:Vector3, right:Vector3):Float {
		return (left.x * right.x + left.y * right.y + left.z * right.z);
	}
	
	inline public static function Cross(left:Vector3, right:Vector3):Vector3 {
		var result = Vector3.Zero();
        Vector3.CrossToRef(left, right, result);
        return result;
	}
	
	inline public static function CrossToRef(left:Vector3, right:Vector3, result:Vector3) {
		result.x = left.y * right.z - left.z * right.y;
        result.y = left.z * right.x - left.x * right.z;
        result.z = left.x * right.y - left.y * right.x;
	}
	
	inline public static function Normalize(vector:Vector3):Vector3 {
		var result = Vector3.Zero();
        Vector3.NormalizeToRef(vector, result);
        return result;
	}
	
	inline public static function NormalizeToRef(vector:Vector3, result:Vector3) {
		result.copyFrom(vector);
        result.normalize();
	}
	
	inline public static function Project(vector:Vector3, world:Matrix, transform:Matrix, viewport:Viewport):Vector3 {
		var cw = viewport.width;
        var ch = viewport.height;
        var cx = viewport.x;
        var cy = viewport.y;

        var viewportMatrix = Matrix.FromValues(
										cw / 2.0, 0, 0, 0,
									    0, -ch / 2.0, 0, 0,
										0, 0, 1, 0,
										cx + cw / 2.0, ch / 2.0 + cy, 0, 1);
        
        var finalMatrix = world.multiply(transform).multiply(viewportMatrix);

        return Vector3.TransformCoordinates(vector, finalMatrix);
	}
	
	inline public static function Unproject(source:Vector3, viewportWidth:Float, viewportHeight:Float, world:Matrix, view:Matrix, projection:Matrix):Vector3 {
		var matrix = world.multiply(view).multiply(projection);
        matrix.invert();
        source.x = source.x / viewportWidth * 2 - 1;
        source.y = -(source.y / viewportHeight * 2 - 1);
        var vector = Vector3.TransformCoordinates(source, matrix);
        var num = source.x * matrix.m[3] + source.y * matrix.m[7] + source.z * matrix.m[11] + matrix.m[15];

        if (Tools.WithinEpsilon(num, 1.0)) {
            vector = vector.scale(1.0 / num);
        }

        return vector;
	}	

	inline public static function Minimize(left:Vector3, right:Vector3):Vector3 {
		var x = (left.x < right.x) ? left.x : right.x;
        var y = (left.y < right.y) ? left.y : right.y;
        var z = (left.z < right.z) ? left.z : right.z;
        return new Vector3(x, y, z);
	}
	
	inline public static function Maximize(left:Vector3, right:Vector3):Vector3 {
		var x = (left.x > right.x) ? left.x : right.x;
        var y = (left.y > right.y) ? left.y : right.y;
        var z = (left.z > right.z) ? left.z : right.z;
        return new Vector3(x, y, z);
	}
	
	inline public static function Distance(value1:Vector3, value2:Vector3):Float {
		return Math.sqrt(Vector3.DistanceSquared(value1, value2));
	}
	
	inline public static function DistanceSquared(value1:Vector3, value2:Vector3):Float {
		var x = value1.x - value2.x;
        var y = value1.y - value2.y;
        var z = value1.z - value2.z;

        return (x * x) + (y * y) + (z * z);
	}
		
}
