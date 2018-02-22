package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg
class QuadraticSegment extends PathSegment {
	
	public var cx:Float;
	public var cy:Float;
	

	public function new(inCX:Float, inCY:Float, inX:Float, inY:Float) {
		super(inX, inY);
		cx = inCX;
		cy = inCY;
	}

	override public function prevCX() { return cx; }
	override public function prevCY() { return cy; }

	override public function getType():Int {
		return PathSegment.CURVE;
	}
	
}