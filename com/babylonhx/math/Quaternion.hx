package com.babylonhx.math;

/**
* ...
* @author Krtolica Vujadin
*/
@:expose('BABYLON.Quaternion') class Quaternion {
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	
	
	inline public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public function toString():String {
		return "{X:" + this.x + " Y:" + this.y + " Z:" + this.z + " W:" + this.w + "}";
	}
	
	public function getClassName():String {
        return "Quaternion";
    }

    public function getHashCode():Float {
        var hash = Std.int(this.x);
        hash = Std.int(hash * 397) ^ Std.int(this.y);
        hash = Std.int(hash * 397) ^ Std.int(this.z);
        hash = Std.int(hash * 397) ^ Std.int(this.w);
		
        return hash;
    }

	inline public function asArray():Array<Float> {
		return [this.x, this.y, this.z, this.w];
	}
	
	inline public function set(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	inline public function equals(otherQuaternion:Quaternion):Bool {
		return otherQuaternion != null && this.x == otherQuaternion.x && this.y == otherQuaternion.y && this.z == otherQuaternion.z && this.w == otherQuaternion.w;
	}

	inline public function clone():Quaternion {
		return new Quaternion(this.x, this.y, this.z, this.w);
	}

	inline public function copyFrom(other:Quaternion):Quaternion {
		this.x = other.x;
		this.y = other.y;
		this.z = other.z;
		this.w = other.w;
		
		return this;
	}

	inline public function copyFromFloats(x:Float, y:Float, z:Float, w:Float):Quaternion {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
		
		return this;
	}

	inline public function add(other:Quaternion):Quaternion {
		return new Quaternion(this.x + other.x, this.y + other.y, this.z + other.z, this.w + other.w);
	}

	inline public function subtract(other:Quaternion):Quaternion {
		return new Quaternion(this.x - other.x, this.y - other.y, this.z - other.z, this.w - other.w);
	}

	inline public function scale(value:Float):Quaternion {
		return new Quaternion(this.x * value, this.y * value, this.z * value, this.w * value);
	}
	
	inline public function multiply(q1:Quaternion):Quaternion {
		var result = new Quaternion(0, 0, 0, 1.0);
		this.multiplyToRef(q1, result);
		
		return result;
	}

	inline public function multiplyToRef(q1:Quaternion, result:Quaternion) {
		result.x = this.x * q1.w + this.y * q1.z - this.z * q1.y + this.w * q1.x;
		result.y = -this.x * q1.z + this.y * q1.w + this.z * q1.x + this.w * q1.y;
		result.z = this.x * q1.y - this.y * q1.x + this.z * q1.w + this.w * q1.z;
		result.w = -this.x * q1.x - this.y * q1.y - this.z * q1.z + this.w * q1.w;
	}
	
	inline public function multiplyInPlace(q1:Quaternion):Quaternion {
        this.multiplyToRef(q1, this);
		
        return this;
    }

	inline public function length():Float {
		return Math.sqrt((this.x * this.x) + (this.y * this.y) + (this.z * this.z) + (this.w * this.w));
	}

	inline public function normalize():Quaternion {
		var length = 1.0 / this.length();
		this.x *= length;
		this.y *= length;
		this.z *= length;
		this.w *= length;
		
		return this;
	}
	
	inline public function toEulerAngles(order:String = "YZX"):Vector3 {
		var result = Vector3.Zero();
		this.toEulerAnglesToRef(result, order);
		
		return result;
	}
	
	public function toEulerAnglesToRef(result:Vector3, order:String = "YZX") {
		var heading:Float = Math.NEGATIVE_INFINITY;
		var attitude:Float = 0;
		var bank:Float = 0;
		var x = this.x;
		var y = this.y;
		var z = this.z;
		var w = this.w;
		
		switch (order) {
			case "YZX":
				var test = x * y + z * w;
				if (test > 0.499) { // singularity at north pole
					heading = 2 * Math.atan2(x, w);
					attitude = Math.PI / 2;
					bank = 0;
				}
				if (test < -0.499) { // singularity at south pole
					heading = -2 * Math.atan2(x, w);
					attitude = -Math.PI / 2;
					bank = 0;
				}
				if (heading == Math.NEGATIVE_INFINITY) {
					var sqx = x * x;
					var sqy = y * y;
					var sqz = z * z;
					heading = Math.atan2(2 * y * w - 2 * x * z, 1 - 2 * sqy - 2 * sqz); // Heading
					attitude = Math.asin(2 * test); // attitude
					bank = Math.atan2(2 * x * w - 2 * y * z, 1 - 2 * sqx - 2 * sqz); // bank
				}
				
			default:
				throw ("Euler order " + order + " not supported yet.");
		}
		
		result.y = heading;
		result.z = attitude;
		result.x = bank;
		
		return this;
	}

	public function toRotationMatrix(result:Matrix) {
		var xx = this.x * this.x;
		var yy = this.y * this.y;
		var zz = this.z * this.z;
		var xy = this.x * this.y;
		var zw = this.z * this.w;
		var zx = this.z * this.x;
		var yw = this.y * this.w;
		var yz = this.y * this.z;
		var xw = this.x * this.w;
		
		result.m[0] = 1.0 - (2.0 * (yy + zz));
		result.m[1] = 2.0 * (xy + zw);
		result.m[2] = 2.0 * (zx - yw);
		result.m[3] = 0;
		result.m[4] = 2.0 * (xy - zw);
		result.m[5] = 1.0 - (2.0 * (zz + xx));
		result.m[6] = 2.0 * (yz + xw);
		result.m[7] = 0;
		result.m[8] = 2.0 * (zx + yw);
		result.m[9] = 2.0 * (yz - xw);
		result.m[10] = 1.0 - (2.0 * (yy + xx));
		result.m[11] = 0;
		result.m[12] = 0;
		result.m[13] = 0;
		result.m[14] = 0;
		result.m[15] = 1.0;
	}
	
	public function multVector(vec:Vector3):Vector3 {		  
		var num = this.x * 2;
		var num2 = this.y * 2;
		var num3 = this.z * 2;
		var num4 = this.x * num;
		var num5 = this.y * num2;
		var num6 = this.z * num3;
		var num7 = this.x * num2;
		var num8 = this.x * num3;
		var num9 = this.y * num3;
		var num10 = this.w * num;
		var num11 = this.w * num2;
		var num12 = this.w * num3;
		
		var result:Vector3 = new Vector3();
		result.x = (1 - (num5 + num6)) * vec.x + (num7 - num12) * vec.y + (num8 + num11) * vec.z;
		result.y = (num7 + num12) * vec.x + (1 - (num4 + num6)) * vec.y + (num9 - num10) * vec.z;
		result.z = (num8 - num11) * vec.x + (num9 + num10) * vec.y + (1 - (num4 + num5)) * vec.z;
		
		return result;
	}

	inline public function fromRotationMatrix(matrix:Matrix) {
		Quaternion.FromRotationMatrixToRef(matrix, this);
		
		return this;
	}

	// Statics
	inline public static function FromRotationMatrix(matrix:Matrix):Quaternion {
		var result = new Quaternion();
		Quaternion.FromRotationMatrixToRef(matrix, result);
		
		return result;
	}
	
	public static function FromRotationMatrixToRef(matrix:Matrix, result:Quaternion) {
		var data = matrix.m;
		var m11 = data[0];
		var m12 = data[4];
		var m13 = data[8];
		var m21 = data[1];
		var m22 = data[5];
		var m23 = data[9];
		var m31 = data[2];
		var m32 = data[6];
		var m33 = data[10];
		var _trace = m11 + m22 + m33;
		var s:Float = 0;
		
		if (_trace > 0) {			
			s = 0.5 / Math.sqrt(_trace + 1.0);
			
			result.w = 0.25 / s;
			result.x = (m32 - m23) * s;
			result.y = (m13 - m31) * s;
			result.z = (m21 - m12) * s;
			
		} 
		else if (m11 > m22 && m11 > m33) {			
			s = 2.0 * Math.sqrt(1.0 + m11 - m22 - m33);
			
			result.w = (m32 - m23) / s;
			result.x = 0.25 * s;
			result.y = (m12 + m21) / s;
			result.z = (m13 + m31) / s;
			
		} 
		else if (m22 > m33) {			
			s = 2.0 * Math.sqrt(1.0 + m22 - m11 - m33);
			
			result.w = (m13 - m31) / s;
			result.x = (m12 + m21) / s;
			result.y = 0.25 * s;
			result.z = (m23 + m32) / s;
			
		} 
		else {			
			s = 2.0 * Math.sqrt(1.0 + m33 - m11 - m22);
			
			result.w = (m21 - m12) / s;
			result.x = (m13 + m31) / s;
			result.y = (m23 + m32) / s;
			result.z = 0.25 * s;
		}
	}
	
	inline public static function Inverse(q:Quaternion):Quaternion {
		return new Quaternion(-q.x, -q.y, -q.z, q.w);
	}
	
	inline public static function Identity():Quaternion {
		return new Quaternion(0, 0, 0, 1);
	}

	inline public static function RotationAxis(axis:Vector3, angle:Float):Quaternion {
		var result = new Quaternion();
		var sin = Math.sin(angle / 2);
		
		axis.normalize();
		
		result.w = Math.cos(angle / 2);
		result.x = axis.x * sin;
		result.y = axis.y * sin;
		result.z = axis.z * sin;
		
		return result;
	}
	
	public static function LookRotation(forward:Vector3, ?up:Vector3) {
		if (up == null) {
			up  = Vector3.Up();
		}
		
		forward.normalize();
		
		var vector:Vector3 = Vector3.Normalize(forward);
		var vector2:Vector3 = Vector3.Normalize(Vector3.Cross(up, vector));
		var vector3:Vector3 = Vector3.Cross(vector, vector2);
		var m00 = vector2.x;
		var m01 = vector2.y;
		var m02 = vector2.z;
		var m10 = vector3.x;
		var m11 = vector3.y;
		var m12 = vector3.z;
		var m20 = vector.x;
		var m21 = vector.y;
		var m22 = vector.z;
		
		var num8:Float = (m00 + m11) + m22;
		var quaternion:Quaternion = new Quaternion();
		if (num8 > 0) {
			var num = Math.sqrt(num8 + 1);
			quaternion.w = num * 0.5;
			num = 0.5 / num;
			quaternion.x = (m12 - m21) * num;
			quaternion.y = (m20 - m02) * num;
			quaternion.z = (m01 - m10) * num;
			
			return quaternion;
		}
		
		if ((m00 >= m11) && (m00 >= m22)) {
			var num7 = Math.sqrt(((1 + m00) - m11) - m22);
			var num4 = 0.5 / num7;
			quaternion.x = 0.5 * num7;
			quaternion.y = (m01 + m10) * num4;
			quaternion.z = (m02 + m20) * num4;
			quaternion.w = (m12 - m21) * num4;
			
			return quaternion;
		}
		
		if (m11 > m22) {
			var num6 = Math.sqrt(((1 + m11) - m00) - m22);
			var num3 = 0.5 / num6;
			quaternion.x = (m10+ m01) * num3;
			quaternion.y = 0.5 * num6;
			quaternion.z = (m21 + m12) * num3;
			quaternion.w = (m20 - m02) * num3;
			
			return quaternion; 
		}
		
		var num5 = Math.sqrt(((1 + m22) - m00) - m11);
		var num2 = 0.5 / num5;
		quaternion.x = (m20 + m02) * num2;
		quaternion.y = (m21 + m12) * num2;
		quaternion.z = 0.5 * num5;
		quaternion.w = (m01 - m10) * num2;
		
		return quaternion;
	}

	inline public static function FromArray(array:Array<Float>, offset:Int = 0):Quaternion {
		return new Quaternion(array[offset], array[offset + 1], array[offset + 2], array[offset + 3]);
	}

	inline public static function RotationYawPitchRoll(yaw:Float, pitch:Float, roll:Float):Quaternion {
		var result = new Quaternion();
		Quaternion.RotationYawPitchRollToRef(yaw, pitch, roll, result);
		return result;
	}

	inline public static function RotationYawPitchRollToRef(yaw:Float, pitch:Float, roll:Float, result:Quaternion) {
		var halfRoll = roll * 0.5;
		var halfPitch = pitch * 0.5;
		var halfYaw = yaw * 0.5;
		
		var sinRoll = Math.sin(halfRoll);
		var cosRoll = Math.cos(halfRoll);
		var sinPitch = Math.sin(halfPitch);
		var cosPitch = Math.cos(halfPitch);
		var sinYaw = Math.sin(halfYaw);
		var cosYaw = Math.cos(halfYaw);
		
		result.x = (cosYaw * sinPitch * cosRoll) + (sinYaw * cosPitch * sinRoll);
		result.y = (sinYaw * cosPitch * cosRoll) - (cosYaw * sinPitch * sinRoll);
		result.z = (cosYaw * cosPitch * sinRoll) - (sinYaw * sinPitch * cosRoll);
		result.w = (cosYaw * cosPitch * cosRoll) + (sinYaw * sinPitch * sinRoll);
	}

	public static function Slerp(left:Quaternion, right:Quaternion, amount:Float):Quaternion {
		var num2 = 0.0;
		var num3 = 0.0;
		var num = amount;
		var num4 = (((left.x * right.x) + (left.y * right.y)) + (left.z * right.z)) + (left.w * right.w);
		var flag = false;
		
		if (num4 < 0) {
			flag = true;
			num4 = -num4;
		}
		
		if (num4 > 0.999999) {
			num3 = 1 - num;
			num2 = flag ? -num : num;
		}
		else {
			var num5 = Math.acos(num4);
			var num6 = (1.0 / Math.sin(num5));
			num3 = (Math.sin((1.0 - num) * num5)) * num6;
			num2 = flag ? ((-Math.sin(num * num5)) * num6) : ((Math.sin(num * num5)) * num6);
		}
		
		return new Quaternion((num3 * left.x) + (num2 * right.x), (num3 * left.y) + (num2 * right.y), (num3 * left.z) + (num2 * right.z), (num3 * left.w) + (num2 * right.w));
	}
	
}
