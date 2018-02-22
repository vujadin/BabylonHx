package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg
class RenderContext {

	public var firstX:Float;
	public var firstY:Float;
	public var lastX:Float;
	public var lastY:Float;
	
	
	public function new() {
		firstX = 0;
		firstY = 0;
		lastX = 0;
		lastY = 0;
	}
	
	public function setLast(inX:Float, inY:Float) {
		lastX = inX;// transX(inX, inY);
		lastY = inY;// transY(inX, inY);
	}
	
}
