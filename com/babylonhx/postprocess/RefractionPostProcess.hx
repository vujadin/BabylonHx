package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.Effect;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RefractionPostProcess') class RefractionPostProcess extends PostProcess {
	
	public var color:Color3;
	public var depth:Float;
	public var colorLevel:Float;
	
	private var _refTexture:Texture;
	
	
	public function new(name:String, refractionTextureUrl:String, color:Color3, depth:Float, colorLevel:Float, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		super(name, "refraction", ["baseColor", "depth", "colorLevel"], ["refractionSampler"], ratio, camera, samplingMode, engine, reusable);
		
		this.color = color;
		this.depth = depth;
		this.colorLevel = colorLevel;
		
		this.onActivate = function(cam:Camera) {
			this._refTexture = this._refTexture != null ? this._refTexture : new Texture(refractionTextureUrl, cam.getScene());
		};
		
		this.onApply = function(effect:Effect) {
			effect.setColor3("baseColor", this.color);
			effect.setFloat("depth", this.depth);
			effect.setFloat("colorLevel", this.colorLevel);
			
			effect.setTexture("refractionSampler", this._refTexture);
		};
	}

	// Methods
	override public function dispose(?camera:Camera):Void {
		if (this._refTexture != null) {
			this._refTexture.dispose();
		}
		
		super.dispose(camera);
	}
	
}
