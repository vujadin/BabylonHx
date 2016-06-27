package com.babylonhx.animations;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AnimationRange {
	
	public var name:String;
	public var from:Float;
	public var to:Float;
	

	public function new(name:String, from:Float, to:Float) {
		this.name = name;
		this.from = from;
		this.to = to;
	}
	
	public function clone():AnimationRange {
		return new AnimationRange(this.name, this.from, this.to);
	}
	
}
