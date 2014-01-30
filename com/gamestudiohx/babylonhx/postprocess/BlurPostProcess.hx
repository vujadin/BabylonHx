package com.gamestudiohx.babylonhx.postprocess;

import com.gamestudiohx.babylonhx.cameras.Camera;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.tools.math.Vector2;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class BlurPostProcess extends PostProcess {
	
	public var direction:Vector2;
	public var blurWidth:Float;

	public function new(name:String, direction:Vector2, blurWidth:Float, ratio:Float, camera:Camera, samplingMode:Int = -1) {
		if (samplingMode == -1) {
            samplingMode = Texture.BILINEAR_SAMPLINGMODE;
        }

        super(name, "blur", ["screenSize", "direction", "blurWidth"], null, ratio, camera, samplingMode);

        this.direction = direction;
        this.blurWidth = blurWidth;
        this.onApply = function (effect:Effect) {
            effect.setFloat2("screenSize", this.width, this.height);
            effect.setVector2("direction", this.direction);
            effect.setFloat("blurWidth", this.blurWidth);
        };
	}
	
}
