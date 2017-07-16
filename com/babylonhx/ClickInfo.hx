package com.babylonhx;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ClickInfo {

	private var _singleClick:Bool = false;
	private var _doubleClick:Bool = false;
	private var _hasSwiped:Bool = false;
	private var _ignore:Bool = false;

	public var singleClick(get, set):Bool;
	inline private function get_singleClick():Bool {
		return this._singleClick;
	}
	inline private function set_singleClick(b:Bool):Bool {
		return this._singleClick = b;
	}
	
	public var doubleClick(get, set):Bool;
	inline private function get_doubleClick():Bool {
		return this._doubleClick;
	}
	inline private function set_doubleClick(b:Bool):Bool {
		return this._doubleClick = b;
	}
	
	public var hasSwiped(get, set):Bool;
	inline private function get_hasSwiped():Bool {
		return this._hasSwiped;
	}
	inline private function set_hasSwiped(b:Bool):Bool {
		return this._hasSwiped = b;
	}
	
	public var ignore(get, set):Bool;
	inline private function get_ignore():Bool {
		return this._ignore;
	}
	inline private function set_ignore(b:Bool):Bool {
		return this._ignore = b;
	}
	
	
	public function new() { }
	
}
