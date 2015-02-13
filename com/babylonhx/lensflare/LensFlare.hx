package com.babylonhx.lensflare;

import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.LensFlare') class LensFlare {
	
	public var size:Float;
	public var color:Color3;
	public var texture:Texture;
	public var position:Float;

	private var _system:LensFlareSystem;
	

	public function new(size:Float, position:Float, ?color:Color3, ?imgUrl:String, system:LensFlareSystem) {
		this.color = color != null ? color : new Color3(1, 1, 1);
        this.position = position;
        this.size = size;
        this.texture = imgUrl != null ? new Texture(imgUrl, system.getScene(), true) : null;
        this._system = system;
        
        _system.lensFlares.push(this);
	}

	public function dispose():Void {
		if (this.texture != null) {
			this.texture.dispose();
		}

		// Remove from scene
		this._system.lensFlares.remove(this);
	}
	
}
	