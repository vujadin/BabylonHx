package com.babylonhx.d2.events;

import com.babylonhx.d2.display.DisplayObject;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Event {
	
	public static inline var ENTER_FRAME			= "enterFrame";
	public static inline var RESIZE					= "resize";
	public static inline var ADDED_TO_STAGE 		= "addedToStage";
	public static inline var REMOVED_FROM_STAGE 	= "removedFromStage";

	public static inline var CHANGE					= "change";

	public static inline var OPEN					= "open";
	public static inline var PROGRESS				= "progress";
	public static inline var COMPLETE				= "complete";
	
	
	public var type:String;
	public var target:DisplayObject;
	public var currentTarget:DisplayObject;
	public var bubbles:Bool;
	

	public function new(type:String, bubbles:Bool = false) {
		this.type			= type;
		this.target			= null;
		this.currentTarget	= null;
		this.bubbles		= bubbles;
	}
	
}
