package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Observer<T> {
	
	/** @ignore */
	public var _willBeUnregistered:Bool = false;
	/**
	 * Gets or sets a property defining that the observer as to be unregistered after the next notification
	 */
	public var unregisterOnNextCall:Bool = false;
	/**
	 * Defines the callback to call when the observer is notified
	 */
	public var callback:T->Null<EventState<T>>->Void;
	/**
	 * Defines the mask of the observer (used to filter notifications)
	 */
	public var mask:Int;
	/**
	 * Defines the current scope used to restore the JS context
	 */
	public var scope:Dynamic;
	

	/**
	 * Creates a new observer
	 * @param callback defines the callback to call when the observer is notified
	 * @param mask defines the mask of the observer (used to filter notifications)
	 * @param scope defines the current scope used to restore the JS context
	 */
	public function new(callback:T->Null<EventState<T>>->Void, mask:Int, scope:Dynamic = null) {
		this.callback = callback;
		this.mask = mask;
		this.scope = scope;
	}
	
}
