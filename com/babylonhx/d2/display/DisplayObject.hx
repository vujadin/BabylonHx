package com.babylonhx.d2.display;

import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.EventDispatcher;
import com.babylonhx.d2.geom.Point;
import com.babylonhx.d2.geom.Rectangle;
import com.babylonhx.d2.geom.Transform;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/** 
 * A basic class in the Display API
 * 
 * @author Ivan Kuckir
 * @version 1.0
 */
class DisplayObject extends EventDispatcher {
	
	private static var _tdo:DisplayObject;
	

	public var visible:Bool;
	
	public var parent:DisplayObjectContainer;
	public var stage:Stage;
	
	public var transform:Transform;
	
	public var blendMode:BlendMode;
	
	//public var x(get, set):Float;
	//public var y(get, set):Float;
	//public var z(get, set):Float;
	
	private var _trect:Rectangle;
	
	private var _tempP:Point;
	private var _torg:Float32Array;
	private var _tvec4_0:Float32Array;
	private var _tvec4_1:Float32Array;
	
	private var _tempm:Float32Array;
	
	private var _atsEv:Event;
	private var _rfsEv:Event;
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	
	public function new() {		
		super();
		
		this.visible	= true;
		
		this.parent		= null;
		this.stage		= null;
		
		this.transform	= new Transform();
		this.transform._obj = this;
		
		this.blendMode	= BlendMode.NORMAL;
		
		//*
		//	for fast access
		this.x			= 0;
		this.y			= 0;
		this.z			= 0;
		//*/
		
		this._trect		= new Rectangle();	// temporary rectangle
		
		this._tempP     = new Point();
		this._torg		= Point._v4_Create();
		this._tvec4_0	= Point._v4_Create();
		this._tvec4_1	= Point._v4_Create();
		
		this._tempm		= Point._m4_Create();
		
		this._atsEv	= new Event(Event.ADDED_TO_STAGE);
		this._rfsEv	= new Event(Event.REMOVED_FROM_STAGE);
		this._atsEv.target = this._rfsEv.target = this;
	}
	
	override public function dispatchEvent(e:Event) {	// : returns the deepest active InteractiveObject of subtree
		super.dispatchEvent(e);
		
		if (e.bubbles && this.parent != null) {
			this.parent.dispatchEvent(e);
		}
	}
	
	private function _globalToLocal(sp:Point, tp:Point)	{ 
		var org = this._torg;
		Stage._main._getOrigin(org);
		Point._m4_MultiplyVec4(this._getAIMat(), org, org);
		
		var p1 = this._tvec4_1;
		p1[0] = sp.x;  
		p1[1] = sp.y;  
		p1[2] = 0;  
		p1[3] = 1;
		Point._m4_MultiplyVec4(this._getAIMat(), p1, p1);
		
		this._lineIsc(org, p1, tp);
	}
	
	public function globalToLocal(p:Point):Point {	
		var lp = new Point();
		this._globalToLocal(p, lp);
		
		return lp;
	}
	
	public function localToGlobal(p:Point):Point {	
		var org = this._torg;
		Stage._main._getOrigin(org);
		
		var p1 = this._tvec4_1;
		p1[0] = p.x;  
		p1[1] = p.y;  
		p1[2] = 0;  
		p1[3] = 1;
		Point._m4_MultiplyVec4(this._getATMat(), p1, p1);
		
		var lp = new Point();
		this._lineIsc(org, p1, lp);
		
		return lp;
	}
	
	// Intersection between line p0, p1 and plane z=0  (result has z==0)
	
	public function _lineIsc(p0:Float32Array, p1:Float32Array, tp:Point) {
		var dx = p1[0] - p0[0];
		var dy = p1[1] - p0[1];
		var dz = p1[2] - p0[2];
		
		var len = Math.sqrt(dx * dx + dy * dy + dz * dz);
		dx /= len; 
		dy /= len; 
		dz /= len; 
		
		var d = -p0[2] / dz;
		tp.x = p0[0] + d * dx;
		tp.y = p0[1] + d * dy;
	}
	
