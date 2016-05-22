package com.babylonhx;

import com.babylonhx.PointerInfo.PointerEvent;
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
class PointerInfoPre {
	
	public var type:Int;
	public var event:PointerEvent;
	public var localPosition:Vector2;
	public var skipOnPointerObservable:Bool;
	
	
	public function new(type:Int, event:PointerEvent, localX:Int, localY:Int) {
		this.type = type;
		this.event = event;
		this.skipOnPointerObservable = false;
		this.localPosition = new Vector2(localX, localY);
	}

}
