package com.babylonhx.d2.geom;

import com.babylonhx.d2.display.DisplayObject;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A class for representing a 2D point
 * @author Ivan Kuckir
 */
class Transform {
	
	public var _obj:DisplayObject;
	
	public var _mdirty:Bool;		// matrix dirty
	public var _vdirty:Bool;		// values dirty
	
	public var _tmat:Float32Array;
	public var _imat:Float32Array;
	public var _atmat:Float32Array;
	public var _aimat:Float32Array;
	public var _pscal:Float32Array;
	
	public var _cmat:Float32Array;
	public var _cvec:Float32Array;
	public var _cID:Bool;
	
	public var _scaleX:Float;
	public var _scaleY:Float;
	public var _scaleZ:Float;
	public var _rotationX:Float;
	public var _rotationY:Float;
	public var _rotationZ:Float;

	
	public function new() {	
		this._obj			= null;
		
		this._mdirty		= false;		// matrix dirty
		this._vdirty		= false;		// values dirty
		
		this._tmat			= Point._m4_Create();
		this._imat			= Point._m4_Create();
		this._atmat			= Point._m4_Create();
		this._aimat			= Point._m4_Create();
		this._pscal			= Point._m4_Create();
		
		this._cmat			= Point._m4_Create();
		this._cvec			= Point._v4_Create();
		this._cID			= true;
		
		this._scaleX		= 1;
		this._scaleY		= 1;
		this._scaleZ		= 1;
		this._rotationX		= 0;
		this._rotationY		= 0;
		this._rotationZ		= 0;
	}
	
	inline public function _getTMat():Float32Array {
		var o = this._obj;
		var m = this._tmat;
		
		this._checkMat();
		
		m[12] = o.x;  
		m[13] = o.y;  
		m[14] = o.z;
		
		return m;
	}

	inline public function _getIMat():Float32Array {
		Point._m4_Inverse(this._getTMat(), this._imat); 
		
		return this._imat;
	}
	
	inline public function _postScale(sx:Float, sy:Float) {
		this._checkMat();
		
		var ps = this._pscal;
		ps[10] = ps[15] = 1;
		ps[0] = sx;  
		ps[5] = sy;
		
		Point._m4_Multiply(ps, this._tmat, this._tmat);
		this._vdirty = true;
	}

	public function _valsToMat() {
		var m = this._tmat;
		
		var sx = this._scaleX;
		var sy = this._scaleY;
		var sz = this._scaleZ;
		
		var r = -0.01745329252;
		var a =  this._rotationX * r;	// alpha
		var b =  this._rotationY * r;	// beta
		var g =  this._rotationZ * r;	// gama
		
		var ca = Math.cos(a), cb = Math.cos(b), cg = Math.cos(g);
		var sa = Math.sin(a), sb = Math.sin(b), sg = Math.sin(g);
		
		m[0] = cb * cg * sx;			
		m[1] = -cb * sg * sx;				
		m[2] = sb * sx;
		m[4] = (ca * sg + sa * sb * cg) * sy;	
		m[5] = (ca * cg - sa * sb * sg) * sy;		
		m[6] = -sa * cb * sy;
		m[8] = (sa * sg - ca * sb * cg) * sz;	
		m[9] = (sa * cg + ca * sb * sg) * sz;		
		m[10] = ca * cb * sz;
	}
	
	public function _matToVals() {
		var a = this._tmat;
		
		var a00 = a[0], a01 = a[1], a02 = a[2 ], 
			a10 = a[4], a11 = a[5], a12 = a[6 ],
			a20 = a[8], a21 = a[9], a22 = a[10];
		
		this._scaleX = Math.sqrt(a00 * a00 + a01 * a01 + a02 * a02);
		this._scaleY = Math.sqrt(a10 * a10 + a11 * a11 + a12 * a12);
		this._scaleZ = Math.sqrt(a20 * a20 + a21 * a21 + a22 * a22);
		
		var isX = 1 / this._scaleX;
		var isY = 1 / this._scaleY;
		var isZ = 1 / this._scaleZ;
		
		a00 *= isX;  a01 *= isX;  a02 *= isX;
		a10 *= isY;  a11 *= isY;  a12 *= isY;
		a20 *= isZ;  a21 *= isZ;  a22 *= isZ;
		
		var r = -57.29577951308;
		this._rotationX = r * Math.atan2( -a12, a22);
		this._rotationY = r * Math.atan2(a02, Math.sqrt(a12 * a12 + a22 * a22));
		this._rotationZ = r * Math.atan2( -a01, a00);
	}
	
