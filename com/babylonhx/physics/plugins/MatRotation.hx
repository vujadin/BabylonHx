package com.babylonhx.physics.plugins;

import oimo.math.Mat33;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MatRotation {

	public static function EulerToAxis(ox:Float, oy:Float, oz:Float):Array<Float> {	// angles in radians
		var c1 = Math.cos(oy * 0.5);	//heading
		var s1 = Math.sin(oy * 0.5);
		var c2 = Math.cos(oz * 0.5);	//altitude
		var s2 = Math.sin(oz * 0.5);
		var c3 = Math.cos(ox * 0.5);	//bank
		var s3 = Math.sin(ox * 0.5);
		var c1c2 = c1 * c2;
		var s1s2 = s1 * s2;
		var w = c1c2 * c3 - s1s2 * s3;
		var x = c1c2 * s3 + s1s2 * c3;
		var y = s1 * c2 * c3 + c1 * s2 * s3;
		var z = c1 * s2 * c3 - s1 * c2 * s3;
		var angle = 2 * Math.acos(w);
		var norm = x * x + y * y + z * z;
		if (norm < 0.001) {
			x = 1;
			y = z = 0;
		} else {
			norm = Math.sqrt(norm);
			x /= norm;
			y /= norm;
			z /= norm;
		}
		return [angle, x, y, z];
	}

	public static function EulerToMatrix(ox:Float, oy:Float, oz:Float):Mat33 {	// angles in radians
		var ch = Math.cos(oy);	//heading
		var sh = Math.sin(oy);
		var ca = Math.cos(oz);	//altitude
		var sa = Math.sin(oz);
		var cb = Math.cos(ox);	//bank
		var sb = Math.sin(ox);
		var mtx = new Mat33();
		
		mtx.e00 = ch * ca;
		mtx.e01 = sh * sb - ch * sa * cb;
		mtx.e02 = ch * sa * sb + sh * cb;
		mtx.e10= sa;
		mtx.e11 = ca * cb;
		mtx.e12 = -ca * sb;
		mtx.e20 = -sh * ca;
		mtx.e21 = sh * sa * cb + ch * sb;
		mtx.e22 = -sh * sa * sb + ch * cb;
		return mtx;
	}

	public static function MatrixToEuler(mtx:Mat33):Array<Float> {		// angles in radians
		var x:Float = 0;
		var y:Float = 0;
		var z:Float = 0;
		
		if (mtx.e10 > 0.998) { 	// singularity at north pole
			y = Math.atan2(mtx.e02, mtx.e22);
			z = Math.PI / 2;
			x = 0;
		} else if (mtx.e10 < -0.998) { 	// singularity at south pole
			y = Math.atan2(mtx.e10, mtx.e22);
			z = -Math.PI / 2;
			x = 0;
		} else {
			y = Math.atan2(-mtx.e20, mtx.e00);
			x = Math.atan2(-mtx.e12, mtx.e11);
			z = Math.asin(mtx.e10);
		}
		return [x, y, z];
	}

	public static function unwrapDegrees(r:Float):Float {
		r = r % 360;
		if (r > 180) {
			r -= 360;
		}
		if (r < -180) {
			r += 360;
		}
		return r;
	}

	public static function unwrapRadian(r:Float):Float {
		r = r % (Math.PI * 2);
		if (r > Math.PI) {
			r -= (Math.PI * 2);
		}
		if (r < -Math.PI) {
			r += (Math.PI * 2);
		}
		return r;
	}
	
}
