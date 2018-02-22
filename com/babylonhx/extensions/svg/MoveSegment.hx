package com.babylonhx.extensions.svg;

// https://github.com/openfl/svg
class MoveSegment extends PathSegment {
	
	public function new(inX:Float, inY:Float) {
		super(inX, inY);
	}
	
	override public function getType():Int {
		return PathSegment.MOVE;
	}
	
}
