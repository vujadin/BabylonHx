package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BackEase') class BackEase extends EasingFunction {
	
	public var amplitude:Float = 1;
	
	
	public function new(amplitude:Float = 1) {
		super();
		
		this.amplitude = amplitude;
	}

	override public function easeInCore(gradient:Float):Float {
		var num = Math.max(0, this.amplitude);
		return (Math.pow(gradient, 3.0) - ((gradient * num) * Math.sin(Math.PI * gradient)));
	}
	
}
