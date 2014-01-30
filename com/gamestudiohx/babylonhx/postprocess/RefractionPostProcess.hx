package com.gamestudiohx.babylonhx.postprocess;

import com.gamestudiohx.babylonhx.cameras.Camera;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.tools.math.Color3;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class RefractionPostProcess extends PostProcess {
	
	public var color:Color3;
	public var depth:Float;
	public var colorLevel:Float;
	public var _refTexture:Texture;

	public function new(name:String, refractionTextureUrl:String, color:Color3, depth:Float, colorLevel:Float, ratio:Float, camera:Camera, samplingMode:Int = 1) {
		super(name, "refraction", ["baseColor", "depth", "colorLevel"], ["refractionSampler"], ratio, camera, samplingMode);
		
		this.color = color;
        this.depth = depth;
        this.colorLevel = colorLevel;
		
        this._refTexture = new Texture(refractionTextureUrl, camera.getScene());
        
        this.onApply = function(effect:Effect):Void {
            effect.setColor3("baseColor", this.color);
            effect.setFloat("depth", this.depth);
            effect.setFloat("colorLevel", this.colorLevel);

            effect.setTexture("refractionSampler", this._refTexture);
        };
		
		this._onDispose = function() {
			if (this._refTexture != null) {
				this._refTexture.dispose();
			}
		}
	}
		
}