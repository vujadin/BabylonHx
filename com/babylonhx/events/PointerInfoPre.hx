package com.babylonhx.events;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This class is used to store pointer related info for the onPrePointerObservable event.
 * Set the skipOnPointerObservable property to true if you want the engine to stop any process after 
 * this event is triggered, even not calling onPointerObservable
 */
class PointerInfoPre extends PointerInfoBase {
	
	public var localPosition:Vector2;
	public var skipOnPointerObservable:Bool;
	
	
	public function new(type:Int, event:PointerEvent, localX:Int, localY:Int) {
		super(type, event);
		this.skipOnPointerObservable = false;
		this.localPosition = new Vector2(localX, localY);
	}

}
