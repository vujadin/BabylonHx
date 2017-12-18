package com.babylonhx.postprocess;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Vector2;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.textures.Texture;


/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Special Glow Blur post process only blurring the alpha channel
 * It enforces keeping the most luminous color in the color channel.
 */
class GlowBlurPostProcess extends PostProcess {

	public var direction:Vector2;
	public var kernel:Float;
	
	
	public function new(name:String, direction:Vector2, kernel:Float, options:Dynamic, camera:Camera, samplingMode:Int = Texture.BILINEAR_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false) {
		this.direction = direction;
		this.kernel = kernel;
		
		super(name, "glowBlurPostProcess", ["screenSize", "direction", "blurWidth"], null, options, camera, samplingMode, engine, reusable);
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setFloat2("screenSize", this.width, this.height);
			effect.setVector2("direction", this.direction);
			effect.setFloat("blurWidth", this.kernel);
		});
	}
	
}
