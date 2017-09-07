package com.babylonhx.events;

import com.babylonhx.events.KeyboardInfo.KeyboardEvent;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * This class is used to store keyboard related info for the onPreKeyboardObservable event.
 * Set the skipOnKeyboardObservable property to true if you want the engine to stop any process after this event is triggered, even not calling onKeyboardObservable
 */
class KeyboardInfoPre extends KeyboardInfo {
	
	public var skipOnPointerObservable:Bool;
	
	
	public function new(type:Int, event:KeyboardEvent) {
		super(type, event);
		this.skipOnPointerObservable = false;
	}
	
}
