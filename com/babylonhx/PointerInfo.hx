package com.babylonhx;

import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This type contains all the data related to a pointer event in Babylon.js.
 * The event member is an instance of PointerEvent for all types except PointerWheel 
 * and is of type MouseWheelEvent when type equals PointerWheel. The different event 
 * types can be found in the PointerEventTypes class.
 */

typedef PointerEvent = {
	x:Int,
	y:Int,
	button:Null<Int>
}

class PointerInfo {
	
	public var type:Int;
	public var event:PointerEvent;
	public var pickInfo:PickingInfo;
	

	public function new(type:Int, event:PointerEvent, pickInfo:PickingInfo) {
		this.type = type;
		this.event = event;
		this.pickInfo = pickInfo;
	}
	
}
