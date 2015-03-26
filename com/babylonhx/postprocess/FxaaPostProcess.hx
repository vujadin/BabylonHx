package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.FxaaPostProcess') class FxaaPostProcess extends PostProcess {
	
	public var texelWidth:Float;
	public var texelHeight:Float;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false/*?reusable:Bool*/) {
		super(name, "fxaa", ["texelSize"], null, ratio, camera, samplingMode, engine, reusable);

		this.onSizeChanged = function() {
			this.texelWidth = 1.0 / this.width;
			this.texelHeight = 1.0 / this.height;
		};
		this.onApply = function(effect:Effect) {
			effect.setFloat2("texelSize", this.texelWidth, this.texelHeight);
		}
	}
	
}
	