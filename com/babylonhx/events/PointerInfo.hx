package com.babylonhx.events;

import com.babylonhx.collisions.PickingInfo;

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
class PointerInfo extends PointerInfoBase {
	
	public var pickInfo:PickingInfo;
	

	public function new(type:Int, event:PointerEvent, pickInfo:PickingInfo) {
		super(type, event);
		this.pickInfo = pickInfo;
	}
	
}
