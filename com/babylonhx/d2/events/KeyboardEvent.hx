package com.babylonhx.d2.events;

/**
 * ...
 * @author Krtolica Vujadin
 */
class KeyboardEvent extends Event {
	
	static inline public var KEY_DOWN:String = "keyDown";
	static inline public var KEY_UP:String = "keyUp";
	
	public var altKey:Bool;
	public var ctrlKey:Bool;
	public var shiftKey:Bool;
	
	public var keyCode:Int;
	public var charCode:Int;
	

	public function new(type:String, bubbles:Bool) {
		super(type, bubbles);
		
		this.altKey = false;
		this.ctrlKey = false;
		this.shiftKey = false;
		
		this.keyCode = 0;
		this.charCode = 0;
	}

	public function _setFromDom(altKey:Bool, ctrlKey:Bool, shiftKey:Bool, keyCode:Int, charCode:Int) {
		this.altKey		= altKey;
		this.ctrlKey	= ctrlKey;
		this.shiftKey	= shiftKey;
		
		this.keyCode	= keyCode;
		this.charCode	= charCode;
	}
	
}
