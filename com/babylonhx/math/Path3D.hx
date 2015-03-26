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
	

	public function new(path:Array<Vector3>) {
		this._curve = path.copy();   // copy array  
		this._compute(); 
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
	
	public function update(path:Array<Vector3>):Path3D {
		for(i in 0...path.length) {
			this._curve[i] = path[i];
		}
		this._compute();
		return this;
	}
	
	// private function compute() : computes tangents, normals and binormals
	private function _compute() {
		var l = this._curve.length;
		
		// first and last tangents
		this._tangents[0] = this._curve[1].subtract(this._curve[0]);
		this._tangents[0].normalize();
		this._tangents[l - 1] = this._curve[l - 1].subtract(this._curve[l - 2]);
		this._tangents[l - 1].normalize();
		
		// normals and binormals at first point : arbitrary vector with _normalVector()
		var tg0 = this._tangents[0];
		var pp0 = this._normalVector(this._curve[0], tg0);
		this._normals[0] = pp0;
		this._normals[0].normalize();
		this._binormals[0] = Vector3.Cross(tg0, this._normals[0]);
		this._normals[0].normalize();
		this._distances[0] = 0;
		
		// normals and binormals : next points
		var prev:Vector3 = Vector3.Zero();        // previous vector (segment)
		var cur:Vector3 = Vector3.Zero();         // current vector (segment)
		var curTang:Vector3 = Vector3.Zero();     // current tangent
		var prevNorm:Vector3 = Vector3.Zero();    // previous normal
		var prevBinor:Vector3 = Vector3.Zero();   // previous binormal
		
		for (i in 1...l) {
			// tangents
			prev = this._curve[i].subtract(this._curve[i - 1]);
			if (i < l - 1) {
				cur = this._curve[i + 1].subtract(this._curve[i]);
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
			this._normals[i].normalize();
			this._binormals[i] = Vector3.Cross(curTang, this._normals[i]);
			this._binormals[i].normalize();
		}
	}

	// private function normalVector(v0, vt) :
	// returns an arbitrary point in the plane defined by the point v0 and the vector vt orthogonal to this plane
	private function _normalVector(v0:Vector3, vt:Vector3):Vector3 {
		var point:Vector3 = Vector3.Zero(); 
		if (vt.x != 1) {     // search for a point in the plane
			point = new Vector3(1, 0, 0);   
		}
		else if (vt.y != 1) {
			point = new Vector3(0, 1, 0);  
		}
		else if (vt.z != 1) {
			point = new Vector3(0, 0, 1);  
		}
		var normal0:Vector3 = Vector3.Cross(vt, point);
		normal0.normalize();
		return normal0;        
	}
	
}
	