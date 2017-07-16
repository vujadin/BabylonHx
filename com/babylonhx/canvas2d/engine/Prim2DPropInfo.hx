package com.babylonhx.canvas2d.engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Prim2DPropInfo {
	
	public static var PROPKIND_MODEL:Int = 1;
	public static var PROPKIND_INSTANCE:Int = 2;
	public static var PROPKIND_DYNAMIC:Int = 3;

	public var id:Int;
	public var flagId:Int;
	public var kind:Int;
	public var name:String;
	public var dirtyBoundingInfo:Bool;
	public var dirtyParentBoundingInfo:Bool;
	public var typeLevelCompare:Bool;
	public var bindingMode:Int;
	public var bindingUpdateSourceTrigger:Int;
	

	public function new() {
		
	}
	
}
