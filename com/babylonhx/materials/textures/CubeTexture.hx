package com.babylonhx.materials.textures;

import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CubeTexture') class CubeTexture extends Texture {
	
	private var _extensions:Array<String>;
	private var _textureMatrix:Matrix;

	
	public function new(rootUrl:String, scene:Scene, ?extensions:Array<String>, ?noMipmap:Bool) {	
		super(rootUrl, scene, noMipmap);
		this.coordinatesMode = Texture.CUBIC_MODE;
		
		this.name = rootUrl;
		this.url = rootUrl;
		this._noMipmap = noMipmap;
		this.hasAlpha = false;
		//this._texture = this._getFromCache(rootUrl, noMipmap);
		
		if (extensions == null) {
			extensions = ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];
		}
		
		this._extensions = extensions;
		
		if (this._texture == null) {
			if (!scene.useDelayedTextureLoading) {
				this._texture = scene.getEngine().createCubeTexture(rootUrl, scene, extensions, noMipmap);
			} else {
				this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
			}
		}
				
		this.isCube = true;
		
		this._textureMatrix = Matrix.Identity();
	}

	override public function clone():CubeTexture {
		var newTexture = new CubeTexture(this.url, this.getScene(), this._extensions, this._noMipmap);
		
		// Base texture
		newTexture.level = this.level;
		newTexture.wrapU = this.wrapU;
		newTexture.wrapV = this.wrapV;
		newTexture.coordinatesIndex = this.coordinatesIndex;
		newTexture.coordinatesMode = this.coordinatesMode;
		
		return newTexture;
	}

	// Methods
	override public function delayLoad() {
		if (this.delayLoadState != Engine.DELAYLOADSTATE_NOTLOADED) {
			return;
		}
		
		this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
		this._texture = this._getFromCache(this.url, this._noMipmap);
		
		if (this._texture == null) {
			this._texture = this.getScene().getEngine().createCubeTexture(this.url, this.getScene(), this._extensions);
		}
	}

	override public function getReflectionTextureMatrix():Matrix {
		return this._textureMatrix;
	}
	
}
