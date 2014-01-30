package com.gamestudiohx.babylonhx.lensflare;

import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.materials.textures.Texture;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class LensFlare {
	
	public var size:Float;
	public var position:Float;
	public var color:Color3;
	public var texture:Texture;
	
	private var _system:LensFlareSystem;
	

	public function new(size:Float, position:Float, ?color:Color3, ?imgUrl:String, system:LensFlareSystem) {
		this.color = color != null ? color : new Color3(1, 1, 1);
        this.position = position;
        this.size = size;
        this.texture = imgUrl != null ? new Texture(imgUrl, system.getScene(), true) : null;
        this._system = system;
        
        _system.lensFlares.push(this);
	}
	
	public function dispose() {
		if (this.texture != null) {
            this.texture.dispose();
        }
        
        // Remove from scene
        //var index = Lambda.indexOf(this._system.lensFlares, this);
        //this._system.lensFlares.splice(index, 1);
		this._system.lensFlares.remove(this);
	}
	
}
