package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BlackAndWhitePostProcess') class BlackAndWhitePostProcess extends PostProcess {
	
	public var degree:Float = 1;
	
	
	public function new(name:String, options:Dynamic, camera:Camera, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false) {
		super(name, "blackAndWhite", ["degree"], null, options, camera, samplingMode, engine, reusable);
		
		this.onApplyObservable.add(function(effect:Effect, _) => {
			effect.setFloat("degree", this.degree);
		});
	}
	
}
