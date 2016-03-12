package com.babylonhx.materials.textures;

import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CubeTexture') class CubeTexture extends BaseTexture {
	
	public var url:String;
	
	private var _noMipmap:Bool;
	private var _files:Array<String>;
	private var _extensions:Array<String>;
	private var _textureMatrix:Matrix;
	
	
	public static function CreateFromImages(files:Array<String>, scene:Scene, noMipmap:Bool = false) {
		return new CubeTexture("", scene, null, noMipmap, files);
	}

	
	public function new(rootUrl:String, scene:Scene, ?extensions:Array<String>, noMipmap:Bool = false, ?files:Array<String>) {				
		super(scene);
		
		this.coordinatesMode = Texture.CUBIC_MODE;
		
		this.name = rootUrl;
		this.url = rootUrl;
		this._noMipmap = noMipmap;
		this.hasAlpha = false;
		
		if ((rootUrl == null || rootUrl == "") && files == null) {
			return;
		}
		
		//this._texture = this._getFromCache(rootUrl, noMipmap);
		
		if (files == null) {
			if (extensions == null) {
				extensions = ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];
			}
			
			files = [];
			
			for (index in 0...extensions.length) {
				files.push(rootUrl + extensions[index]);
			}
			
			this._extensions = extensions;
		}
		
		this._files = files;
		
		if (this._texture == null) {
			if (!scene.useDelayedTextureLoading) {
				this._texture = scene.getEngine().createCubeTexture(rootUrl, scene, files, noMipmap);
			} 
			else {
				this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
			}
		}
		
		this.isCube = true;
		
		this._textureMatrix = Matrix.Identity();
	}

	override public function clone():CubeTexture {
		var newTexture = new CubeTexture(this.url, this.getScene(), this._extensions, this._noMipmap, this._files);
		
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
	
	override public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject:Dynamic = { };
		serializationObject.name = this.name;
		serializationObject.hasAlpha = this.hasAlpha;
		serializationObject.isCube = true;
		serializationObject.level = this.level;
		serializationObject.coordinatesMode = this.coordinatesMode;
		
		return serializationObject;
	}
	
	public static function Parse(parsedTexture:Dynamic, scene:Scene, rootUrl:String):CubeTexture {
		var texture:CubeTexture = null;
		if ((parsedTexture.name != null || parsedTexture.extensions != null) && !parsedTexture.isRenderTarget) {
			texture = new CubeTexture(rootUrl + parsedTexture.name, scene, parsedTexture.extensions);
			texture.name = parsedTexture.name;
			texture.hasAlpha = parsedTexture.hasAlpha;
			texture.level = parsedTexture.level;
			texture.coordinatesMode = parsedTexture.coordinatesMode;
		}
		
		return texture;
	}
	
}
