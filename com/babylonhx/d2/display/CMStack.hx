package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Point;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.typedarray.Float32Array;

#if (!js && !purejs)
import com.babylonhx.utils.GL in Gl;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

/*
	Color matrix stack
*/
class CMStack {

	public var mats:Array<Float32Array>;
	public var vecs:Array<Float32Array>;
	public var isID:Array<Bool>;
	
	public var bmds:Array<BlendMode>;
	public var lnnm:Array<Int>;
	
	public var size:Int;
	public var dirty:Bool;
	

	public function new() {
		this.mats = [];	//	linear transform matrix
		this.vecs = [];	//  affine shift column
		this.isID = []; //	is Identity
		
		this.bmds = []; //	blend modes
		this.lnnm = [];	//	last not NORMAL blend mode
		this.size = 1;
		this.dirty = true;	// if top matrix is different than shader value
		for (i in 0...30) {	
			this.mats.push(Point._m4_Create()); 
			this.vecs.push(new Float32Array(4)); 
			this.isID.push(true); 
			this.bmds.push(BlendMode.NORMAL); 
			this.lnnm.push(0); 
		}
	}
	
	public function push(m:Float32Array, v:Float32Array, id:Bool, bmd:BlendMode) {
		var s = this.size++;
		this.isID[s] = id;
		
		if(id) {
			Point._m4_Set(this.mats[s - 1], this.mats[s]);
			Point._v4_Set(this.vecs[s - 1], this.vecs[s]);
		}
		else {
			Point._m4_Multiply    (this.mats[s - 1], m, this.mats[s]);
			Point._m4_MultiplyVec4(this.mats[s - 1], v, this.vecs[s]);
			Point._v4_Add	      (this.vecs[s - 1], this.vecs[s], this.vecs[s]);
		}
		if (!id) {
			this.dirty = true;
		}
		
		this.bmds[s] = bmd;
		this.lnnm[s] = (bmd == BlendMode.NORMAL) ? this.lnnm[s - 1] : s;
	}
	
	public function update(st:Stage #if (js || purejs), Gl:js.html.webgl.RenderingContext #end) {
		if (this.dirty) {
			var s = this.size - 1;
			Gl.uniformMatrix4fv(st._sprg.cMatUniform, false, this.mats[s]);
			Gl.uniform4fv      (st._sprg.cVecUniform, this.vecs[s]);
			this.dirty = false;
		}
		
		var n = this.lnnm[this.size - 1];
		st._setBMD(this.bmds[n]);
	}
	
	public function pop() {
		if (!this.isID[this.size - 1]) {
			this.dirty = true;
		}
		this.size--;
	}
	
}