	inline public function _checkVals() { 
		if (this._vdirty) {
			this._matToVals(); 
			this._vdirty = false;
		} 
	}
	
	inline public function _checkMat() { 
		if (this._mdirty) {
			this._valsToMat(); 
			this._mdirty = false;
		} 
	}
	
	inline public function _setOPos() {
		var m = this._tmat;
		this._obj.x = m[12];  
		this._obj.y = m[13];  
		this._obj.z = m[14];
	}
	
	inline public function _checkColorID() {
		var m = this._cmat;
		var v = this._cvec;
		this._cID = m[15] == 1 &&
					m[0 ] == 1 && m[1 ] == 0 && m[2 ] == 0 && m[3 ] == 0 &&
					m[4 ] == 0 && m[5 ] == 1 && m[6 ] == 0 && m[7 ] == 0 && 
					m[8 ] == 0 && m[9 ] == 0 && m[10] == 1 && m[11] == 0 && 
					m[12] == 0 && m[13] == 0 && m[14] == 0 && m[15] == 1 && 
					v[0 ] == 0 && v[1 ] == 0 && v[2 ] == 0 && v[3 ] == 0;
	}
	
	inline public function _setMat3(m3:Float32Array) { 
		var m4 = this._tmat; 
		m4[0] = m3[0]; 
		m4[1] = m3[1]; 
		m4[4] = m3[3]; 
		m4[5] = m3[4]; 
		m4[12] = m3[6]; 
		m4[13] = m3[7];
	}
	
	inline public function _getMat3(m3:Float32Array) { 
		var m4 = this._tmat; 
		m3[0] = m4[0]; 
		m3[1] = m4[1]; 
		m3[3] = m4[4]; 
		m3[4] = m4[5]; 
		m3[6] = m4[12]; 
		m3[7] = m4[13];
	}
	
	inline public function _setCMat5(m5:Float32Array) { 
		var m4 = this._cmat;
		var v4 = this._cvec;           
		for (i in 0...4) { 
			v4[i] = m5[20 + i];  
			for (j in 0...4) {
				m4[4 * i + j] = m5[5 * i + j];
			}
		} 
	}
	
	inline public function _getCMat5(m5:Float32Array) { 
		var m4 = this._cmat;
		var v4 = this._cvec; 
		m5[24] = 1; 
		for (i in 0...4) { 
			m5[20 + i] = v4[i];  
			for (j in 0...4) {
				m5[5 * i + j] = m4[4 * i + j]; 
				
			} 			
		}
	}	
	
	public var matrix(get, set):Float32Array;
	inline private function set_matrix(m:Float32Array):Float32Array { 
		this._checkMat(); 
		this._setMat3(m); 
		this._setOPos(); 
		this._vdirty = true; 
		
		return m;
	}
	inline private function get_matrix():Float32Array { 
		this._checkMat(); 
		var m = new Float32Array(9); 
		this._getMat3(m);
		
		return m; 
	}
	
	public var matrix3D(get, set):Float32Array;
	inline private function set_matrix3D(m:Float32Array):Float32Array { 
		this._checkMat(); 
		Point._m4_Set(m, this._tmat); 
		this._setOPos(); 
		this._vdirty = true; 
		
		return m;
	}
	inline private function get_matrix3D():Float32Array { 
		this._checkMat(); 
		return Point._m4_Create(this._getTMat()); 
	}
	
	public var colorTransform(get, set):Float32Array;
	inline private function set_colorTransform(m:Float32Array):Float32Array { 
		this._setCMat5(m); 
		this._checkColorID(); 
		
		return m;
	}
	inline private function get_colorTransform():Float32Array { 
		var m = new Float32Array(25); 
		this._getCMat5(m); 
		
		return m; 
	}
	
}
