package com.babylonhx.math;

import lime.utils.Float32Array;

/**
* ...
* @author Krtolica Vujadin
*/

//Vector4 class created for EulerAngle class conversion to Quaternion
@:expose('BABYLON.Vector4') class Vector4 {
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	

	inline public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0) { 
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public function toString():String {
		return "{X:" + this.x + " Y:" + this.y + " Z:" + this.z + "W:" + this.w + "}";
	}
	
	inline public function getClassName():String {
        return "Vector4";
    }
	
	public function getHashCode():Int {
        var hash = Std.int(this.x);
        hash = Std.int(hash * 397) ^ Std.int(this.y);
		hash = Std.int(hash * 397) ^ Std.int(this.z);
		hash = Std.int(hash * 397) ^ Std.int(this.w);
		
        return hash;
    }

	// Operators
	inline public function asArray():Array<Float> {
		var result:Array<Float> = [];
		this.toArray(result, 0);
		
		return result;
	}
	
	inline public function toArray(array:Array<Float>, index:Int = 0):Vector4 {
		array[index] = this.x;
		array[index + 1] = this.y;
		array[index + 2] = this.z;
		array[index + 3] = this.w;
		
		return this;
	}
	
	inline public function toFloat32Array(array:Float32Array, index:Int = 0):Vector4 {
		array[index] = this.x;
		array[index + 1] = this.y;
		array[index + 2] = this.z;
		array[index + 3] = this.w;
		
		return this;
	}

	inline public function addInPlace(otherVector:Vector4):Vector4 {
		this.x += otherVector.x;
		this.y += otherVector.y;
		this.z += otherVector.z;
		this.w += otherVector.w;
		
		return this;
	}

	inline public function add(otherVector:Vector4):Vector4 {
		return new Vector4(this.x + otherVector.x, this.y + otherVector.y, this.z + otherVector.z, this.w + otherVector.w);
	}

	inline public function addToRef(otherVector:Vector4, result:Vector4):Vector4 {
		result.x = this.x + otherVector.x;
		result.y = this.y + otherVector.y;
		result.z = this.z + otherVector.z;
		result.w = this.w + otherVector.w;
		
		return this;
	}

	inline public function subtractInPlace(otherVector:Vector4):Vector4 {
		this.x -= otherVector.x;
		this.y -= otherVector.y;
		this.z -= otherVector.z;
		this.w -= otherVector.w;
		
		return this;
	}

	inline public function subtract(otherVector:Vector4):Vector4 {
		return new Vector4(this.x - otherVector.x, this.y - otherVector.y, this.z - otherVector.z, this.w - otherVector.w);
	}

	inline public function subtractToRef(otherVector:Vector4, result:Vector4):Vector4 {
		result.x = this.x - otherVector.x;
		result.y = this.y - otherVector.y;
		result.z = this.z - otherVector.z;
		result.w = this.w - otherVector.w;
		
		return this;
	}

	inline public function subtractFromFloats(x:Float, y:Float, z:Float, w:Float):Vector4 {
		return new Vector4(this.x - x, this.y - y, this.z - z, this.w - w);
	}

	inline public function subtractFromFloatsToRef(x:Float, y:Float, z:Float, w:Float, result:Vector4):Vector4 {
		result.x = this.x - x;
		result.y = this.y - y;
		result.z = this.z - z;
		result.w = this.w - w;
		
		return this;
	}

	inline public function negate():Vector4 {
		return new Vector4(-this.x, -this.y, -this.z, -this.w);
	}

	inline public function scaleInPlace(scale:Float):Vector4 {
		this.x *= scale;
		this.y *= scale;
		this.z *= scale;
		this.w *= scale;
		
		return this;
	}

	inline public function scale(scale:Float):Vector4 {
		return new Vector4(this.x * scale, this.y * scale, this.z * scale, this.w * scale);
	}

	inline public function scaleToRef(scale:Float, result:Vector4):Vector4 {
		result.x = this.x * scale;
		result.y = this.y * scale;
		result.z = this.z * scale;
		result.w = this.w * scale;
		
		return this;
	}

	inline public function equals(otherVector:Vector4):Bool {
		return (otherVector != null && this.x == otherVector.x && this.y == otherVector.y && this.z == otherVector.z && this.w == otherVector.w);
	}

	inline public function equalsWithEpsilon(otherVector:Vector4, epsilon:Float = Tools.Epsilon):Bool {
		return otherVector != null  
		&& Scalar.WithinEpsilon(this.x, otherVector.x, epsilon) 
		&& Scalar.WithinEpsilon(this.y, otherVector.y, epsilon) 
		&& Scalar.WithinEpsilon(this.z, otherVector.z, epsilon)
		&& Scalar.WithinEpsilon(this.w, otherVector.w, epsilon);
	}

	inline public function equalsToFloats(x:Float, y:Float, z:Float, w:Float):Bool {
		return this.x == x && this.y == y && this.z == z && this.w == w;
	}

	inline public function multiplyInPlace(otherVector:Vector4):Vector4 {
		this.x *= otherVector.x;
		this.y *= otherVector.y;
		this.z *= otherVector.z;
		this.w *= otherVector.w;
		
		return this;
	}

	inline public function multiply(otherVector:Vector4):Vector4 {
		return new Vector4(this.x * otherVector.x, this.y * otherVector.y, this.z * otherVector.z, this.w * otherVector.w);
	}

	inline public function multiplyToRef(otherVector:Vector4, result:Vector4):Vector4 {
		result.x = this.x * otherVector.x;
		result.y = this.y * otherVector.y;
		result.z = this.z * otherVector.z;
		result.w = this.w * otherVector.w;
		
		return this;
	}

	inline public function multiplyByFloats(x:Float, y:Float, z:Float, w:Float):Vector4 {
		return new Vector4(this.x * x, this.y * y, this.z * z, this.w * w);
	}

	inline public function divide(otherVector:Vector4):Vector4 {
		return new Vector4(this.x / otherVector.x, this.y / otherVector.y, this.z / otherVector.z, this.w / otherVector.w);
	}

	inline public function divideToRef(otherVector:Vector4, result:Vector4):Vector4 {
		result.x = this.x / otherVector.x;
		result.y = this.y / otherVector.y;
		result.z = this.z / otherVector.z;
		result.w = this.w / otherVector.w;
		
		return this;
	}
	
	inline public function dotProduct(a:Vector4):Float {		
		return x * a.x + y * a.y + z * a.z;		
	}

	inline public function MinimizeInPlace(other:Vector4):Vector4 {
		if (other.x < this.x) this.x = other.x;
		if (other.y < this.y) this.y = other.y;
		if (other.z < this.z) this.z = other.z;
		if (other.w < this.w) this.w = other.w;
		
		return this;
	}

	inline public function MaximizeInPlace(other:Vector4):Vector4 {
		if (other.x > this.x) this.x = other.x;
		if (other.y > this.y) this.y = other.y;
		if (other.z > this.z) this.z = other.z;
		if (other.w > this.w) this.w = other.w;
		
		return this;
	}

	// Properties
	inline public function length():Float {
		return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w);
	}

	inline public function lengthSquared():Float {
		return (this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w);
	}

	// Methods
	public function normalize():Vector4 {
		var len = this.length();
		
		if (len == 0) {
			return this;
		}
		
		var num = 1.0 / len;
		
		this.x *= num;
		this.y *= num;
		this.z *= num;
		this.w *= num;
		
		return this;
	}
	
	inline public function toVector3():Vector3 {
		return new Vector3(this.x, this.y, this.z);
	}

	inline public function clone():Vector4 {
		return new Vector4(this.x, this.y, this.z, this.w);
	}

	inline public function copyFrom(source:Vector4):Vector4 {
		this.x = source.x;
		this.y = source.y;
		this.z = source.z;
		this.w = source.w;
		
		return this;
	}

	/**
	 * Updates the current Vector4 coordinates with the passed floats.  
	 * Returns the updated Vector4.  
	 */
	inline public function copyFromFloats(x:Float, y:Float, z:Float, w:Float):Vector4 {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
		
		return this;
	}
	
	/**
	 * Updates the current Vector4 coordinates with the passed floats.  
	 * Returns the updated Vector4.  
	 */
	public function set(x:Float, y:Float, z:Float, w:Float):Vector4 {
		return this.copyFromFloats(x, y, z, w);
	}

	// Statics
	
	/**
	 * Returns a new Vector4 set from the starting index of the passed array.
	 */
	inline public static function FromArray(array:Float32Array, offset:Int = 0):Vector4 {
		return new Vector4(array[offset], array[offset + 1], array[offset + 2], array[offset + 3]);
	}

	/**
	 * Updates the passed vector "result" from the starting index of the passed array.
	 */
	inline public static function FromArrayToRef(array:Float32Array, offset:Int, result:Vector4) {
		result.x = array[offset];
		result.y = array[offset + 1];
		result.z = array[offset + 2];
		result.w = array[offset + 3];
	}

	/**
	 * Updates the passed vector "result" from the starting index of the passed Float32Array.
	 */
	inline public static function FromFloat32ArrayToRef(array:Float32Array, offset:Int, result:Vector4) {
		Vector4.FromArrayToRef(array, offset, result);
	}

	/**
	 * Updates the passed vector "result" coordinates from the passed floats.  
	 */
	inline public static function FromFloatsToRef(x:Float, y:Float, z:Float, w:Float, result:Vector4) {
		result.x = x;
		result.y = y;
		result.z = z;
		result.w = w;
	}

	/**
	 * Returns a new Vector4 set to (0.0, 0.0, 0.0, 0.0)
	 */
	inline public static function Zero():Vector4 {
		return new Vector4(0, 0, 0, 0);
	}
	
	/**
     * Returns a new Vector4 set to (1.0, 1.0, 1.0, 1.0)
     */
    inline public static function One():Vector4 {
        return new Vector4(1.0, 1.0, 1.0, 1.0);
    }

	/**
	 * Returns a new normalized Vector4 from the passed one.  
	 */
	inline public static function Normalize(vector:Vector4):Vector4 {
		var result = Vector4.Zero();
		Vector4.NormalizeToRef(vector, result);
		return result;
	}

	/**
	 * Updates the passed vector "result" from the normalization of the passed one.
	 */
	inline public static function NormalizeToRef(vector:Vector4, result:Vector4) {
		result.copyFrom(vector);
		result.normalize();
	}

	inline public static function Minimize(left:Vector4, right:Vector4):Vector4 {
		var min = left.clone();
		min.MinimizeInPlace(right);
		return min;
	}

	inline public static function Maximize(left:Vector4, right:Vector4):Vector4 {
		var max = left.clone();
		max.MaximizeInPlace(right);
		return max;
	}

	/**
	 * Returns the distance (float) between the vectors "value1" and "value2".  
	 */
	inline public static function Distance(value1:Vector4, value2:Vector4):Float {
		return Math.sqrt(Vector4.DistanceSquared(value1, value2));
	}
	
	/**
	 * Returns the squared distance (float) between the vectors "value1" and "value2".  
	 */
	inline public static function DistanceSquared(value1:Vector4, value2:Vector4):Float {
		var x = value1.x - value2.x;
		var y = value1.y - value2.y;
		var z = value1.z - value2.z;
		var w = value1.w - value2.w;
		
		return (x * x) + (y * y) + (z * z) + (w * w);
	}

	/**
	 * Returns a new Vector4 located at the center between the vectors "value1" and "value2".  
	 */
	inline public static function Center(value1:Vector4, value2:Vector4):Vector4 {
		var center = value1.add(value2);
		center.scaleInPlace(0.5);
		return center;
	}
	
	/**
	 * Returns a new Vector4 set with the result of the normal transformation by the passed matrix of the passed vector.  
	 * This methods computes transformed normalized direction vectors only.  
	 */
	public static function TransformNormal(vector:Vector4, transformation:Matrix):Vector4 {
		var result = Vector4.Zero();
		Vector4.TransformNormalToRef(vector, transformation, result);
		return result;
	}

	/**
	 * Sets the passed vector "result" with the result of the normal transformation by the passed matrix of the passed vector.  
	 * This methods computes transformed normalized direction vectors only. 
	 */
	public static function TransformNormalToRef(vector:Vector4, transformation:Matrix, result:Vector4) {
		var x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4]) + (vector.z * transformation.m[8]);
		var y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5]) + (vector.z * transformation.m[9]);
		var z = (vector.x * transformation.m[2]) + (vector.y * transformation.m[6]) + (vector.z * transformation.m[10]);
		result.x = x;
		result.y = y;
		result.z = z;
		result.w = vector.w;
	}

	/**
	 * Sets the passed vector "result" with the result of the normal transformation by the passed matrix of the passed floats (x, y, z, w).  
	 * This methods computes transformed normalized direction vectors only. 
	 */
	public static function TransformNormalFromFloatsToRef(x:Float, y:Float, z:Float, w:Float, transformation:Matrix, result:Vector4) {
		result.x = (x * transformation.m[0]) + (y * transformation.m[4]) + (z * transformation.m[8]);
		result.y = (x * transformation.m[1]) + (y * transformation.m[5]) + (z * transformation.m[9]);
		result.z = (x * transformation.m[2]) + (y * transformation.m[6]) + (z * transformation.m[10]);
		result.w = w;
	}
	
}
