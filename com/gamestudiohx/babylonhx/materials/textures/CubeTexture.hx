package com.gamestudiohx.babylonhx.materials.textures;

import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.tools.math.Matrix;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

 
// CubeTexture should inherit BaseTexture, not Texture - but this makes things easier (less casting involved)
class CubeTexture extends Texture {	
	
	public var _textureMatrix:Matrix;
	public var _extensions:Array<String>;
	public var isCube:Bool = true;

	
	public function new(rootUrl:String, scene:Scene, ?extensions:Array<String>) {
		
		// HACK - _scene is null before we call super class constructor, so we have to set it here ...
		this._scene = scene;
		
		if (null == extensions) {
            extensions = ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];
        }

        this._extensions = extensions;
		
		this._texture = this._getFromCache(rootUrl, false);
		if (this._texture == null) {
            this._texture = scene.getEngine().createCubeTexture(rootUrl, scene, extensions);           
        } 
		super(rootUrl, scene);
        
        this.name = rootUrl;
        this.url = rootUrl;
        this.hasAlpha = false;
        this.coordinatesMode = Texture.CUBIC_MODE;

        this._textureMatrix = Matrix.Identity();
	}
	
	override public function delayLoad() {
        if (this.delayLoadState != Engine.DELAYLOADSTATE_NOTLOADED) {
            return;
        }

        this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
        this._texture = this._getFromCache(this.url, false);

        if (this._texture == null) {
            this._texture = this._scene.getEngine().createCubeTexture(this.url, this._scene);
        }
    }
	
	override public function _computeReflectionTextureMatrix():Matrix {
        return this._textureMatrix;
    }
	
}
