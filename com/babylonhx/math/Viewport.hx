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
	
	
	inline public function new(x:Float, y:Float, width:Float, height:Float) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	inline public function toGlobal(renderWidth:Int, renderHeight:Int):Viewport {		
		return new Viewport(this.x * renderWidth, this.y * renderHeight, this.width * renderWidth, this.height * renderHeight);
	}
	
}
