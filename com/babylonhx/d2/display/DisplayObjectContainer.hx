package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Point;
import com.babylonhx.d2.geom.Rectangle;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DisplayObjectContainer extends InteractiveObject {
	
	private var _tempR:Rectangle;
	private var _children:Array<DisplayObject>;
	
	public var numChildren:Int;
	

	public function new() {
		super();
		
		this._tempR = new Rectangle();
		
		this.numChildren = 0;
		this._children = [];
	}
	
	override public function _getRect(tmat:Float32Array, torg:Float32Array, stks:Bool):Rectangle {
		var r = this._trect;  
		r.setEmpty();
		
		for (i in 0...this.numChildren) {
			var ch = this._children[i];  
			if (!ch.visible) {
				continue;
			}
			r._unionWith(ch._getRect(tmat, torg, stks));
		}
		
		return r;
	}
	
	override public function _htpLocal(org:Float32Array, p:Float32Array):Bool {
		var n = this._children.length;
		for (i in 0...n) {
			var ch = this._children[i];
			if (!ch.visible) {
				continue;
			}
			
			var corg = ch._tvec4_0;
			var cp = ch._tvec4_1;
			var im = ch.transform._getIMat();
			
			Point._m4_MultiplyVec4(im, org, corg);
			Point._m4_MultiplyVec4(im, p, cp);
			
			return ch._htpLocal(corg, cp);
		}
		
		return false;
	}
	
	
	/**
	 * Adds a child to the container
	 * 
	 * @param o	a chil object to be added
	 */
	public function addChild(o:DisplayObject) {
		this._children.push(o);
		o.parent = this;
		o._setStage(this.stage);
		++this.numChildren;
	}
	
	public function addChildAt(o:DisplayObject, index:Int) {
		if (index >= 0 && index <= this._children.length - 1) {
			this._children.insert(index, o);
			o.parent = this;
			o._setStage(this.stage);
			++this.numChildren;
		}
	}
	
	/**
	 * Removes a child from the container
	 * 
	 * @param o	a child object to be removed
	 */
	public function removeChild(o:DisplayObject) {
		var ind = this._children.indexOf(o);
		if (ind < 0) {
			return;
		}
		
		this._children.splice(ind, 1);
		o.parent = null;
		o._setStage(null);
		--this.numChildren;
	}
	
	public function removeChildAt(i:Int) {
		this.removeChild(this._children[i]);
	}
	
	/**
	 * Checks, if a container contains a certain child
	 * 
	 * @param o	an object for which we check, if it is contained or not
	 * @return	true if contains, false if not
	 */
	inline public function contains(o:DisplayObject):Bool {
		return (this._children.indexOf(o) >= 0);
	}
	
	inline public function getChildIndex(o:DisplayObject):Int {
		return this._children.indexOf(o);
	}
	
	/**
	 * Sets the child index in the current children list.
	 * Child index represents a "depth" - an order, in which children are rendered
	 * 
	 * @param c1	a child object
	 * @param i2	a new depth value
	 */
	public function setChildIndex(c1:DisplayObject, i2:Int) {
		var i1 = this._children.indexOf(c1);
		
		if (i2 > i1) {
			for (i in i1 + 1...i2 + 1) {
				this._children[i-1] = this._children[i];
			}
			this._children[i2] = c1;
		}
		else if (i2 < i1) {
			var i = i1 - 1;
			while (i >= i2) {
				this._children[i + 1] = this._children[i];
				--i;
			}
			this._children[i2] = c1;
		}
	}	
	
	/**
	 * Returns the child display object instance that exists at the specified index.
	 * 
	 * @param i	index (depth)
	 * @return	an object at this index
	 */
	inline public function getChildAt(i:Int):DisplayObject {
		return this._children[i];
	}	
	
	override public function _render() {
		for (i in 0...this.numChildren) {
			this._children[i]._renderAll();
		}
	}	
	
	override private function _getTarget(porg:Float32Array, pp:Float32Array):DisplayObject {	// parent origin, parent point
		if (!this.visible || (!this.mouseChildren && !this.mouseEnabled)) {
			return null;
		}
		
		var org = this._tvec4_0;
		var p   = this._tvec4_1;
		var im  = this.transform._getIMat();
		Point._m4_MultiplyVec4(im, porg, org);
		Point._m4_MultiplyVec4(im, pp, p);
		
		var topTGT:DisplayObject = null;
		var n = this.numChildren - 1;
		
		var i = n;
		while (i > -1) {			
			var ntg = this._children[i]._getTarget(org, p);
			if (ntg != null) {
				topTGT = ntg;  
				break; 
			}
			
			--i;
		}
		if (!this.mouseChildren && topTGT != null) {
			return this;
		}
		
		return topTGT;
	}
	
	/*
		Check, whether object hits pt[0], pt[1] in parent coordinate system
	*/
	
	override private function _setStage(st:Stage) {
		super._setStage(st);
		
		for (i in 0...this.numChildren) {
			this._children[i]._setStage(st);
		}
	}
	
}
