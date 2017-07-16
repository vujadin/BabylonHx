package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.FxaaPostProcess') class FxaaPostProcess extends PostProcess {
	
	public function new(name:String, options:Dynamic, camera:Camera, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false, textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT) {
		super(name, "fxaa", ["texelSize"], null, options, camera, samplingMode, engine, reusable, null, textureType, "fxaa");
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setFloat2("texelSize", texelSize.x, texelSize.y);
		});
	}
	
}
	