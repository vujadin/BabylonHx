package com.gamestudiohx.babylonhx.tools.math;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Quaternion {

	public var x:Float;		
	public var y:Float;
	public var z:Float;
	public var w:Float;

	public function toString():String {
		return "{X: " + this.x + " Y:" + this.y + " Z:" + this.z + " W:" + this.w + "}";
	}

	public function new(initialX:Float = 0, initialY:Float = 0, initialZ:Float = 0, initialW:Float = 0) {
		this.x = initialX;
        this.y = initialY;
        this.z = initialZ;
        this.w = initialW;
	}

	inline public function equals(otherQuaternion:Quaternion):Bool {
		return this.x == otherQuaternion.x && this.y == otherQuaternion.y && this.z == otherQuaternion.z && this.w == otherQuaternion.w;
	}
	
	inline public function clone():Quaternion {
		return new Quaternion(this.x, this.y, this.z, this.w);
	}
	
	inline public function copyFrom(other:Quaternion) {
		this.x = other.x;
        this.y = other.y;
        this.z = other.z;
        this.w = other.w;
	}
	
	inline public function add(other:Quaternion):Quaternion {
		return new Quaternion(this.x + other.x, this.y + other.y, this.z + other.z, this.w + other.w);
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
		result.x = this.x * q1.w + this.y * q1.z - this.z * q1.y + this.w * q1.x;
        result.y = -this.x * q1.z + this.y * q1.w + this.z * q1.x + this.w * q1.y;
        result.z = this.x * q1.y - this.y * q1.x + this.z * q1.w + this.w * q1.z;
        result.w = -this.x * q1.x - this.y * q1.y - this.z * q1.z + this.w * q1.w;
		
		return result;
	}
	
	inline public function length():Float {
		return Math.sqrt((this.x * this.x) + (this.y * this.y) + (this.z * this.z) + (this.w * this.w));
	}
	
	inline public function normalize() {
		var length = 1.0 / this.length();
        this.x *= length;
        this.y *= length;
        this.z *= length;
        this.w *= length;
	}
	
	inline public function toEulerAngles():Vector3 {
		var qx = this.x;
        var qy = this.y;
        var qz = this.z;
        var qw = this.w;

        var sqx = qx * qx;
        var sqy = qy * qy;
        var sqz = qz * qz;

        var yaw = Math.atan2(2.0 * (qy * qw - qx * qz), 1.0 - 2.0 * (sqy + sqz));
        var pitch = Math.asin(2.0 * (qx * qy + qz * qw));
        var roll = Math.atan2(2.0 * (qx * qw - qy * qz), 1.0 - 2.0 * (sqx + sqz));

        var gimbaLockTest = qx * qy + qz * qw;
        if (gimbaLockTest > 0.499) {
            yaw = 2.0 * Math.atan2(qx, qw);
            roll = 0;
        } else if (gimbaLockTest < -0.499) {
            yaw = -2.0 * Math.atan2(qx, qw);
            roll = 0;
        }

        return new Vector3(pitch, yaw, roll);
	}
	
	inline public function toRotationMatrix(result:Matrix):Matrix {
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
	
	inline public static function RotationYawPitchRollToRef(yaw:Float, pitch:Float, roll:Float, result:Quaternion):Quaternion {
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
		
		return result;
	}
	
	inline public static function Slerp(left:Quaternion, right:Quaternion, amount:Float):Quaternion {
		var num2:Float;
        var num3:Float;
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