	public function _transfRect(mat:Float32Array, torg:Float32Array, srct:Rectangle, trct:Rectangle) {
		var sp = this._tvec4_0;
		var tp = this._tvec4_1;
		var p = new Point();
		var minx = Math.POSITIVE_INFINITY;
		var miny = Math.POSITIVE_INFINITY;
		var maxx = Math.NEGATIVE_INFINITY;
		var maxy = Math.NEGATIVE_INFINITY;
		
		sp[0] = srct.x;  
		sp[1] = srct.y;  
		sp[2] = 0; 
		sp[3] = 1;		
		Point._m4_MultiplyVec4(mat, sp, tp);
		this._lineIsc(torg, tp, p);
		minx = Math.min(minx, p.x);  
		miny = Math.min(miny, p.y);
		maxx = Math.max(maxx, p.x);  
		maxy = Math.max(maxy, p.y);
		
		sp[0] = srct.x + srct.width;
		sp[1] = srct.y;  
		sp[2] = 0; 
		sp[3] = 1;		
		Point._m4_MultiplyVec4(mat, sp, tp);
		this._lineIsc(torg, tp, p);
		minx = Math.min(minx, p.x);  
		miny = Math.min(miny, p.y);
		maxx = Math.max(maxx, p.x);  
		maxy = Math.max(maxy, p.y);
		
		sp[0] = srct.x;  
		sp[1] = srct.y + srct.height;  
		sp[2] = 0; 
		sp[3] = 1;		
		Point._m4_MultiplyVec4(mat, sp, tp);
		this._lineIsc(torg, tp, p);
		minx = Math.min(minx, p.x);  
		miny = Math.min(miny, p.y);
		maxx = Math.max(maxx, p.x);  
		maxy = Math.max(maxy, p.y);
		
		sp[0] = srct.x + srct.width;  
		sp[1] = srct.y + srct.height;  
		sp[2] = 0; 
		sp[3] = 1;		
		Point._m4_MultiplyVec4(mat, sp, tp);
		this._lineIsc(torg, tp, p);
		minx = Math.min(minx, p.x);  
		miny = Math.min(miny, p.y);
		maxx = Math.max(maxx, p.x);  
		maxy = Math.max(maxy, p.y);
		
		trct.x = minx;  
		trct.y = miny; 
		trct.width = maxx - minx;  
		trct.height = maxy-miny;
	}
	
	private function _getLocRect():Rectangle {
		return null;
	}
	
	//  Returns bounding rectangle
	// 		tmat : matrix from global to target local
	// 		torg : origin in tmat coordinates
	//		result: read-only
	
	private function _getRect(tmat:Float32Array, torg:Float32Array, stks:Bool):Rectangle {
		Point._m4_Multiply(tmat, this._getATMat(), this._tempm);
		this._transfRect(this._tempm, torg, this._getLocRect(), this._trect);
		
		return this._trect;
	}
	
	private function _getR(tcs:DisplayObject, stks:Bool):Rectangle {
		Stage._main._getOrigin(this._torg);
		Point._m4_MultiplyVec4(tcs._getAIMat(), this._torg, this._torg);
		
		return this._getRect(tcs._getAIMat(), this._torg, stks);
	}
	
	private function _getParR(tcs:DisplayObject, stks:Bool):Rectangle {
		if (DisplayObject._tdo == null) {
			DisplayObject._tdo = new DisplayObject();
		}
		var nopar = this.parent == null;
		if (nopar) {
			this.parent = cast DisplayObject._tdo;
		}
		var out = this._getR(this.parent, stks);
		if (nopar) {
			this.parent = null;
		}
		
		return out;
	}
	
	// no strokes
	private function getRect(tcs:DisplayObject):Rectangle {  
		return this._getR(tcs, false).clone();  
	}
	
