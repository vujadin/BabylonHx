package com.babylonhx.d2.events;

import com.babylonhx.d2.display.Stage;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TouchEvent extends Event {
	
	static public inline var TOUCH_BEGIN:String = "touchBegin";
	static public inline var TOUCH_END:String = "touchEnd";
	static public inline var TOUCH_MOVE:String = "touchMove";
	static public inline var TOUCH_OUT:String = "touchOut";
	static public inline var TOUCH_OVER:String = "touchOver";
	static public inline var TOUCH_TAP:String = "touchTap";
	
	
	public var stageX:Int;
	public var stageY:Int;
	public var touchPointID:Int;
	

	public function new(type:String, bubbles:Bool) {
		super(type, bubbles);
		
		this.stageX = 0;
		this.stageY = 0;
		this.touchPointID = -1;
	}

	public function _setFromDom(t:Dynamic) {
		var dpr = 1;// Stage._getDPR();
		this.stageX = Std.int(t.clientX * dpr);
		this.stageY = Std.int(t.clientY * dpr);
		this.touchPointID = t.identifier;
	}
	
}
