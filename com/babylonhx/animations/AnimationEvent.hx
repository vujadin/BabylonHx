package com.babylonhx.animations;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AnimationEvent {
	
	public var frame:Int;
	public var action:Void->Void;
	public var onlyOnce:Bool;
	public var isDone:Bool = false;
	

	public function new(frame:Int, action:Void->Void, onlyOnce:Bool = false) {
		this.frame = frame;
		this.action = action;
		this.onlyOnce = onlyOnce;
	}
	
}
