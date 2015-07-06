package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Viewport') class Viewport {
	
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	
	
	public function new(x:Float, y:Float, width:Float, height:Float) {
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
