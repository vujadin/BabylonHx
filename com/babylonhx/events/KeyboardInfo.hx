package com.babylonhx.events;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef KeyboardEvent = {
	keyCode:Int,
	key:String
}
 
class KeyboardInfo {
	
	public var type:Int;
	public var event:KeyboardEvent;
	

	public function new(type:Int, event:KeyboardEvent) {
		this.type = type;
		this.event = event;
	}
	
}