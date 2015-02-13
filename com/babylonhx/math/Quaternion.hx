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
	
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public function toString():String {
		return "{X:" + this.x + " Y:" + this.y + " Z:" + this.z + " W:" + this.w + "}";
	}

	inline public function asArray():Array<Float> {
		return [this.x, this.y, this.z, this.w];
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
	
	inline public function toEulerAngles():Vector3 {
		var result = Vector3.Zero();
		this.toEulerAnglesToRef(result);
		return result;
	}
	
	inline public function toEulerAnglesToRef(result:Vector3) {
		//result is an EulerAngles in the in the z-x-z convention
		var qx = this.x;
		var qy = this.y;
		var qz = this.z;
		var qw = this.w;
		var qxy = qx * qy;
		var qxz = qx * qz;
		var qwy = qw * qy;
		var qwz = qw * qz;
		var qwx = qw * qx;
		var qyz = qy * qz;
		var sqx = qx * qx;
		var sqy = qy * qy;
		
		var determinant = sqx + sqy;
		
		if (determinant != 0.000 && determinant != 1.000) {
			result.x = Math.atan2(qxz + qwy, qwx - qyz);
			result.y = Math.acos(1 - 2 * determinant);
			result.z = Math.atan2(qxz - qwy, qwx + qyz);
		} else {
			if (determinant == 0.000) {
				result.x = 0.0;
				result.y = 0.0;
				result.z = Math.atan2(qxy - qwz, 0.5 - sqy - qz * qz); //actually, degeneracy gives us choice with x+z=Math.atan2(qxy-qwz,0.5-sqy-qz*qz)
			} else //determinant == 1.000
			{
				result.x = Math.atan2(qxy - qwz, 0.5 - sqy - qz * qz); //actually, degeneracy gives us choice with x-z=Math.atan2(qxy-qwz,0.5-sqy-qz*qz)
				result.y = Math.PI;
				result.z = 0.0;
			}
		}
	}

	inline public function toRotationMatrix(result:Matrix) {
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

	public function fromRotationMatrix(matrix:Matrix) {
		Quaternion.FromRotationMatrixToRef(matrix, this);
		return this;
	}

	// Statics
	inline public static function FromRotationMatrix(matrix:Matrix):Quaternion {
		var result = new Quaternion();
		Quaternion.FromRotationMatrixToRef(matrix, result);
		return result;
	}
	
	inline public static function FromRotationMatrixToRef(matrix:Matrix, result:Quaternion) {
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
			
		} else if (m11 > m22 && m11 > m33) {
			
			s = 2.0 * Math.sqrt(1.0 + m11 - m22 - m33);
			
			result.w = (m32 - m23) / s;
			result.x = 0.25 * s;
			result.y = (m12 + m21) / s;
			result.z = (m13 + m31) / s;
			
		} else if (m22 > m33) {
			
			s = 2.0 * Math.sqrt(1.0 + m22 - m11 - m33);
			
			result.w = (m13 - m31) / s;
			result.x = (m12 + m21) / s;
			result.y = 0.25 * s;
			result.z = (m23 + m32) / s;
			
		} else {
			
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

	inline public static function RotationAxis(axis:Vector3, angle:Float):Quaternion {
		var result = new Quaternion();
		var sin = Math.sin(angle / 2);
		
		result.w = Math.cos(angle / 2);
		result.x = axis.x * sin;
		result.y = axis.y * sin;
		result.z = axis.z * sin;
		
		return result;
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

	inline public static function Slerp(left:Quaternion, right:Quaternion, amount:Float):Quaternion {
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
