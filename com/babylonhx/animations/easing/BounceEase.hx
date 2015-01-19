package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BounceEase') class BounceEase extends EasingFunction {
	
	public var bounces:Float = 3.0;
	public var bounciness:Float = 2.0;
	
	
	public function new(bounces:Float = 3, bounciness:Float = 2) {
		super();
		
		this.bounces = bounces;
		this.bounciness = bounciness;
	}

	override public function easeInCore(gradient:Float):Float {
		var y = Math.max(0.0, this.bounces);
		var bounciness = this.bounciness;
		if (bounciness <= 1.0) {
			bounciness = 1.001;
		}
		var num9 = Math.pow(bounciness, y);
		var num5 = 1.0 - bounciness;
		var num4 = ((1.0 - num9) / num5) + (num9 * 0.5);
		var num15 = gradient * num4;
		var num65 = Math.log((-num15 * (1.0 - bounciness)) + 1.0) / Math.log(bounciness);
		var num3 = Math.floor(num65);
		var num13 = num3 + 1.0;
		var num8 = (1.0 - Math.pow(bounciness, num3)) / (num5 * num4);
		var num12 = (1.0 - Math.pow(bounciness, num13)) / (num5 * num4);
		var num7 = (num8 + num12) * 0.5;
		var num6 = gradient - num7;
		var num2 = num7 - num8;
		return (((-Math.pow(1.0 / bounciness, y - num3) / (num2 * num2)) * (num6 - num2)) * (num6 + num2));
	}
	
}
