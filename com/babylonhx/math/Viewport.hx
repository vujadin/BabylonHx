package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Viewport') class Viewport {
	
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	
	
	public function new(x:Int, y:Int, width:Int, height:Int) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	inline public function toGlobal(engine:Engine) {
		var width = engine.getRenderWidth();
		var height = engine.getRenderHeight();
		return new Viewport(this.x * width, this.y * height, this.width * width, this.height * height);
	}
	
}
