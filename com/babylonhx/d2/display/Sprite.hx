package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Point;
import com.babylonhx.d2.geom.Rectangle;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Sprite extends DisplayObjectContainer {
	
	private var _graphics:Graphics;
	public var graphics(get, set):Graphics;
	inline private function get_graphics():Graphics {
		return this._graphics;
	}
	inline private function set_graphics(g:Graphics):Graphics {
		return this._graphics = g;
	}
	
	private var _trect2:Rectangle;
	

	public function new() {
		super();
		
		this._trect2 = new Rectangle();
		
		this._graphics = new Graphics();
	}

	override private function _setStage(st:Stage) {
		super._setStage(st);

		this._graphics._stage = st;
	}
	
	override public function _getRect(tmat:Float32Array, torg:Float32Array, stks:Bool):Rectangle {
		var r1 = super._getRect(tmat, torg, stks);
		var r2 = this.graphics._getLocRect(stks);
		
		Point._m4_Multiply(tmat, this._getATMat(), this._tempm);
		this._transfRect(this._tempm, torg, r2, this._trect2);
		
		return r1.union(this._trect2);
	}	
	
	override public function _render() {
		this.graphics._render();
		super._render();
	}
	
	override private function _getTarget(porg:Float32Array, pp:Float32Array):DisplayObject {
		if (!this.visible || (!this.mouseChildren && !this.mouseEnabled)) {
			return null; 
		}
		
		var tgt = super._getTarget(porg, pp);
		if (tgt != null) {
			return tgt;
		}
		
		if (!this.mouseEnabled) {
			return null;
		}
		
		var org = this._tvec4_0;
		var p   = this._tvec4_1;
		var im = this.transform._getIMat();
		Point._m4_MultiplyVec4(im, porg, org);
		Point._m4_MultiplyVec4(im, pp, p);
		
		var pt = this._tempP;
		this._lineIsc(org, p, pt);
		
		if (this.graphics._hits(pt.x, pt.y)) {
			return this;
		}
		
		return null;
	}
	
	override public function _htpLocal(org:Float32Array, p:Float32Array):Bool {
		var tp = this._tempP;
		this._lineIsc(org, p, tp);
		
		if (this.graphics._hits(tp.x, tp.y)) {
			return true;
		}
		
		return super._htpLocal(org, p);
	}
	
}
