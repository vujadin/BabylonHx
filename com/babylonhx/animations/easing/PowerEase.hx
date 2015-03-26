package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PowerEase') class PowerEase extends EasingFunction {
	
	public var power:Float = 2;
	
	
	public function new(power:Float = 2) {
		super();
		
		this.power = power;
	}

	override public function easeInCore(gradient:Float):Float {
		var y = Math.max(0.0, this.power);
		return Math.pow(gradient, y);
	}
	
}
