package com.babylonhx.math;

import com.babylonhx.cameras.Camera;

import com.babylonhx.utils.typedarray.Float32Array;
#if cpp
import haxe.ds.Vector;
#end


/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Matrix') class Matrix {
	
	private static var _tempQuaternion:Quaternion = new Quaternion();
	private static var _xAxis:Vector3 = Vector3.Zero();
	private static var _yAxis:Vector3 = Vector3.Zero();
	private static var _zAxis:Vector3 = Vector3.Zero();

	#if (js || html5 || purejs)
	public var m:Float32Array;
	#else
	public var m:Array<Float>;	
	#end
	
	
	inline public function new() {
		#if (js || html5 || purejs)
		m = new Float32Array([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
		#else
		m = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
		#end
	}
	
	public function toString():String {
		return m + "";
	}

	// Properties
	public function isIdentity():Bool {
		if (this.m[0] != 1.0 || this.m[5] != 1.0 || this.m[10] != 1.0 || this.m[15] != 1.0)
			return false;
			
		if (this.m[1] != 0.0 || this.m[2] != 0.0 || this.m[3] != 0.0 ||
			this.m[4] != 0.0 || this.m[6] != 0.0 || this.m[7] != 0.0 ||
			this.m[8] != 0.0 || this.m[9] != 0.0 || this.m[11] != 0.0 ||
			this.m[12] != 0.0 || this.m[13] != 0.0 || this.m[14] != 0.0)
			return false;
			
		return true;
	}

	inline public function determinant():Float {
		var temp1 = (this.m[10] * this.m[15]) - (this.m[11] * this.m[14]);
		var temp2 = (this.m[9] * this.m[15]) - (this.m[11] * this.m[13]);
		var temp3 = (this.m[9] * this.m[14]) - (this.m[10] * this.m[13]);
		var temp4 = (this.m[8] * this.m[15]) - (this.m[11] * this.m[12]);
		var temp5 = (this.m[8] * this.m[14]) - (this.m[10] * this.m[12]);
		var temp6 = (this.m[8] * this.m[13]) - (this.m[9] * this.m[12]);
		
		return ((((this.m[0] * (((this.m[5] * temp1) - (this.m[6] * temp2)) + (this.m[7] * temp3))) - (this.m[1] * (((this.m[4] * temp1) -
			(this.m[6] * temp4)) + (this.m[7] * temp5)))) + (this.m[2] * (((this.m[4] * temp2) - (this.m[5] * temp4)) + (this.m[7] * temp6)))) -
			(this.m[3] * (((this.m[4] * temp3) - (this.m[5] * temp5)) + (this.m[6] * temp6))));
	}

	// Methods
	inline public function toArray(): #if (js || html5 || purejs) Float32Array #else Array<Float> #end {
		return this.m;
	}

	inline public function asArray(): #if (js || html5 || purejs) Float32Array #else Array<Float> #end {
		return #if (js || html5 || purejs) m #else m #end ;
	}

	inline public function invert():Matrix {
		this.invertToRef(this);
		
		return this;
	}

	inline public function invertToRef(other:Matrix):Matrix {
		var l1 = this.m[0];
		var l2 = this.m[1];
		var l3 = this.m[2];
		var l4 = this.m[3];
		var l5 = this.m[4];
		var l6 = this.m[5];
		var l7 = this.m[6];
		var l8 = this.m[7];
		var l9 = this.m[8];
		var l10 = this.m[9];
		var l11 = this.m[10];
		var l12 = this.m[11];
		var l13 = this.m[12];
		var l14 = this.m[13];
		var l15 = this.m[14];
		var l16 = this.m[15];
		var l17 = (l11 * l16) - (l12 * l15);
		var l18 = (l10 * l16) - (l12 * l14);
		var l19 = (l10 * l15) - (l11 * l14);
		var l20 = (l9 * l16) - (l12 * l13);
		var l21 = (l9 * l15) - (l11 * l13);
		var l22 = (l9 * l14) - (l10 * l13);
		var l23 = ((l6 * l17) - (l7 * l18)) + (l8 * l19);
		var l24 = -(((l5 * l17) - (l7 * l20)) + (l8 * l21));
		var l25 = ((l5 * l18) - (l6 * l20)) + (l8 * l22);
		var l26 = -(((l5 * l19) - (l6 * l21)) + (l7 * l22));
		var l27 = 1.0 / ((((l1 * l23) + (l2 * l24)) + (l3 * l25)) + (l4 * l26));
		var l28 = (l7 * l16) - (l8 * l15);
		var l29 = (l6 * l16) - (l8 * l14);
		var l30 = (l6 * l15) - (l7 * l14);
		var l31 = (l5 * l16) - (l8 * l13);
		var l32 = (l5 * l15) - (l7 * l13);
		var l33 = (l5 * l14) - (l6 * l13);
		var l34 = (l7 * l12) - (l8 * l11);
		var l35 = (l6 * l12) - (l8 * l10);
		var l36 = (l6 * l11) - (l7 * l10);
		var l37 = (l5 * l12) - (l8 * l9);
		var l38 = (l5 * l11) - (l7 * l9);
		var l39 = (l5 * l10) - (l6 * l9);
		
		other.m[0] = l23 * l27;
		other.m[4] = l24 * l27;
		other.m[8] = l25 * l27;
		other.m[12] = l26 * l27;
		other.m[1] = -(((l2 * l17) - (l3 * l18)) + (l4 * l19)) * l27;
		other.m[5] = (((l1 * l17) - (l3 * l20)) + (l4 * l21)) * l27;
		other.m[9] = -(((l1 * l18) - (l2 * l20)) + (l4 * l22)) * l27;
		other.m[13] = (((l1 * l19) - (l2 * l21)) + (l3 * l22)) * l27;
		other.m[2] = (((l2 * l28) - (l3 * l29)) + (l4 * l30)) * l27;
		other.m[6] = -(((l1 * l28) - (l3 * l31)) + (l4 * l32)) * l27;
		other.m[10] = (((l1 * l29) - (l2 * l31)) + (l4 * l33)) * l27;
		other.m[14] = -(((l1 * l30) - (l2 * l32)) + (l3 * l33)) * l27;
		other.m[3] = -(((l2 * l34) - (l3 * l35)) + (l4 * l36)) * l27;
		other.m[7] = (((l1 * l34) - (l3 * l37)) + (l4 * l38)) * l27;
		other.m[11] = -(((l1 * l35) - (l2 * l37)) + (l4 * l39)) * l27;
		other.m[15] = (((l1 * l36) - (l2 * l38)) + (l3 * l39)) * l27;
		
		return this;
	}
	
	inline public function reset():Matrix {
        for (index in 0...16) {
            this.m[index] = 0;
        }
		
        return this;
    }
	
    inline public function add(other:Matrix):Matrix {
        var result = new Matrix();
        this.addToRef(other, result);
		
        return result;
    }

    inline public function addToRef(other:Matrix, result:Matrix):Matrix {
        for (index in 0...16) {
            result.m[index] = this.m[index] + other.m[index];
        }
		
        return this;
    }

    inline public function addToSelf(other:Matrix):Matrix {
        for (index in 0...16) {
            this.m[index] += other.m[index];
        }
		
        return this;
    }

	inline public function setTranslation(vector3:Vector3):Matrix {
		this.m[12] = vector3.x;
		this.m[13] = vector3.y;
		this.m[14] = vector3.z;
		
		return this;
	}
	
	inline public function getTranslation():Vector3 {
        return new Vector3(this.m[12], this.m[13], this.m[14]);
    }

	inline public function multiply(other:Matrix):Matrix {
		var result = new Matrix();
		
		this.multiplyToRef(other, result);
		
		return result;
	}

	inline public function copyFrom(other:Matrix):Matrix {
		for (index in 0...16) {
			this.m[index] = other.m[index];
		}
		
		return this;
	}

	inline public function copyToArray(array: #if (js || html5 || purejs) Float32Array #else Array<Float> #end, offset:Int = 0) {
		for (index in 0...16) {
			array[offset + index] = this.m[index];
		}
	}

	inline public function multiplyToRef(other:Matrix, result:Matrix):Matrix {
		this.multiplyToArray(other, result.m, 0);
		
		return this;
	}

	inline public function multiplyToArray(other:Matrix, result: #if (js || html5 || purejs) Float32Array #else Array<Float> #end, offset:Int) {	
		var tm = this.m;
		var om = other.m;
		result[offset] = tm[0] * om[0] + tm[1] * om[4] + tm[2] * om[8] + tm[3] * om[12];
		result[offset + 1] = tm[0] * om[1] + tm[1] * om[5] + tm[2] * om[9] + tm[3] * om[13];
		result[offset + 2] = tm[0] * om[2] + tm[1] * om[6] + tm[2] * om[10] + tm[3] * om[14];
		result[offset + 3] = tm[0] * om[3] + tm[1] * om[7] + tm[2] * om[11] + tm[3] * om[15];
		
		result[offset + 4] = tm[4] * om[0] + tm[5] * om[4] + tm[6] * om[8] + tm[7] * om[12];
		result[offset + 5] = tm[4] * om[1] + tm[5] * om[5] + tm[6] * om[9] + tm[7] * om[13];
		result[offset + 6] = tm[4] * om[2] + tm[5] * om[6] + tm[6] * om[10] + tm[7] * om[14];
		result[offset + 7] = tm[4] * om[3] + tm[5] * om[7] + tm[6] * om[11] + tm[7] * om[15];
		
		result[offset + 8] = tm[8] * om[0] + tm[9] * om[4] + tm[10] * om[8] + tm[11] * om[12];
		result[offset + 9] = tm[8] * om[1] + tm[9] * om[5] + tm[10] * om[9] + tm[11] * om[13];
		result[offset + 10] = tm[8] * om[2] + tm[9] * om[6] + tm[10] * om[10] + tm[11] * om[14];
		result[offset + 11] = tm[8] * om[3] + tm[9] * om[7] + tm[10] * om[11] + tm[11] * om[15];
		
		result[offset + 12] = tm[12] * om[0] + tm[13] * om[4] + tm[14] * om[8] + tm[15] * om[12];
		result[offset + 13] = tm[12] * om[1] + tm[13] * om[5] + tm[14] * om[9] + tm[15] * om[13];
		result[offset + 14] = tm[12] * om[2] + tm[13] * om[6] + tm[14] * om[10] + tm[15] * om[14];
		result[offset + 15] = tm[12] * om[3] + tm[13] * om[7] + tm[14] * om[11] + tm[15] * om[15];
	}

	inline public function equals(value:Matrix):Bool {
		return value != null &&
			(this.m[0] == value.m[0] && this.m[1] == value.m[1] && this.m[2] == value.m[2] && this.m[3] == value.m[3] &&
			this.m[4] == value.m[4] && this.m[5] == value.m[5] && this.m[6] == value.m[6] && this.m[7] == value.m[7] &&
			this.m[8] == value.m[8] && this.m[9] == value.m[9] && this.m[10] == value.m[10] && this.m[11] == value.m[11] &&
			this.m[12] == value.m[12] && this.m[13] == value.m[13] && this.m[14] == value.m[14] && this.m[15] == value.m[15]);
	}

	inline public function clone():Matrix {
		return Matrix.FromValues(this.m[0], this.m[1], this.m[2], this.m[3],
			this.m[4], this.m[5], this.m[6], this.m[7],
			this.m[8], this.m[9], this.m[10], this.m[11],
			this.m[12], this.m[13], this.m[14], this.m[15]);
	}
	
	public function decompose(scale:Vector3, rotation:Quaternion, translation:Vector3):Bool {
		translation.x = this.m[12];
		translation.y = this.m[13];
		translation.z = this.m[14];
		
		var xs = Tools.Sign(this.m[0] * this.m[1] * this.m[2] * this.m[3]) < 0 ? -1 : 1;
		var ys = Tools.Sign(this.m[4] * this.m[5] * this.m[6] * this.m[7]) < 0 ? -1 : 1;
		var zs = Tools.Sign(this.m[8] * this.m[9] * this.m[10] * this.m[11]) < 0 ? -1 : 1;
		
		scale.x = xs * Math.sqrt(this.m[0] * this.m[0] + this.m[1] * this.m[1] + this.m[2] * this.m[2]);
		scale.y = ys * Math.sqrt(this.m[4] * this.m[4] + this.m[5] * this.m[5] + this.m[6] * this.m[6]);
		scale.z = zs * Math.sqrt(this.m[8] * this.m[8] + this.m[9] * this.m[9] + this.m[10] * this.m[10]);
		
		if (scale.x == 0 || scale.y == 0 || scale.z == 0) {
			rotation.x = 0;
			rotation.y = 0;
			rotation.z = 0;
			rotation.w = 1;
			
			return false;
		}
		
		var rotationMatrix = Matrix.FromValues(
			this.m[0] / scale.x, this.m[1] / scale.x, this.m[2] / scale.x, 0,
			this.m[4] / scale.y, this.m[5] / scale.y, this.m[6] / scale.y, 0,
			this.m[8] / scale.z, this.m[9] / scale.z, this.m[10] / scale.z, 0,
			0, 0, 0, 1);
			
		Quaternion.FromRotationMatrixToRef(rotationMatrix, rotation);
		
		return true;
	}

	// Statics
	inline public static function FromArray(array:Array<Float>, offset:Int = 0):Matrix {
		var result = new Matrix();
		
		Matrix.FromArrayToRef(array, offset, result);
		
		return result;
	}

	inline public static function FromArrayToRef(array:Array<Float>, offset:Int, result:Matrix) {
		for (index in 0...16) {
			result.m[index] = array[index + offset];
		}
	}
	
	inline public static function FromFloat32ArrayToRefScaled(array:Float32Array, offset:Int, scale:Float, result:Matrix) {
        for (index in 0...16) {
            result.m[index] = array[index + offset] * scale;
        }
    }

	public static function FromValuesToRef(initialM11:Float, initialM12:Float, initialM13:Float, initialM14:Float,
		initialM21:Float, initialM22:Float, initialM23:Float, initialM24:Float,
		initialM31:Float, initialM32:Float, initialM33:Float, initialM34:Float,
		initialM41:Float, initialM42:Float, initialM43:Float, initialM44:Float, result:Matrix) {
			
		result.m[0] = initialM11;
		result.m[1] = initialM12;
		result.m[2] = initialM13;
		result.m[3] = initialM14;
		result.m[4] = initialM21;
		result.m[5] = initialM22;
		result.m[6] = initialM23;
		result.m[7] = initialM24;
		result.m[8] = initialM31;
		result.m[9] = initialM32;
		result.m[10] = initialM33;
		result.m[11] = initialM34;
		result.m[12] = initialM41;
		result.m[13] = initialM42;
		result.m[14] = initialM43;
		result.m[15] = initialM44;
	}
	
	public function getRow(index:Int):Vector4 {
		if (index < 0 || index > 3) {
			return null;
		}
		
		var i = Std.int(index * 4);
		
		return new Vector4(this.m[i + 0], this.m[i + 1], this.m[i + 2], this.m[i + 3]);
	}

	public function setRow(index:Int, row:Vector4):Matrix {
		if (index < 0 || index > 3) {
			return null;
		}
		
		var i = Std.int(index * 4);
		
		this.m[i + 0] = row.x;
		this.m[i + 1] = row.y;
		this.m[i + 2] = row.z;
		this.m[i + 3] = row.w;
		
		return this;
	}

	inline public static function FromValues(initialM11:Float, initialM12:Float, initialM13:Float, initialM14:Float,
		initialM21:Float, initialM22:Float, initialM23:Float, initialM24:Float,
		initialM31:Float, initialM32:Float, initialM33:Float, initialM34:Float,
		initialM41:Float, initialM42:Float, initialM43:Float, initialM44:Float):Matrix {
			
		var result = new Matrix();
		
		result.m[0] = initialM11;
		result.m[1] = initialM12;
		result.m[2] = initialM13;
		result.m[3] = initialM14;
		result.m[4] = initialM21;
		result.m[5] = initialM22;
		result.m[6] = initialM23;
		result.m[7] = initialM24;
		result.m[8] = initialM31;
		result.m[9] = initialM32;
		result.m[10] = initialM33;
		result.m[11] = initialM34;
		result.m[12] = initialM41;
		result.m[13] = initialM42;
		result.m[14] = initialM43;
		result.m[15] = initialM44;
		
		return result;
	}
	
	public static inline function Compose(scale:Vector3, rotation:Quaternion, translation:Vector3):Matrix {
		var result = Matrix.FromValues(
			scale.x, 0, 0, 0,
			0, scale.y, 0, 0,
			0, 0, scale.z, 0,
			0, 0, 0, 1
		);
		
		var rotationMatrix = Matrix.Identity();
		rotation.toRotationMatrix(rotationMatrix);
		result = result.multiply(rotationMatrix);
		
		result.setTranslation(translation);
		
		return result;
	}

	inline public static function Identity():Matrix {
		return Matrix.FromValues(
			1.0, 0, 0, 0,
			0, 1.0, 0, 0,
			0, 0, 1.0, 0,
			0, 0, 0, 1.0
		);
	}

	inline public static function IdentityToRef(result:Matrix) {
		Matrix.FromValuesToRef(
			1.0, 0, 0, 0,
			0, 1.0, 0, 0,
			0, 0, 1.0, 0,
			0, 0, 0, 1.0, result
		);
	}

	inline public static function Zero():Matrix {
		return Matrix.FromValues(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0
		);
	}

	inline public static function RotationX(angle:Float):Matrix {
		var result = new Matrix();
		
		Matrix.RotationXToRef(angle, result);
		
		return result;
	}
	
	inline public static function Invert(source:Matrix):Matrix {
		var result = new Matrix();
		
		source.invertToRef(result);
		
		return result;
	}

	inline public static function RotationXToRef(angle:Float, result:Matrix) {
		var s = Math.sin(angle);
		var c = Math.cos(angle);
		
		result.m[0] = 1.0;
		result.m[15] = 1.0;
		
		result.m[5] = c;
		result.m[10] = c;
		result.m[9] = -s;
		result.m[6] = s;
		
		result.m[1] = 0;
		result.m[2] = 0;
		result.m[3] = 0;
		result.m[4] = 0;
		result.m[7] = 0;
		result.m[8] = 0;
		result.m[11] = 0;
		result.m[12] = 0;
		result.m[13] = 0;
		result.m[14] = 0;
	}

	inline public static function RotationY(angle:Float):Matrix {
		var result = new Matrix();
		
		Matrix.RotationYToRef(angle, result);
		
		return result;
	}

	inline public static function RotationYToRef(angle:Float, result:Matrix) {
		var s = Math.sin(angle);
		var c = Math.cos(angle);
		
		result.m[5] = 1.0;
		result.m[15] = 1.0;
		
		result.m[0] = c;
		result.m[2] = -s;
		result.m[8] = s;
		result.m[10] = c;
		
		result.m[1] = 0;
		result.m[3] = 0;
		result.m[4] = 0;
		result.m[6] = 0;
		result.m[7] = 0;
		result.m[9] = 0;
		result.m[11] = 0;
		result.m[12] = 0;
		result.m[13] = 0;
		result.m[14] = 0;
	}

	inline public static function RotationZ(angle:Float):Matrix {
		var result = new Matrix();
		
		Matrix.RotationZToRef(angle, result);
		
		return result;
	}

	inline public static function RotationZToRef(angle:Float, result:Matrix) {
		var s = Math.sin(angle);
		var c = Math.cos(angle);
		
		result.m[10] = 1.0;
		result.m[15] = 1.0;
		
		result.m[0] = c;
		result.m[1] = s;
		result.m[4] = -s;
		result.m[5] = c;
		
		result.m[2] = 0;
		result.m[3] = 0;
		result.m[6] = 0;
		result.m[7] = 0;
		result.m[8] = 0;
		result.m[9] = 0;
		result.m[11] = 0;
		result.m[12] = 0;
		result.m[13] = 0;
		result.m[14] = 0;
	}

	inline public static function RotationAxis(axis:Vector3, angle:Float):Matrix {
		var result = Matrix.Zero();
		
		Matrix.RotationAxisToRef(axis, angle, result);
		
		return result;
	}
	
	public static function RotationAxisToRef(axis:Vector3, angle:Float, result:Matrix) {
		var s = Math.sin(-angle);
		var c = Math.cos(-angle);
		var c1:Float = 1 - c;
		
		axis.normalize();
		
		result.m[0] = (axis.x * axis.x) * c1 + c;
		result.m[1] = (axis.x * axis.y) * c1 - (axis.z * s);
		result.m[2] = (axis.x * axis.z) * c1 + (axis.y * s);
		result.m[3] = 0.0;
		
		result.m[4] = (axis.y * axis.x) * c1 + (axis.z * s);
		result.m[5] = (axis.y * axis.y) * c1 + c;
		result.m[6] = (axis.y * axis.z) * c1 - (axis.x * s);
		result.m[7] = 0.0;
		
		result.m[8] = (axis.z * axis.x) * c1 - (axis.y * s);
		result.m[9] = (axis.z * axis.y) * c1 + (axis.x * s);
		result.m[10] = (axis.z * axis.z) * c1 + c;
		result.m[11] = 0.0;
		
		result.m[15] = 1.0;
	}

	inline public static function RotationYawPitchRoll(yaw:Float, pitch:Float, roll:Float):Matrix {
		var result = new Matrix();
		
		Matrix.RotationYawPitchRollToRef(yaw, pitch, roll, result);
		
		return result;
	}

	inline public static function RotationYawPitchRollToRef(yaw:Float, pitch:Float, roll:Float, result:Matrix) {
		Quaternion.RotationYawPitchRollToRef(yaw, pitch, roll, Matrix._tempQuaternion);
		Matrix._tempQuaternion.toRotationMatrix(result);
	}

	inline public static function Scaling(x:Float, y:Float, z:Float):Matrix {
		var result = Matrix.Zero();
		
		Matrix.ScalingToRef(x, y, z, result);
		
		return result;
	}

	inline public static function ScalingToRef(x:Float, y:Float, z:Float, result:Matrix) {
		result.m[0] = x;
		result.m[1] = 0;
		result.m[2] = 0;
		result.m[3] = 0;
		result.m[4] = 0;
		result.m[5] = y;
		result.m[6] = 0;
		result.m[7] = 0;
		result.m[8] = 0;
		result.m[9] = 0;
		result.m[10] = z;
		result.m[11] = 0;
		result.m[12] = 0;
		result.m[13] = 0;
		result.m[14] = 0;
		result.m[15] = 1.0;
	}

	inline public static function Translation(x:Float, y:Float, z:Float):Matrix {
		var result = Matrix.Identity();
		
		Matrix.TranslationToRef(x, y, z, result);
		
		return result;
	}

	inline public static function TranslationToRef(x:Float, y:Float, z:Float, result:Matrix) {
		Matrix.FromValuesToRef(
			1.0, 0, 0, 0,
			0, 1.0, 0, 0,
			0, 0, 1.0, 0,
			x, y, z, 1.0, result);
	}
	
	inline public static function Lerp(startValue:Matrix, endValue:Matrix, gradient:Float):Matrix {
		var result = Matrix.Zero();
		
		for (index in 0...16) {
			result.m[index] = startValue.m[index] * (1.0 - gradient) + endValue.m[index] * gradient;
		}
		
		return result;
	}

	public static function DecomposeLerp(startValue:Matrix, endValue:Matrix, gradient:Float):Matrix {
		var startScale = new Vector3(0, 0, 0);
		var startRotation = new Quaternion();
		var startTranslation = new Vector3(0, 0, 0);
		startValue.decompose(startScale, startRotation, startTranslation);
		
		var endScale = new Vector3(0, 0, 0);
		var endRotation = new Quaternion();
		var endTranslation = new Vector3(0, 0, 0);
		endValue.decompose(endScale, endRotation, endTranslation);
		
		var resultScale = Vector3.Lerp(startScale, endScale, gradient);
		var resultRotation = Quaternion.Slerp(startRotation, endRotation, gradient);
		var resultTranslation = Vector3.Lerp(startTranslation, endTranslation, gradient);
		
		return Matrix.Compose(resultScale, resultRotation, resultTranslation);
	} 

	inline public static function LookAtLH(eye:Vector3, target:Vector3, up:Vector3):Matrix {
		var result = Matrix.Zero();
		Matrix.LookAtLHToRef(eye, target, up, result);
		
		return result;
	}

	static var ex:Float;
	static var ey:Float;
	static var ez:Float;
	public static function LookAtLHToRef(eye:Vector3, target:Vector3, up:Vector3, result:Matrix) {
		// Z axis
		target.subtractToRef(eye, Matrix._zAxis);
		Matrix._zAxis.normalize();
		
		// X axis
		Vector3.CrossToRef(up, Matrix._zAxis, Matrix._xAxis);
		
		if (Matrix._xAxis.lengthSquared() == 0) {
			Matrix._xAxis.x = 1.0;
		} 
		else {
			Matrix._xAxis.normalize();
		}
		
		// Y axis
		Vector3.CrossToRef(Matrix._zAxis, Matrix._xAxis, Matrix._yAxis);
		Matrix._yAxis.normalize();
		
		// Eye angles
		ex = -Vector3.Dot(Matrix._xAxis, eye);
		ey = -Vector3.Dot(Matrix._yAxis, eye);
		ez = -Vector3.Dot(Matrix._zAxis, eye);
		
		return Matrix.FromValuesToRef(Matrix._xAxis.x, Matrix._yAxis.x, Matrix._zAxis.x, 0,
			Matrix._xAxis.y, Matrix._yAxis.y, Matrix._zAxis.y, 0,
			Matrix._xAxis.z, Matrix._yAxis.z, Matrix._zAxis.z, 0,
			ex, ey, ez, 1, result);
	}

	inline public static function OrthoLH(width:Float, height:Float, znear:Float, zfar:Float):Matrix {
		var hw = 2.0 / width;
		var hh = 2.0 / height;
		var id = 1.0 / (zfar - znear);
		var nid = znear / (znear - zfar);
		
		return Matrix.FromValues(hw, 0, 0, 0,
			0, hh, 0, 0,
			0, 0, id, 0,
			0, 0, nid, 1);
	}

	inline public static function OrthoOffCenterLH(left:Float, right:Float, bottom:Float, top:Float, znear:Float, zfar:Float):Matrix {
		var matrix = Matrix.Zero();
		Matrix.OrthoOffCenterLHToRef(left, right, bottom, top, znear, zfar, matrix);
		return matrix;
	}

	public static function OrthoOffCenterLHToRef(left:Float, right:Float, bottom:Float, top:Float, znear:Float, zfar:Float, result:Matrix) {
		result.m[0] = 2.0 / (right - left);
		result.m[1] = 0;
		result.m[2] = 0;
		result.m[3] = 0;
		result.m[5] = 2.0 / (top - bottom);
		result.m[4] = 0;
		result.m[6] = 0;
		result.m[7] = 0;
		result.m[10] = -1.0 / (znear - zfar);
		result.m[8] = 0;
		result.m[9] = 0;
		result.m[11] = 0;
		result.m[12] = (left + right) / (left - right);
		result.m[13] = (top + bottom) / (bottom - top);
		result.m[14] = znear / (znear - zfar);
		result.m[15] = 1.0;
	}

	inline public static function PerspectiveLH(width:Float, height:Float, znear:Float, zfar:Float):Matrix {
		var matrix = Matrix.Zero();
		
		matrix.m[0] = (2.0 * znear) / width;
		matrix.m[1] = 0.0;
		matrix.m[2] = 0.0;
		matrix.m[3] = 0.0;
		matrix.m[5] = (2.0 * znear) / height;
		matrix.m[4] = 0.0;
		matrix.m[6] = 0.0;
		matrix.m[7] = 0.0;
		matrix.m[10] = -zfar / (znear - zfar);
		matrix.m[8] = 0.0;
		matrix.m[9] = 0.0;
		matrix.m[11] = 1.0;
		matrix.m[12] = 0.0;
		matrix.m[13] = 0.0;
		matrix.m[15] = 0.0;
		matrix.m[14] = (znear * zfar) / (znear - zfar);
		
		return matrix;
	}

	inline public static function PerspectiveFovLH(fov:Float, aspect:Float, znear:Float, zfar:Float):Matrix {
		var matrix = Matrix.Zero();
		
		Matrix.PerspectiveFovLHToRef(fov, aspect, znear, zfar, matrix);
		
		return matrix;
	}

	public static function PerspectiveFovLHToRef(fov:Float, aspect:Float, znear:Float, zfar:Float, result:Matrix, isVerticalFovFixed:Bool = true) {
		var tan = 1.0 / (Math.tan(fov * 0.5));
		
		if (isVerticalFovFixed) {
			result.m[0] = tan / aspect;
		} 
		else {
			result.m[0] = tan;
		}
		
		result.m[1] = 0.0;
		result.m[2] = 0.0;
		result.m[3] = 0.0;
		
		if (isVerticalFovFixed) { 
			result.m[5] = tan; 
		} 
		else { 
			result.m[5] = tan * aspect; 
		}
			
		result.m[4] = 0.0;
		result.m[6] = 0.0;
		result.m[7] = 0.0;
		result.m[8] = 0.0;
		result.m[9] = 0.0;
		result.m[10] = -zfar / (znear - zfar);
		result.m[11] = 1.0;
		result.m[12] = 0.0;
		result.m[13] = 0.0;
		result.m[15] = 0.0;
		result.m[14] = (znear * zfar) / (znear - zfar);
	}

	inline public static function GetFinalMatrix(viewport:Viewport, world:Matrix, view:Matrix, projection:Matrix, zmin:Float, zmax:Float):Matrix {
		var cw = viewport.width;
		var ch = viewport.height;
		var cx = viewport.x;
		var cy = viewport.y;
		
		var viewportMatrix = Matrix.FromValues(cw / 2.0, 0, 0, 0,
			0, -ch / 2.0, 0, 0,
			0, 0, zmax - zmin, 0,
			cx + cw / 2.0, ch / 2.0 + cy, zmin, 1);
			
		return world.multiply(view).multiply(projection).multiply(viewportMatrix);
	}
	
	inline public static function GetAsMatrix2x2(matrix:Matrix):Float32Array {
		return new Float32Array([
			matrix.m[0], matrix.m[1],
			matrix.m[4], matrix.m[5]
		]);
	}

	inline public static function GetAsMatrix3x3(matrix:Matrix):Float32Array {
		return new Float32Array([
			matrix.m[0], matrix.m[1], matrix.m[2],
			matrix.m[4], matrix.m[5], matrix.m[6],
			matrix.m[8], matrix.m[9], matrix.m[10]
		]);
	}

	inline public static function Transpose(matrix:Matrix):Matrix {
		var result = new Matrix();
		
		result.m[0] = matrix.m[0];
		result.m[1] = matrix.m[4];
		result.m[2] = matrix.m[8];
		result.m[3] = matrix.m[12];
		
		result.m[4] = matrix.m[1];
		result.m[5] = matrix.m[5];
		result.m[6] = matrix.m[9];
		result.m[7] = matrix.m[13];
		
		result.m[8] = matrix.m[2];
		result.m[9] = matrix.m[6];
		result.m[10] = matrix.m[10];
		result.m[11] = matrix.m[14];
		
		result.m[12] = matrix.m[3];
		result.m[13] = matrix.m[7];
		result.m[14] = matrix.m[11];
		result.m[15] = matrix.m[15];
		
		return result;
	}

	inline public static function Reflection(plane:Plane):Matrix {
		var matrix = new Matrix();
		Matrix.ReflectionToRef(plane, matrix);
		return matrix;
	}

	public static function ReflectionToRef(plane:Plane, result:Matrix) {
		plane.normalize();
		var x = plane.normal.x;
		var y = plane.normal.y;
		var z = plane.normal.z;
		var temp = -2 * x;
		var temp2 = -2 * y;
		var temp3 = -2 * z;
		result.m[0] = (temp * x) + 1;
		result.m[1] = temp2 * x;
		result.m[2] = temp3 * x;
		result.m[3] = 0.0;
		result.m[4] = temp * y;
		result.m[5] = (temp2 * y) + 1;
		result.m[6] = temp3 * y;
		result.m[7] = 0.0;
		result.m[8] = temp * z;
		result.m[9] = temp2 * z;
		result.m[10] = (temp3 * z) + 1;
		result.m[11] = 0.0;
		result.m[12] = temp * plane.d;
		result.m[13] = temp2 * plane.d;
		result.m[14] = temp3 * plane.d;
		result.m[15] = 1.0;
	}
	
}
