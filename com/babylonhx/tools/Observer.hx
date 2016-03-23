package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Observer<T> {
	
	public var callback:T->Void;
	

	public function new(callback:T->Void) {
		this.callback = callback;
	}
	
}