	// with strokes
	public function getBounds(tcs:DisplayObject):Rectangle {  
		return this._getR(tcs, true ).clone();  
	}	
	
	//  Check, whether object hits a line org, p in local coordinate system
	
	private function _htpLocal(org:Float32Array, p:Float32Array):Bool {
		var tp = this._tempP;
		this._lineIsc(org, p, tp);
		
		return this._getLocRect().contains(tp.x, tp.y);
	}
	
	//  tests, if object intersects a point in Stage coordinates
	
	public function hitTestPoint(x:Float, y:Float, shapeFlag:Bool = false) {		
		var org = this._torg;
		Stage._main._getOrigin(org);
		Point._m4_MultiplyVec4(this._getAIMat(), org, org);
		
		var p1 = this._tvec4_1;
		p1[0] = x;  
		p1[1] = y;  
		p1[2] = 0;  
		p1[3] = 1;
		Point._m4_MultiplyVec4(this._getAIMat(), p1, p1);
		
		//  org and p1 are in local coordinates
		//  now we have to decide, if line (p0, p1) intersects an object
		
		if (shapeFlag) {
			return this._htpLocal(org, p1);
		}
		else {
            return this._getR(Stage._main, false).contains(x, y);
		}
	}
	
	inline public function hitTestObject(obj:DisplayObject):Bool {
		var r0 = this._getR(Stage._main, false);
		var r1 = obj ._getR(Stage._main, false);
		
		return r0.intersects(r1);
	}
	
	private function _loseFocus() {
		
	}	
	
	/*
		Returns the deepest InteractiveObject of subtree with mouseEnabled = true  OR itself, if "hit over" and mouseEnabled = false
	*/	
	private function _getTarget(porg:Float32Array, pp:Float32Array):DisplayObject {
		return null;
	}
	
	private function _setStage(st:Stage) {
		var pst = this.stage;	// previous stage
		this.stage = st;
		if (pst == null && st != null) {
			this.dispatchEvent(this._atsEv);
		}
		if (pst != null && st == null) {
			this.dispatchEvent(this._rfsEv);
		}
	}
	
	/** 
	 * This method adds a drawing matrix onto the OpenGL stack
	 */
	inline private function _preRender(st:Stage) {
		var m = this.transform._getTMat();
		st._mstack.push(m);
		st._cmstack.push(this.transform._cmat, this.transform._cvec, this.transform._cID, this.blendMode);
	}	
	
	/** 
	 * This method renders the current content
	 */
	public function _render(st:Stage) {
		
	}
	
	/** 
	 * This method renders the whole object
	 */
	private function _renderAll(st:Stage) {
		if (!this.visible) {
			return;
		}
		
		this._preRender(st);
		this._render(st);
		st._mstack.pop();
		st._cmstack.pop();
	}
	
	/*
		Absolute Transform matrix
	*/
	private function _getATMat():Float32Array {
		if (this.parent == null) {
			return this.transform._getTMat();
		}
		Point._m4_Multiply(this.parent._getATMat(), this.transform._getTMat(), this.transform._atmat);
		
		return this.transform._atmat;
	}
	
	/*
		Absolute Inverse Transform matrix
	*/
	private function _getAIMat():Float32Array {
		if (this.parent == null) {
			return this.transform._getIMat();
		}
		
		Point._m4_Multiply(this.transform._getIMat(), this.parent._getAIMat(), this.transform._aimat);
		
		return this.transform._aimat;
	}
	
	inline private function _getMouse():Point {
		var lp = this._tempP;
		lp.setTo(this.stage._mouseX, this.stage._mouseY);
		this._globalToLocal(lp, lp);
		
		return lp;
	}	
	
	/*
	dp.ds("x", function(x){this.transform._tmat[12] = x; this.transform._imat[12] = -x;});
	dp.ds("y", function(y){this.transform._tmat[13] = y; this.transform._imat[13] = -y;});
	dp.ds("z", function(z){this.transform._tmat[14] = z; this.transform._imat[14] = -z;});
	dp.dg("x", function( ){return this.transform._tmat[12];});
	dp.dg("y", function( ){return this.transform._tmat[13];});
	dp.dg("z", function( ){return this.transform._tmat[14];});
	//*/
	
