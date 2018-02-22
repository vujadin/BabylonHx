package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg
class PathSegment {
	
	public static inline var MOVE  = 1;
	public static inline var DRAW  = 2;
	public static inline var CURVE = 3;
	public static inline var CUBIC = 4;
	public static inline var ARC   = 5;

	public var x:Float;
	public var y:Float;
	

	public function new(inX:Float, inY:Float) {
		x = inX;
		y = inY;
	}
	
	public function getType():Int {
		return 0;
	}

	public function prevX() { return x; }
	public function prevY() { return y; }
	public function prevCX() { return x; }
	public function prevCY() { return y; }
	
	public function toGfx(inGfx:SVGDataToPointsArray, ioContext:RenderContext) {
		ioContext.setLast(x, y);
		ioContext.firstX = ioContext.lastX;
		ioContext.firstY = ioContext.lastY;
		inGfx.moveTo(ioContext.lastX, ioContext.lastY);
	}

}
