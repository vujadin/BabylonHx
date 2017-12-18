package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Observer<T> {
	
	public var callback:T->Null<EventState>->Void;
	public var mask:Int;
	public var scope:Dynamic;
	

	inline public function new(callback:T->Null<EventState>->Void, mask:Int, scope:Dynamic = null) {
		this.callback = callback;
		this.mask = mask;
		this.scope = scope;
	}
	
}
