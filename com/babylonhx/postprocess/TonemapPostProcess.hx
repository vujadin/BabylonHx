package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:enum 
abstract TonemappingOperator(Int) {
    var Hable = 0;
    var Reinhard = 1;
    var HejiDawson = 2;
    var Photographic = 3;
}
 
class TonemapPostProcess extends PostProcess {

	private var _operator:TonemappingOperator;
	public var exposureAdjustment:Float;

	
	public function new(name:String, operator:TonemappingOperator, exposureAdjustment:Float, camera:Camera, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, textureFormat:Int = Engine.TEXTURETYPE_UNSIGNED_INT) {
		super(name, "tonemap", ["_ExposureAdjustment"], null, 1.0, camera, samplingMode, engine, true, defines, textureFormat);
		
		this._operator = operator;
		this.exposureAdjustment = exposureAdjustment;
		
		var defines:String = "#define ";
		
		if (operator == TonemappingOperator.Hable) {
			defines += "HABLE_TONEMAPPING";
		}
		else if (operator == TonemappingOperator.Reinhard) {
			defines += "REINHARD_TONEMAPPING";
		}
		else if (operator == TonemappingOperator.HejiDawson) {
			defines += "OPTIMIZED_HEJIDAWSON_TONEMAPPING";
		}
		else if (operator == TonemappingOperator.Photographic) {
			defines += "PHOTOGRAPHIC_TONEMAPPING";
		}
		
		//sadly a second call to create the effect.
		this.updateEffect(defines);
		
		this.onApply = function(effect:Effect) {
			effect.setFloat("_ExposureAdjustment", this.exposureAdjustment);
		};
	}
	
}
