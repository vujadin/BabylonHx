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

	inline public function multiplyToRef(q1:Quaternion, result:Quaternion):Quaternion {
		var x = this.x * q1.w + this.y * q1.z - this.z * q1.y + this.w * q1.x;
		var y = -this.x * q1.z + this.y * q1.w + this.z * q1.x + this.w * q1.y;
		var z = this.x * q1.y - this.y * q1.x + this.z * q1.w + this.w * q1.z;
		var w = -this.x * q1.x - this.y * q1.y - this.z * q1.z + this.w * q1.w;
		result.copyFromFloats(x, y, z, w);
		
		return this;
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
	
	public function toEulerAnglesToRef(result:Vector3, order:String = "YZX"):Quaternion {
		var qz = this.z;
		var qx = this.x;
		var qy = this.y;
		var qw = this.w;
		
		var sqw = qw * qw;
		var sqz = qz * qz;
		var sqx = qx * qx;
		var sqy = qy * qy;
		
		var zAxisY = qy * qz - qx * qw;
		var limit = .4999999;
		
		if (zAxisY < -limit) {
			result.y = 2 * Math.atan2(qy, qw);
			result.x = Math.PI / 2;
			result.z = 0;
		}
		else if (zAxisY > limit) {
			result.y = 2 * Math.atan2(qy, qw);
			result.x = -Math.PI / 2;
			result.z = 0;
		}
		else {
			result.z = Math.atan2(2.0 * (qx * qy + qz * qw), ( -sqz - sqx + sqy + sqw));
			result.x = Math.asin( -2.0 * (qz * qy - qx * qw));
			result.y = Math.atan2(2.0 * (qz * qx + qy * qw), (sqz - sqx - sqy + sqw));
		}
		
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
	
	/**
	 * Returns a new Quaternion set to (0.0, 0.0, 0.0).  
	 */
	public static function Zero():Quaternion {
		return new Quaternion(0.0, 0.0, 0.0, 0.0);
	}
		
	/**
	 * Returns a new Quaternion as the inverted current Quaternion.  
	 */
	inline public static function Inverse(q:Quaternion):Quaternion {
		return new Quaternion(-q.x, -q.y, -q.z, q.w);
	}
	
	inline public static function Identity():Quaternion {
		return new Quaternion(0, 0, 0, 1);
	}
	
	public static inline function IsIdentity(quaternion:Quaternion):Bool {
		return quaternion != null && quaternion.x == 0 && quaternion.y == 0 && quaternion.z == 0 && quaternion.w == 1;
	}
	
	/**
	 * Returns a new Quaternion set from the passed axis (Vector3) and angle in radians (float). 
	 */
	inline public static function RotationAxis(axis:Vector3, angle:Float):Quaternion {
		return Quaternion.RotationAxisToRef(axis, angle, new Quaternion());
	}

	/**
	 * Sets the passed quaternion "result" from the passed axis (Vector3) and angle in radians (float). 
	 */
	inline public static function RotationAxisToRef(axis:Vector3, angle:Float, result:Quaternion):Quaternion {
		var sin = Math.sin(angle / 2);
		
		axis.normalize();
		
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
		var q = new Quaternion();
		Quaternion.RotationYawPitchRollToRef(yaw, pitch, roll, q);
		
		return q;
	}

	inline public static function RotationYawPitchRollToRef(yaw:Float, pitch:Float, roll:Float, result:Quaternion) {
		// Produces a quaternion from Euler angles in the z-y-x orientation (Tait-Bryan angles)
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
	
	 /**
	 * Returns a new Quaternion from the passed float Euler angles expressed in z-x-z orientation
	 */
	public static function RotationAlphaBetaGamma(alpha:Float, beta:Float, gamma:Float):Quaternion {
		var result = new Quaternion();
		Quaternion.RotationAlphaBetaGammaToRef(alpha, beta, gamma, result);
		return result;
	}
	/**
	 * Sets the passed quaternion "result" from the passed float Euler angles expressed in z-x-z orientation
	 */
	public static function RotationAlphaBetaGammaToRef(alpha:Float, beta:Float, gamma:Float, result:Quaternion) {
		// Produces a quaternion from Euler angles in the z-x-z orientation
		var halfGammaPlusAlpha = (gamma + alpha) * 0.5;
		var halfGammaMinusAlpha = (gamma - alpha) * 0.5;
		var halfBeta = beta * 0.5;
		
		result.x = Math.cos(halfGammaMinusAlpha) * Math.sin(halfBeta);
		result.y = Math.sin(halfGammaMinusAlpha) * Math.sin(halfBeta);
		result.z = Math.sin(halfGammaPlusAlpha) * Math.cos(halfBeta);
		result.w = Math.cos(halfGammaPlusAlpha) * Math.cos(halfBeta);
	}

	/**
	 * Returns a new Quaternion as the quaternion rotation value to reach the target (axis1, axis2, axis3) orientation as a rotated XYZ system.   
	 * cf to Vector3.RotationFromAxis() documentation.  
	 * Note : axis1, axis2 and axis3 are normalized during this operation.   
	 */
	public static function RotationQuaternionFromAxis(axis1:Vector3, axis2:Vector3, axis3:Vector3, ref:Quaternion):Quaternion {
		var quat = new Quaternion(0.0, 0.0, 0.0, 0.0);
		Quaternion.RotationQuaternionFromAxisToRef(axis1, axis2, axis3, quat);
		return quat;
	}
	/**
	 * Sets the passed quaternion "ref" with the quaternion rotation value to reach the target (axis1, axis2, axis3) orientation as a rotated XYZ system.   
	 * cf to Vector3.RotationFromAxis() documentation.  
	 * Note : axis1, axis2 and axis3 are normalized during this operation.   
	 */
	public static function RotationQuaternionFromAxisToRef(axis1:Vector3, axis2:Vector3, axis3:Vector3, ref:Quaternion) {
		var rotMat = Tmp.matrix[0];
		Matrix.FromXYZAxesToRef(axis1.normalize(), axis2.normalize(), axis3.normalize(), rotMat);
		Quaternion.FromRotationMatrixToRef(rotMat, ref);
	}

	public static function Slerp(left:Quaternion, right:Quaternion, amount:Float):Quaternion {
		var result = Quaternion.Identity();
		
        Quaternion.SlerpToRef(left, right, amount, result);
		
        return result;
	}
	
	public static function SlerpToRef(left:Quaternion, right:Quaternion, amount:Float, result:Quaternion) {
		var num2:Float = 0.0;
		var num3:Float = 0.0;
		var num:Float = amount;
		var num4:Float = (((left.x * right.x) + (left.y * right.y)) + (left.z * right.z)) + (left.w * right.w);
		var flag:Bool = false;
		
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
		
		result.x = (num3 * left.x) + (num2 * right.x);
        result.y = (num3 * left.y) + (num2 * right.y);
        result.z = (num3 * left.z) + (num2 * right.z);
        result.w = (num3 * left.w) + (num2 * right.w);
	}
	
	/**
	 * Returns a new Quaternion located for "amount" (float) on the Hermite interpolation spline defined by the vectors "value1", "tangent1", "value2", "tangent2".
	 */
	public static function Hermite(value1:Quaternion, tangent1:Quaternion, value2:Quaternion, tangent2:Quaternion, amount:Float):Quaternion {
		var squared = amount * amount;
		var cubed = amount * squared;
		var part1 = ((2.0 * cubed) - (3.0 * squared)) + 1.0;
		var part2 = (-2.0 * cubed) + (3.0 * squared);
		var part3 = (cubed - (2.0 * squared)) + amount;
		var part4 = cubed - squared;
		
		var x = (((value1.x * part1) + (value2.x * part2)) + (tangent1.x * part3)) + (tangent2.x * part4);
		var y = (((value1.y * part1) + (value2.y * part2)) + (tangent1.y * part3)) + (tangent2.y * part4);
		var z = (((value1.z * part1) + (value2.z * part2)) + (tangent1.z * part3)) + (tangent2.z * part4);
		var w = (((value1.w * part1) + (value2.w * part2)) + (tangent1.w * part3)) + (tangent2.w * part4);
		return new Quaternion(x, y, z, w);
	}
	
}
