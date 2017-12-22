package com.babylonhx.animations;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This class defines the direct association between an animation and a target
 */
class TargetedAnimation {
	
	public var animation:Animation;
	public var target:Dynamic;
	

	public function new(anim:Animation, targ:Dynamic) {
		this.animation = anim;
		this.target = targ;
	}
	
}
