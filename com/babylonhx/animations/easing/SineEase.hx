package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

class SineEase  extends EasingFunction {
	
	override public easeInCore(gradient:Float):Float {
		return (1.0 - Math.sin((Math.PI / 2) * (1.0 - gradient)));
	}
	
}
	