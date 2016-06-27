package com.babylonhx.math;

import com.babylonhx.tools.Tools;
import com.babylonhx.utils.typedarray.Float32Array;
import haxe.ds.Vector;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Vector3') class Vector3 {
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	

	inline public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	inline public function toString():String {
		return "{X:" + this.x + " Y:" + this.y + " Z:" + this.z + "}";
	}
	
	inline public function getClassName():String {
        return "Vector3";
    }
	
	public function getHashCode():Int {
        var hash = Std.int(this.x);
        hash = Std.int(hash * 397) ^ Std.int(this.y);
		hash = Std.int(hash * 397) ^ Std.int(this.z);
		
        return hash;
    }

	// Operators
	inline public function asArray():Array<Float> {
		var result:Array<Float> = [];
		
		this.toArray(result, 0);
		
		return result;
	}
	
	inline public function set(x:Float = 0, y:Float = 0, z:Float = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	inline public function toArray(array:Array<Float>, index:Int = 0) {
		array[index] = this.x;
		array[index + 1] = this.y;
		array[index + 2] = this.z;
	}
	
	inline public function toFloat32Array(array:Float32Array, index:Int = 0) {
		array[index] = this.x;
		array[index + 1] = this.y;
		array[index + 2] = this.z;
	}
	
	public function toQuaternion():Quaternion {
		var result = new Quaternion(0, 0, 0, 1);
		
		var cosxPlusz = Math.cos((this.x + this.z) * 0.5);
		var sinxPlusz = Math.sin((this.x + this.z) * 0.5);
		var coszMinusx = Math.cos((this.z - this.x) * 0.5);
		var sinzMinusx = Math.sin((this.z - this.x) * 0.5);
		var cosy = Math.cos(this.y * 0.5);
		var siny = Math.sin(this.y * 0.5);
		
		result.x = coszMinusx * siny;
		result.y = -sinzMinusx * siny;
		result.z = sinxPlusz * cosy;
		result.w = cosxPlusz * cosy;
		
		return result;
	}

	inline public function addInPlace(otherVector:Vector3):Vector3 {
		this.x += otherVector.x;
		this.y += otherVector.y;
		this.z += otherVector.z;
		
		return this;
	}

	inline public function add(otherVector:Vector3):Vector3 {
		return new Vector3(this.x + otherVector.x, this.y + otherVector.y, this.z + otherVector.z);
	}

	inline public function addToRef(otherVector:Vector3, result:Vector3):Vector3 {
		result.x = this.x + otherVector.x;
		result.y = this.y + otherVector.y;
		result.z = this.z + otherVector.z;
		
		return this;
	}

	inline public function subtractInPlace(otherVector:Vector3):Vector3 {
		this.x -= otherVector.x;
		this.y -= otherVector.y;
		this.z -= otherVector.z;
		
		return this;
	}

	inline public function subtract(otherVector:Vector3):Vector3 {
		return new Vector3(this.x - otherVector.x, this.y - otherVector.y, this.z - otherVector.z);
	}

	inline public function subtractToRef(otherVector:Vector3, result:Vector3):Vector3 {
		result.x = this.x - otherVector.x;
		result.y = this.y - otherVector.y;
		result.z = this.z - otherVector.z;
		
		return this;
	}

	inline public function subtractFromFloats(x:Float, y:Float, z:Float):Vector3 {
		return new Vector3(this.x - x, this.y - y, this.z - z);
	}

	inline public function subtractFromFloatsToRef(x:Float, y:Float, z:Float, result:Vector3):Vector3 {
		result.x = this.x - x;
		result.y = this.y - y;
		result.z = this.z - z;
		
		return this;
	}

	inline public function negate():Vector3 {
		return new Vector3(-this.x, -this.y, -this.z);
	}

	inline public function scaleInPlace(scale:Float):Vector3 {
		this.x *= scale;
		this.y *= scale;
		this.z *= scale;
		
		return this;
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
		return otherVector != null && this.x == otherVector.x && this.y == otherVector.y && this.z == otherVector.z;
	}

	inline public function equalsWithEpsilon(otherVector:Vector3, epsilon:Float = Tools.Epsilon):Bool {
		return otherVector != null && Tools.WithinEpsilon(this.x, otherVector.x, epsilon) && Tools.WithinEpsilon(this.y, otherVector.y, epsilon) && Tools.WithinEpsilon(this.z, otherVector.z, epsilon);
	}

	inline public function equalsToFloats(x:Float, y:Float, z:Float):Bool {
		return this.x == x && this.y == y && this.z == z;
	}

	inline public function multiplyInPlace(otherVector:Vector3):Vector3 {
		this.x *= otherVector.x;
		this.y *= otherVector.y;
		this.z *= otherVector.z;
		
		return this;
	}

	inline public function multiply(otherVector:Vector3):Vector3 {
		return new Vector3(this.x * otherVector.x, this.y * otherVector.y, this.z * otherVector.z);
	}

	inline public function multiplyToRef(otherVector:Vector3, result:Vector3):Vector3 {
		result.x = this.x * otherVector.x;
		result.y = this.y * otherVector.y;
		result.z = this.z * otherVector.z;
		
		return this;
	}

	inline public function multiplyByFloats(x:Float, y:Float, z:Float):Vector3 {
		return new Vector3(this.x * x, this.y * y, this.z * z);
	}

	inline public function divide(otherVector:Vector3):Vector3 {
		return new Vector3(this.x / otherVector.x, this.y / otherVector.y, this.z / otherVector.z);
	}

	inline public function divideToRef(otherVector:Vector3, result:Vector3):Vector3 {
		result.x = this.x / otherVector.x;
		result.y = this.y / otherVector.y;
		result.z = this.z / otherVector.z;
		
		return this;
	}

	inline public function MinimizeInPlace(other:Vector3):Vector3 {
		if (other.x < this.x) this.x = other.x;
		if (other.y < this.y) this.y = other.y;
		if (other.z < this.z) this.z = other.z;
		
		return this;
	}

	inline public function MaximizeInPlace(other:Vector3):Vector3 {
		if (other.x > this.x) this.x = other.x;
		if (other.y > this.y) this.y = other.y;
		if (other.z > this.z) this.z = other.z;
		
		return this;
	}

	// Properties
	inline public function length():Float {
		return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
	}

	inline public function lengthSquared():Float {
		return (this.x * this.x + this.y * this.y + this.z * this.z);
	}

	// Methods
	public function normalize():Vector3 {
		var len = this.length();
		
		if (len == 0 || len == 1) {
			return this;
		}
		
		var num = 1.0 / len;
		
		this.x *= num;
		this.y *= num;
		this.z *= num;
		
		return this;
	}

	inline public function clone():Vector3 {
		return new Vector3(this.x, this.y, this.z);
	}

	inline public function copyFrom(source:Vector3):Vector3 {
		this.x = source.x;
		this.y = source.y;
		this.z = source.z;
		
		return this;
	}

	inline public function copyFromFloats(x:Float, y:Float, z:Float):Vector3 {
		this.x = x;
		this.y = y;
		this.z = z;
		
		return this;
	}

	// Statics
	inline public static function GetClipFactor(vector0:Vector3, vector1:Vector3, axis:Vector3, size:Float):Float {
        var d0 = Vector3.Dot(vector0, axis) - size;
        var d1 = Vector3.Dot(vector1, axis) - size;
		
        var s = d0 / (d0 - d1);
		
        return s;
    }
	
	inline public static function FromArray(array:Array<Float>, offset:Int = 0):Vector3 {
		return new Vector3(array[offset], array[offset + 1], array[offset + 2]);
	}
	
	inline public static function FromFloatArray(array:Float32Array, offset:Int = 0):Vector3 {
        return new Vector3(array[offset], array[offset + 1], array[offset + 2]);
    }

	inline public static function FromArrayToRef(array:Array<Float>, offset:Int, result:Vector3) {
		result.x = array[offset];
		result.y = array[offset + 1];
		result.z = array[offset + 2];
	}

	inline public static function FromFloatArrayToRef(array: #if (js || purejs || web || html5) Float32Array #else Array<Float> #end, offset:Int, result:Vector3) {
		result.x = array[offset];
		result.y = array[offset + 1];
		result.z = array[offset + 2];
	}

	inline public static function FromFloatsToRef(x:Float, y:Float, z:Float, result:Vector3) {
		result.x = x;
		result.y = y;
		result.z = z;
	}

	inline public static function Zero():Vector3 {
		return new Vector3(0, 0, 0);
	}
	
	inline public static function One():Vector3 {
		return new Vector3(1, 1, 1);
	}

	inline public static function Up():Vector3 {
		return new Vector3(0, 1.0, 0);
	}
	
	inline public static function Down():Vector3 {
		return new Vector3(0, -1.0, 0);
	}
	
	inline public static function Forward():Vector3 {
		return new Vector3(0, 0, 1.0);
	}
	
	inline public static function Back():Vector3 {
		return new Vector3(0, 0, -1.0);
	}
	
	inline public static function Right():Vector3 {
		return new Vector3(1.0, 0, 0);
	}
	
	inline public static function Left():Vector3 {
		return new Vector3(-1.0, 0, 0);
	}

	inline public static function TransformCoordinates(vector:Vector3, transformation:Matrix):Vector3 {
		var result = Vector3.Zero();
		
		Vector3.TransformCoordinatesToRef(vector, transformation, result);
		
		return result;
	}

	inline public static function TransformCoordinatesToRef(vector:Vector3, transformation:Matrix, result:Vector3) {
		var vx = vector.x;
		var vy = vector.y;
		var vz = vector.z;
		var tm = transformation.m;
		var x = (vx * tm[0]) + (vy * tm[4]) + (vz * tm[8]) + tm[12];
		var y = (vx * tm[1]) + (vy * tm[5]) + (vz * tm[9]) + tm[13];
		var z = (vx * tm[2]) + (vy * tm[6]) + (vz * tm[10]) + tm[14];
		var w = (vx * tm[3]) + (vy * tm[7]) + (vz * tm[11]) + tm[15];
		
		result.x = x / w;
		result.y = y / w;
		result.z = z / w;
	}

	inline public static function TransformCoordinatesFromFloatsToRef(x:Float, y:Float, z:Float, transformation:Matrix, result:Vector3) {
		var rx = (x * transformation.m[0]) + (y * transformation.m[4]) + (z * transformation.m[8]) + transformation.m[12];
		var ry = (x * transformation.m[1]) + (y * transformation.m[5]) + (z * transformation.m[9]) + transformation.m[13];
		var rz = (x * transformation.m[2]) + (y * transformation.m[6]) + (z * transformation.m[10]) + transformation.m[14];
		var rw = (x * transformation.m[3]) + (y * transformation.m[7]) + (z * transformation.m[11]) + transformation.m[15];
		
		result.x = rx / rw;
		result.y = ry / rw;
		result.z = rz / rw;
	}

	inline public static function TransformNormal(vector:Vector3, transformation:Matrix):Vector3 {
		var result = Vector3.Zero();
		
		Vector3.TransformNormalToRef(vector, transformation, result);
		
		return result;
	}

	inline public static function TransformNormalToRef(vector:Vector3, transformation:Matrix, result:Vector3) {
		var vx = vector.x;
		var vy = vector.y;
		var vz = vector.z;
		result.x = (vx * transformation.m[0]) + (vy * transformation.m[4]) + (vz * transformation.m[8]);
		result.y = (vx * transformation.m[1]) + (vy * transformation.m[5]) + (vz * transformation.m[9]);
		result.z = (vx * transformation.m[2]) + (vy * transformation.m[6]) + (vz * transformation.m[10]);
	}

	inline public static function TransformNormalFromFloatsToRef(x:Float, y:Float, z:Float, transformation:Matrix, result:Vector3) {
		result.x = (x * transformation.m[0]) + (y * transformation.m[4]) + (z * transformation.m[8]);
		result.y = (x * transformation.m[1]) + (y * transformation.m[5]) + (z * transformation.m[9]);
		result.z = (x * transformation.m[2]) + (y * transformation.m[6]) + (z * transformation.m[10]);
	}

	inline public static function CatmullRom(value1:Vector3, value2:Vector3, value3:Vector3, value4:Vector3, amount:Float):Vector3 {
		var squared = amount * amount;
		var cubed = amount * squared;
		
		var v1x = value1.x;
		var v2x = value2.x;
		var v3x = value3.x;
		var v4x = value4.x;
		
		var v1y = value1.y;
		var v2y = value2.y;
		var v3y = value3.y;
		var v4y = value4.y;
		
		var v1z = value1.z;
		var v2z = value2.z;
		var v3z = value3.z;
		var v4z = value4.z;
		
		var x = 0.5 * ((((2.0 * v2x) + ((-v1x + v3x) * amount)) +
			(((((2.0 * v1x) - (5.0 * v2x)) + (4.0 * v3x)) - v4x) * squared)) +
			(((( -v1x + (3.0 * v2x)) - (3.0 * v3x)) + v4x) * cubed));
			
		var y = 0.5 * ((((2.0 * v2y) + ((-v1y + v3y) * amount)) +
			(((((2.0 * v1y) - (5.0 * v2y)) + (4.0 * v3y)) - v4y) * squared)) +
			(((( -v1y + (3.0 * v2y)) - (3.0 * v3y)) + v4y) * cubed));
			
		var z = 0.5 * ((((2.0 * v2z) + ((-v1z + v3z) * amount)) +
			(((((2.0 * v1z) - (5.0 * v2z)) + (4.0 * v3z)) - v4z) * squared)) +
			(((( -v1z + (3.0 * v2z)) - (3.0 * v3z)) + v4z) * cubed));
			
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
	
	inline public static function UnprojectFromTransform(source:Vector3, viewportWidth:Float, viewportHeight:Float, world:Matrix, transform:Matrix):Vector3 {
		Tmp.matrix[0] = world.multiply(transform);
		Tmp.matrix[0].invert();
		source.x = source.x / viewportWidth * 2 - 1;
		source.y = -(source.y / viewportHeight * 2 - 1);
		var vector = Vector3.TransformCoordinates(source, Tmp.matrix[0]);
		var num = source.x * Tmp.matrix[0].m[3] + source.y * Tmp.matrix[0].m[7] + source.z * Tmp.matrix[0].m[11] + Tmp.matrix[0].m[15];
		
		if (Tools.WithinEpsilon(num, 1.0)) {
			vector = vector.scale(1.0 / num);
		}
		
		return vector;
	}

	inline public static function Unproject(source:Vector3, viewportWidth:Float, viewportHeight:Float, world:Matrix, view:Matrix, projection:Matrix):Vector3 {
		Tmp.matrix[0] = world.multiply(view).multiply(projection);
		Tmp.matrix[0].invert();
		var screenSource = new Vector3(source.x / viewportWidth * 2 - 1, -(source.y / viewportHeight * 2 - 1), source.z);
        var vector = Vector3.TransformCoordinates(screenSource, Tmp.matrix[0]);
        var num = screenSource.x * Tmp.matrix[0].m[3] + screenSource.y * Tmp.matrix[0].m[7] + screenSource.z * Tmp.matrix[0].m[11] + Tmp.matrix[0].m[15];
		
		if (Tools.WithinEpsilon(num, 1.0)) {
			vector = vector.scale(1.0 / num);
		}
		
		return vector;
	}

	inline public static function Minimize(left:Vector3, right:Vector3):Vector3 {
		var min = left.clone();
		min.MinimizeInPlace(right);
		
		return min;
	}

	inline public static function Maximize(left:Vector3, right:Vector3):Vector3 {
		var max = left.clone();
		max.MaximizeInPlace(right);
		
		return max;
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

	inline public static function Center(value1:Vector3, value2:Vector3):Vector3 {
		var center = value1.add(value2);
		center.scaleInPlace(0.5);
		
		return center;
	}
	
	/** 
	 * Given three orthogonal left-handed oriented Vector3 axis in space (target system), 
	 * RotationFromAxis() returns the rotation Euler angles (ex : rotation.x, rotation.y, rotation.z) to apply
	 * to something in order to rotate it from its local system to the given target system.
	 */
	public static function RotationFromAxis(axis1:Vector3, axis2:Vector3, axis3:Vector3):Vector3 {
		var rotation = Vector3.Zero();
		Vector3.RotationFromAxisToRef(axis1, axis2, axis3, rotation);
		
		return rotation;
	}
	
	/** 
	 * The same as RotationFromAxis but updates the passed ref Vector3 parameter.
	 */
	static var _tF:Vector<Float> = new Vector<Float>(4);
	public static function RotationFromAxisToRef(axis1:Vector3, axis2:Vector3, axis3:Vector3, ref:Vector3) {
		var u = Tmp.vector3[0];
		var w = Tmp.vector3[1];
		Vector3.NormalizeToRef(axis1, u);
		Vector3.NormalizeToRef(axis3, w);
		
		// equation unknowns and vars
		_tF[0] = 0.0;
		_tF[1] = 0.0;
		_tF[2] = 0.0;
		var sign = -1;
		var nbRevert = 0;
		var cross:Vector3 = Tmp.vector3[2];
		_tF[3] = 0.0;
		
		// step 1  : rotation around w
		// Rv3(u) = u1, and u1 belongs to plane xOz
		// Rv3(w) = w1 = w invariant
		var u1:Vector3 = Tmp.vector3[3];
		var v1:Vector3 = Tmp.vector3[4];
		if (Tools.WithinEpsilon(w.z, 0, Tools.Epsilon)) {
			_tF[1] = 1.0;
		}
		else if (Tools.WithinEpsilon(w.x, 0, Tools.Epsilon)) {
			_tF[0] = 1.0;
		}
		else {
			_tF[2] = w.z / w.x;
			_tF[0] = - _tF[2] * Math.sqrt(1 / (1 + _tF[2] * _tF[2]));
			_tF[1] = Math.sqrt(1 / (1 + _tF[2] * _tF[2]));
		}
		
		u1.set(_tF[0], 0, _tF[1]);
		u1.normalize();
		v1 = Vector3.Cross(w, u1);     // v1 image of v through rotation around w
		v1.normalize();
		cross = Vector3.Cross(u, u1);  // returns same direction as w (=local z) if positive angle : cross(source, image)
		cross.normalize();
		if (Vector3.Dot(w, cross) < 0) {
			sign = 1;
		}
		
		_tF[4] = Vector3.Dot(u, u1);
		_tF[4] = (Math.min(1.0, Math.max(-1.0, _tF[4]))); // to force dot to be in the range [-1, 1]
		ref.z = Math.acos(_tF[4]) * sign;
		
		if (Vector3.Dot(u1, Axis.X) < 0) { // checks X orientation
			ref.z = Math.PI + ref.z;
			u1 = u1.scaleInPlace(-1);
			v1 = v1.scaleInPlace(-1);
			nbRevert++;
		}
		
		// step 2 : rotate around u1
		// Ru1(w1) = Ru1(w) = w2, and w2 belongs to plane xOz
		// u1 is yet in xOz and invariant by Ru1, so after this step u1 and w2 will be in xOz
		var w2:Vector3 = Tmp.vector3[5];
		var v2:Vector3 = Tmp.vector3[6];
		_tF[0] = 0.0;
		_tF[1] = 0.0;
		sign = -1;
		if (Tools.WithinEpsilon(w.z, 0, Tools.Epsilon)) {
			_tF[0] = 1.0;
		}
		else {
			_tF[2] = u1.z / u1.x;
			_tF[0] = - _tF[2] * Math.sqrt(1 / (1 + _tF[2] * _tF[2]));
			_tF[1] = Math.sqrt(1 / (1 + _tF[2] * _tF[2]));
		}
		
		w2.set(_tF[0], 0, _tF[1]);
		w2.normalize();
		v2 = Vector3.Cross(w2, u1);   // v2 image of v1 through rotation around u1
		v2.normalize();
		cross = Vector3.Cross(w, w2); // returns same direction as u1 (=local x) if positive angle : cross(source, image)
		cross.normalize();
		if (Vector3.Dot(u1, cross) < 0) {
			sign = 1;
		}
		
		_tF[4] = Vector3.Dot(w, w2);
		_tF[4] = (Math.min(1.0, Math.max(-1.0, _tF[4]))); // to force dot to be in the range [-1, 1]
		ref.x = Math.acos(_tF[4]) * sign;
		if (Vector3.Dot(v2, Axis.Y) < 0) { // checks for Y orientation
			ref.x = Math.PI + ref.x;
			v2 = v2.scaleInPlace(-1);
			w2 = w2.scaleInPlace(-1);
			nbRevert++;
		}
		
		// step 3 : rotate around v2
		// Rv2(u1) = X, same as Rv2(w2) = Z, with X=(1,0,0) and Z=(0,0,1)
		sign = -1;
		cross = Vector3.Cross(Axis.X, u1); // returns same direction as Y if positive angle : cross(source, image)
		cross.normalize();
		if (Vector3.Dot(cross, Axis.Y) < 0) {
			sign = 1;
		}
		_tF[4] = Vector3.Dot(u1, Axis.X);
		_tF[4] = (Math.min(1.0, Math.max(-1.0, _tF[4]))); 	// to force dot to be in the range [-1, 1]
		ref.y = - Math.acos(_tF[4]) * sign;         		// negative : plane zOx oriented clockwise
		if (_tF[4] < 0 && nbRevert < 2) {
			ref.y = Math.PI + ref.y;
		}
	}
	
	/*public static function RotationFromAxisToRef(axis1:Vector3, axis2:Vector3, axis3:Vector3, ref:Vector3) {
		var u = Vector3.Normalize(axis1);
		var w = Vector3.Normalize(axis3);
		
		// world axis
		var X = Axis.X;
		var Y = Axis.Y;
		
		// equation unknowns and vars
		var yaw = 0.0;
		var pitch = 0.0;
		var roll = 0.0;
		var x = 0.0;
		var y = 0.0;
		var z = 0.0;
		var t = 0.0;
		var sign = -1.0;
		var nbRevert = 0;
		var cross:Vector3 = Tmp.vector3[0];
		var dot = 0.0;
		
		// step 1  : rotation around w
		// Rv3(u) = u1, and u1 belongs to plane xOz
		// Rv3(w) = w1 = w invariant
		var u1:Vector3 = Tmp.vector3[1];
		var v1:Vector3 = null;
		if (Tools.WithinEpsilon(w.z, 0, Tools.Epsilon)) {
			z = 1.0;
		}
		else if (Tools.WithinEpsilon(w.x, 0, Tools.Epsilon)) {
			x = 1.0;
		}
		else {
			t = w.z / w.x;
			x = - t * Math.sqrt(1 / (1 + t * t));
			z = Math.sqrt(1 / (1 + t * t));
		}
		
		u1 = new Vector3(x, y, z);
		u1.normalize();
		v1 = Vector3.Cross(w, u1);     // v1 image of v through rotation around w
		v1.normalize();
		cross = Vector3.Cross(u, u1);  // returns same direction as w (=local z) if positive angle : cross(source, image)
		cross.normalize();
		if (Vector3.Dot(w, cross) < 0) {
			sign = 1.0;
		}
		
		dot = Vector3.Dot(u, u1);
		dot = (Math.min(1.0, Math.max(-1.0, dot))); // to force dot to be in the range [-1, 1]
		roll = Math.acos(dot) * sign;
		
		if (Vector3.Dot(u1, X) < 0) { // checks X orientation
			roll = Math.PI + roll;
			u1 = u1.scaleInPlace(-1);
			v1 = v1.scaleInPlace(-1);
			nbRevert++;
		}
		
		// step 2 : rotate around u1
		// Ru1(w1) = Ru1(w) = w2, and w2 belongs to plane xOz
		// u1 is yet in xOz and invariant by Ru1, so after this step u1 and w2 will be in xOz
		var w2:Vector3 = Tmp.vector3[2];
		var v2:Vector3 = Tmp.vector3[3];
		x = 0.0;
		y = 0.0;
		z = 0.0;
		sign = -1;
		if (Tools.WithinEpsilon(w.z, 0, Tools.Epsilon)) {
			x = 1.0;
		}
		else {
			t = u1.z / u1.x;
			x = - t * Math.sqrt(1 / (1 + t * t));
			z = Math.sqrt(1 / (1 + t * t));
		}
		
		w2 = new Vector3(x, y, z);
		w2.normalize();
		v2 = Vector3.Cross(w2, u1);   // v2 image of v1 through rotation around u1
		v2.normalize();
		cross = Vector3.Cross(w, w2); // returns same direction as u1 (=local x) if positive angle : cross(source, image)
		cross.normalize();
		if (Vector3.Dot(u1, cross) < 0) {
			sign = 1.0;
		}
		
		dot = Vector3.Dot(w, w2);
		dot = (Math.min(1.0, Math.max(-1.0, dot))); // to force dot to be in the range [-1, 1]
		pitch = Math.acos(dot) * sign;
		if (Vector3.Dot(v2, Y) < 0) { // checks for Y orientation
			pitch = Math.PI + pitch;
			v2 = v2.scaleInPlace(-1);
			w2 = w2.scaleInPlace(-1);
			nbRevert++;
		}
		
		// step 3 : rotate around v2
		// Rv2(u1) = X, same as Rv2(w2) = Z, with X=(1,0,0) and Z=(0,0,1)
		sign = -1;
		cross = Vector3.Cross(X, u1); // returns same direction as Y if positive angle : cross(source, image)
		cross.normalize();
		if (Vector3.Dot(cross, Y) < 0) {
			sign = 1.0;
		}
		dot = Vector3.Dot(u1, X);
		dot = (Math.min(1.0, Math.max(-1.0, dot))); // to force dot to be in the range [-1, 1]
		yaw = - Math.acos(dot) * sign;         // negative : plane zOx oriented clockwise
		if (dot < 0 && nbRevert < 2) {
			yaw = Math.PI + yaw;
		}
		
		ref.x = pitch;
		ref.y = yaw;
		ref.z = roll;
	}*/
	
}
