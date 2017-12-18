package com.babylonhx.events;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PointerEvent {
	
	public var x:Float;
	public var y:Float;
	public var button:Int = -1;
	public var type:Int = PointerEventTypes.POINTERMOVE;
	public var pointerType:String = "";
	
	/*pointerId:Null<Int>,
	pointerType:Null<Int>*/
	

	inline public function new(x:Float = 0, y:Float = 0, button:Int = -1, type:Int = PointerEventTypes.POINTERMOVE, pointerType:String = "") {
		this.x = x;
		this.y = y;
		this.button = button;
		this.type = type;
		this.pointerType = pointerType;
	}
	
}
