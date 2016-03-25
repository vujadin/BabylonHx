package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Observer<T> {
	
	public var callback:T->Null<EventState>->Void;
	

	public function new(callback:T->Null<EventState>->Void) {
		this.callback = callback;
	}
	
}
