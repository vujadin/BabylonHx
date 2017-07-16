package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Path3D') class Path3D {
	
	public var path:Array<Vector3>;
	
	private var _curve:Array<Vector3> = [];
	private var _distances:Array<Float> = [];
	private var _tangents:Array<Vector3> = [];
	private var _normals:Array<Vector3> = [];
	private var _binormals:Array<Vector3> = [];
	private var _raw:Bool = false;
	

	/** 
    * new Path3D(path, normal, raw) 
    * path : an array of Vector3, the curve axis of the Path3D
    * normal (optional) : Vector3, the first wanted normal to the curve. Ex (0, 1, 0) for a vertical normal.
    * raw (optional, default false) : boolean, if true the returned Path3D isn't normalized. Useful to depict path acceleration or speed.
    */
	public function new(path:Array<Vector3>, ?firstNormal:Vector3, ?raw:Bool = false) {
		for (p in 0...path.length) {
            this._curve[p] = path[p].clone(); // hard copy
        }  
		this._raw = raw;
		this._compute(firstNormal); 
	}

	public function getCurve():Array<Vector3> {
		return this._curve;
	}

	public function getTangents():Array<Vector3> {
		return this._tangents;
	}

	public function getNormals():Array<Vector3> {
		return this._normals;
	}

	public function getBinormals():Array<Vector3> {
		return this._binormals;
	}

	public function getDistances():Array<Float> {
		return this._distances;
	}
	
	public function update(path:Array<Vector3>, ?firstNormal:Vector3):Path3D {
		for(p in 0...path.length) {
			this._curve[p].x = path[p].x;
			this._curve[p].y = path[p].y;
			this._curve[p].z = path[p].z;
		}
		this._compute(firstNormal);
		return this;
	}
	
	// private function compute() : computes tangents, normals and binormals
	private function _compute(?firstNormal:Vector3) {
		var l = this._curve.length;
		
		// first and last tangents
		this._tangents[0] = this._getFirstNonNullVector(0);
		if (!this._raw) {
			this._tangents[0].normalize();
		}
		this._tangents[l - 1] = this._curve[l - 1].subtract(this._curve[l - 2]);
		if (!this._raw) {
			this._tangents[l - 1].normalize();
		}
		
		// normals and binormals at first point : arbitrary vector with _normalVector()
		var tg0 = this._tangents[0];
		var pp0 = this._normalVector(this._curve[0], tg0, firstNormal);
		this._normals[0] = pp0;
		if (!this._raw) {
			this._normals[0].normalize();
		}
		this._binormals[0] = Vector3.Cross(tg0, this._normals[0]);
		if (!this._raw) {
			this._binormals[0].normalize();
		}
		this._distances[0] = 0;
		
		// normals and binormals : next points
		var prev:Vector3 = Vector3.Zero();        // previous vector (segment)
		var cur:Vector3 = Vector3.Zero();         // current vector (segment)
		var curTang:Vector3 = Vector3.Zero();     // current tangent
		var prevNorm:Vector3 = Vector3.Zero();    // previous normal
		var prevBinor:Vector3 = Vector3.Zero();   // previous binormal
		
		for (i in 1...l) {
			// tangents
			prev = this._getLastNonNullVector(i);
			if (i < l - 1) {
				cur = this._getFirstNonNullVector(i);
				this._tangents[i] = prev.add(cur);
				this._tangents[i].normalize();
			}
			this._distances[i] = this._distances[i - 1] + prev.length();   
				  
			// normals and binormals
			// http://www.cs.cmu.edu/afs/andrew/scs/cs/15-462/web/old/asst2camera.html
			curTang = this._tangents[i];
			prevNorm = this._normals[i - 1];
			prevBinor = this._binormals[i - 1];
			this._normals[i] = Vector3.Cross(prevBinor, curTang);
			if (!this._raw) {
				this._normals[i].normalize();
			}
			this._binormals[i] = Vector3.Cross(curTang, this._normals[i]);
			if (!this._raw) {
				this._binormals[i].normalize();
			}
		}
	}

	// private function getFirstNonNullVector(index)
	// returns the first non null vector from index : curve[index + N].subtract(curve[index])
	private function _getFirstNonNullVector(index:Int):Vector3 {
		var i = 1;
		var nNVector:Vector3 = this._curve[index + i].subtract(this._curve[index]);
		while (nNVector.length() == 0 && index + i + 1 < this._curve.length) {
			i++;
			nNVector = this._curve[index + i].subtract(this._curve[index]);
		}
		return nNVector;
	}

	// private function getLastNonNullVector(index)
	// returns the last non null vector from index : curve[index].subtract(curve[index - N])
	private function _getLastNonNullVector(index:Int):Vector3 {
		var i = 1;
		var nLVector: Vector3 = this._curve[index].subtract(this._curve[index - i]);
		while (nLVector.length() == 0 && index > i + 1) {
			i++;
			nLVector = this._curve[index].subtract(this._curve[index - i]);
		}
		return nLVector;
	}

	// private function normalVector(v0, vt, va) :
	// returns an arbitrary point in the plane defined by the point v0 and the vector vt orthogonal to this plane
	// if va is passed, it returns the va projection on the plane orthogonal to vt at the point v0
	private function _normalVector(v0:Vector3, vt:Vector3, va:Vector3 = null):Vector3 {
		var normal0:Vector3 = Vector3.Zero();
		if (va == null) {
			var point:Vector3 = Vector3.Zero();
			if (!Tools.WithinEpsilon(vt.y, 1, Tools.Epsilon)) {     // search for a point in the plane
				point = new Vector3(0, -1, 0);
			}
			else if (!Tools.WithinEpsilon(vt.x, 1, Tools.Epsilon)) {
				point = new Vector3(1, 0, 0);
			}
			else if (!Tools.WithinEpsilon(vt.z, 1, Tools.Epsilon)) {
				point = new Vector3(0, 0, 1);
			}
			normal0 = Vector3.Cross(vt, point);
		}
		else {
			normal0 = Vector3.Cross(vt, va);
			Vector3.CrossToRef(normal0, vt, normal0);
			//normal0 = Vector3.Cross(normal0, vt);
		}
		normal0.normalize();       
		return normal0;
	}
	
}
	