	public var scaleX(get, set):Float;
	inline private function set_scaleX(sx:Float):Float { 
		this.transform._checkVals(); 
		this.transform._scaleX = sx; 
		this.transform._mdirty = true;
		
		return sx;
	}
	inline private function get_scaleX():Float {
		this.transform._checkVals(); 
		
		return this.transform._scaleX;
	}
	
	public var scaleY(get, set):Float;
	inline private function set_scaleY(sy:Float):Float {
		this.transform._checkVals(); 
		this.transform._scaleY = sy; 
		this.transform._mdirty = true;
		
		return sy;
	}
	inline private function get_scaleY():Float {
		this.transform._checkVals(); 
		
		return this.transform._scaleY;
	}
	
	public var scaleZ(get, set):Float;
	inline private function set_scaleZ(sz:Float):Float {
		this.transform._checkVals(); 
		this.transform._scaleZ = sz; 
		this.transform._mdirty = true;
		
		return sz;
	}
	inline private function get_scaleZ():Float {
		this.transform._checkVals(); 
		
		return this.transform._scaleZ;
	}
	
	public var rotationX(get, set):Float;
	inline private function set_rotationX(r:Float):Float {
		this.transform._checkVals(); 
		this.transform._rotationX = r; 
		this.transform._mdirty = true;
		
		return r;
	}
	inline private function get_rotationX():Float {
		this.transform._checkVals(); 
		
		return this.transform._rotationX;
	}
	
	public var rotationY(get, set):Float;
	inline private function set_rotationY(r:Float):Float {
		this.transform._checkVals(); 
		this.transform._rotationY = r; 
		this.transform._mdirty = true;
		
		return r;
	}
	inline private function get_rotationY():Float {
		this.transform._checkVals(); 
		
		return this.transform._rotationY;
	}
	
	public var rotationZ(get, set):Float;
	inline private function set_rotationZ(r:Float):Float {
		this.transform._checkVals(); 
		this.transform._rotationZ = r; 
		this.transform._mdirty = true;
		
		return r;
	}
	inline private function get_rotationZ():Float { 
		this.transform._checkVals(); 
		
		return this.transform._rotationZ;
	}
	
	public var rotation(get, set):Float;
	inline private function set_rotation(r:Float):Float { 
		this.transform._checkVals(); 
		this.transform._rotationZ = r; 
		this.transform._mdirty = true;
		
		return r;
	}
	inline private function get_rotation():Float {
		this.transform._checkVals(); 
		
		return this.transform._rotationZ;
	}
	
	public var width(get, set):Float;
	inline private function set_width(w:Float):Float {
		var ow = this.width; 
		this.transform._postScale(w / ow, 1); 
		
		return w;
	}
	inline private function get_width():Float {
		this.transform._checkVals(); 
		
		return this._getParR(this, true).width; 
	}
	
	public var height(get, set):Float;
	inline private function set_height(h:Float):Float {
		var oh = this.height; 
		this.transform._postScale(1, h / oh); 
		
		return h;
	}
	inline private function get_height():Float {
		this.transform._checkVals(); 
		
		return this._getParR(this, true).height;	
	}
	
	public var alpha(get, set):Float;
	inline private function set_alpha(a:Float):Float { 
		this.transform._cmat[15] = a; 
		this.transform._checkColorID(); 
		
		return a;
	}
	inline private function get_alpha():Float {
		return this.transform._cmat[15]; 
	}
	
	public var mouseX(get, never):Int;
	inline private function get_mouseX():Int { 
		return Std.int(this._getMouse().x);	
	}
	
	public var mouseY(get, never):Int;
	inline private function get_mouseY():Int {
		return Std.int(this._getMouse().y);
	}
	
}
