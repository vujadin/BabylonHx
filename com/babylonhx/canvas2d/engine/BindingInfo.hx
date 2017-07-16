package com.babylonhx.canvas2d.engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BindingInfo {
	
	public var binding:DataBinding;
	public var level:Int;
	public var isLast:Bool;
	

	public function new(binding:DataBinding, level:Int, isLast:Bool) {
		this.binding = binding;
		this.level = level;
		this.isLast = isLast;
	}
	
}
