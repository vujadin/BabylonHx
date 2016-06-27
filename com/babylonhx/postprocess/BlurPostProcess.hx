package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BlurPostProcess') class BlurPostProcess extends PostProcess {
	
	public var direction:Vector2;
	public var blurWidth:Float;
	
	
	public function new(name:String, direction:Vector2, blurWidth:Float, ratio:Float, camera:Camera, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false) {
		super(name, "blur", ["screenSize", "direction", "blurWidth"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.direction = direction;
        this.blurWidth = blurWidth;
		
		this.onApplyObservable.add(function(effect:Effect, es:EventState = null) {
			effect.setFloat2("screenSize", this.width, this.height);
			effect.setVector2("direction", this.direction);
			effect.setFloat("blurWidth", this.blurWidth);
		});
	}

}
