package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BlurPostProcess') class BlurPostProcess extends PostProcess {
	
	public var direction:Vector2;
	public var blurWidth:Float;
	
	
	public function new(name:String, direction:Vector2, blurWidth:Float, ratio:Float, camera:Camera, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false/*?reusable:Bool*/) {
		super(name, "blur", ["screenSize", "direction", "blurWidth"], null, ratio, camera, samplingMode, engine, reusable);
		this.onApply = function(effect:Effect) {
			effect.setFloat2("screenSize", this.width, this.height);
			effect.setVector2("direction", this.direction);
			effect.setFloat("blurWidth", this.blurWidth);
		};
	}

}
