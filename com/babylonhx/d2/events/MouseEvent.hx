package com.babylonhx.d2.events;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MouseEvent extends Event {
	
	public static inline var CLICK					= "click";
	public static inline var MOUSE_DOWN				= "mouseDown";
	public static inline var MOUSE_UP				= "mouseUp";

	public static inline var MIDDLE_CLICK			= "middleClick";
	public static inline var MIDDLE_MOUSE_DOWN		= "middleMouseDown";
	public static inline var MIDDLE_MOUSE_UP		= "middleMouseUp";

	public static inline var RIGHT_CLICK			= "rightClick";
	public static inline var RIGHT_MOUSE_DOWN		= "rightMouseDown";
	public static inline var RIGHT_MOUSE_UP			= "rightMouseUp";

	public static inline var MOUSE_MOVE				= "mouseMove";
	public static inline var MOUSE_OVER				= "mouseOver";
	public static inline var MOUSE_OUT				= "mouseOut";
	
	
	public var movementX:Int;
	public var movementY:Int;
	

	public function new(type:String, bubbles:Bool = false) {
		super(type, bubbles);
		
		this.movementX = 0;
		this.movementY = 0;
	}
	
}
