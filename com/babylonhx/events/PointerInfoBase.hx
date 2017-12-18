package com.babylonhx.events;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PointerInfoBase {
	
	public var type:Int;
	public var event:PointerEvent;
	

	public function new(type:Int, event:PointerEvent) {
		this.type = type;
		this.event = event;
	}
	
}
