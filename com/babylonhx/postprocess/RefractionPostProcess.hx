package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.Effect;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RefractionPostProcess') class RefractionPostProcess extends PostProcess {
	
	public var color:Color3;
	public var depth:Float;
	public var colorLevel:Float;
	
	private var _refTexture:Texture;
	
	
	public function new(name:String, refractionTextureUrl:String, color:Color3, depth:Float, colorLevel:Float, options:Dynamic, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		super(name, "refraction", ["baseColor", "depth", "colorLevel"], ["refractionSampler"], options, camera, samplingMode, engine, reusable);
		
		this.color = color;
		this.depth = depth;
		this.colorLevel = colorLevel;
		
		this.onActivateObservable.add(function(cam:Camera, _) {
			this._refTexture = this._refTexture != null ? this._refTexture : new Texture(refractionTextureUrl, cam.getScene());
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setColor3("baseColor", this.color);
			effect.setFloat("depth", this.depth);
			effect.setFloat("colorLevel", this.colorLevel);
			
			effect.setTexture("refractionSampler", this._refTexture);
		});
	}

	// Methods
	override public function dispose(?camera:Camera):Void {
		if (this._refTexture != null) {
			this._refTexture.dispose();
		}
		
		super.dispose(camera);
	}
	
}
