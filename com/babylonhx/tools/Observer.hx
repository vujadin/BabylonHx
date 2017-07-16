package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Observer<T> {
	
	public var callback:T->Null<EventState>->Void;
	public var mask:Int;
	

	inline public function new(callback:T->Null<EventState>->Void, mask:Int) {
		this.callback = callback;
		this.mask = mask;
	}
	
}
