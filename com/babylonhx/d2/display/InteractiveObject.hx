package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Point;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class InteractiveObject extends DisplayObject {
	
	public var buttonMode:Bool;
	public var mouseEnabled:Bool;
	public var mouseChildren:Bool;
	

	public function new() {
		super();
		
		this.buttonMode = false;
		this.mouseEnabled = true;
		this.mouseChildren = true;
	}	
	
	override private function _getTarget(porg:Float32Array, pp:Float32Array):DisplayObject {
		if (!this.visible || !this.mouseEnabled) {
			return null;
		}
		
		var r = this._getLocRect();
		if (r == null) {
			return null;
		}
		
		var org = this._tvec4_0;
		var p   = this._tvec4_1;
		Point._m4_MultiplyVec4(this.transform._getIMat(), porg, org);
		Point._m4_MultiplyVec4(this.transform._getIMat(), pp, p);
		
		var pt = this._tempP;
		this._lineIsc(org, p, pt);
		
		if (r.contains(pt.x, pt.y)) {
			return this;
		}
		
		return null;
	}
	
}
