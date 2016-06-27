package com.babylonhx.materials.textures;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;

import com.babylonhx.utils.GL;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BaseTexture') class BaseTexture implements IAnimatable {
	
	public var name:String;
	public var delayLoadState:Int = Engine.DELAYLOADSTATE_NONE;
	public var hasAlpha:Bool = false;
	public var getAlphaFromRGB:Bool = false;
	public var level:Float = 1;
	public var isCube:Bool = false;
	public var isRenderTarget:Bool = false;
	public var animations:Array<Animation> = [];
	public var coordinatesIndex:Int = 0;
	public var coordinatesMode:Int = Texture.EXPLICIT_MODE;
	public var wrapU:Int = Texture.WRAP_ADDRESSMODE;
	public var wrapV:Int = Texture.WRAP_ADDRESSMODE;
	public var anisotropicFilteringLevel:Int = 4;
	public var _cachedAnisotropicFilteringLevel:Int;
	
	/**
	* An event triggered when the texture is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable = new Observable<BaseTexture>();
	private var _onDisposeObserver:Observer<BaseTexture>;
	public var onDispose(never, set):BaseTexture->Null<EventState>->Void;
	private function set_onDispose(callback:BaseTexture->Null<EventState>->Void):BaseTexture->Null<EventState>->Void {
		if (this._onDisposeObserver != null) {
			this.onDisposeObservable.remove(this._onDisposeObserver);
		}
		this._onDisposeObserver = this.onDisposeObservable.add(callback);
		
		return callback;
	}
	
	public var __smartArrayFlags:Array<Int> = [];
	
	public var __serializableMembers:Dynamic;

	private var _scene:Scene;
	public var _texture:WebGLTexture;
	

	public function new(scene:Scene) {
		this._scene = scene;
		this._scene.textures.push(this);
	}

	public function getScene():Scene {
		return this._scene;
	}

	public function getTextureMatrix():Matrix {
		return null;
	}

	public function getReflectionTextureMatrix():Matrix {
		return null;
	}

	public function getInternalTexture():WebGLTexture {
		return this._texture;
	}

	public function isReady():Bool {
		if (this.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) {
			return true;
		}
		
		if (this._texture != null) {
			return this._texture.isReady;
		}
		
		return false;
	}

	public function getSize():Dynamic  {
		if (this._texture._width != -1 && this._texture._width != 0) {
			return { width: this._texture._width, height: this._texture._height };
		}
		
		if (this._texture._size != null) {
			return { width: this._texture._size, height: this._texture._size };
		}
		
		return { width: 0, height: 0 };
	}

	public function getBaseSize():Dynamic {
		if (!this.isReady() || this._texture == null) {
			return { width: 0, height: 0 };
		}
		
		if (this._texture._size != null) {
			return { width: this._texture._size, height: this._texture._size };
		}
		
		return { width: this._texture._baseWidth, height: this._texture._baseHeight };
	}

	public function scale(ratio:Float) { }

	/*public var canRescale(get, never):Bool;
	private function get_canRescale():Bool {
		return false;
	}*/

	public function _removeFromCache(url:String, noMipmap:Bool) {
		var texturesCache:Array<WebGLTexture> = this._scene.getEngine().getLoadedTexturesCache();
		for (index in 0...texturesCache.length) {
			var texturesCacheEntry = texturesCache[index];
			
			if (texturesCacheEntry.url == url && texturesCacheEntry.noMipmap == noMipmap) {
				texturesCache.splice(index, 1);
				return;
			}
		}
	}

	public function _getFromCache(url:String, noMipmap:Bool, ?sampling:Int):WebGLTexture {
        var texturesCache:Array<WebGLTexture> = this._scene.getEngine().getLoadedTexturesCache();
        for (index in 0...texturesCache.length) {
            var texturesCacheEntry:WebGLTexture = texturesCache[index];
			
            if (texturesCacheEntry.url == url && texturesCacheEntry.noMipmap == noMipmap) {
				if(sampling == null || sampling == texturesCacheEntry.samplingMode) {
					texturesCacheEntry.references++;
					return texturesCacheEntry;
				}
            }
        }
		
        return null;
    }

	public function delayLoad() {
	}

	public function releaseInternalTexture() {
        if (this._texture == null) {
            return;
        }
		
        var texturesCache:Array<WebGLTexture> = this._scene.getEngine().getLoadedTexturesCache();
        this._texture.references--;
		
        // Final reference ?
        if (this._texture.references == 0) {
			texturesCache.remove(this._texture);
			
            this._scene.getEngine()._releaseTexture(this._texture);
			
            this._texture = null;
        }
    }

	public function clone():BaseTexture {
		return null;
	}

	public function dispose() {
		// Animations
        this.getScene().stopAnimation(this);
		
		// Remove from scene
		var index = this._scene.textures.indexOf(this);
		
		if (index >= 0) {
			this._scene.textures.splice(index, 1);
		}
		
		if (this._texture == null) {
			return;
		}
		
		this.releaseInternalTexture();
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
        this.onDisposeObservable.clear();
	}
	
	public static function ParseCubeTexture(parsedTexture:Dynamic, scene:Scene, rootUrl:String):CubeTexture {
		var texture:CubeTexture = null;
		
		if ((parsedTexture.name != null || parsedTexture.extensions != null) && parsedTexture.isRenderTarget == false) {
			texture = new CubeTexture(rootUrl + parsedTexture.name, scene, parsedTexture.extensions);
			
			texture.name = parsedTexture.name;
			texture.hasAlpha = parsedTexture.hasAlpha;
			texture.level = parsedTexture.level;
			texture.coordinatesMode = parsedTexture.coordinatesMode;
		}
		
        return texture;
    }
	
	public static function ParseTexture(parsedTexture:Dynamic, scene:Scene, rootUrl:String):BaseTexture {		
        if (parsedTexture.isCube != null && parsedTexture.isCube == true) {
            return BaseTexture.ParseCubeTexture(parsedTexture, scene, rootUrl);
        }
		
		if (parsedTexture.name == null && parsedTexture.isRenderTarget == false) {
            return null;
        }
		
        var texture:Texture = null;
		
        if (parsedTexture.mirrorPlane != null) {
            texture = new MirrorTexture(parsedTexture.name, parsedTexture.renderTargetSize, scene);
            cast(texture, MirrorTexture)._waitingRenderList = parsedTexture.renderList;
            cast(texture, MirrorTexture).mirrorPlane = Plane.FromArray(parsedTexture.mirrorPlane);
        } 
		else if (parsedTexture.isRenderTarget) {
            texture = new RenderTargetTexture(parsedTexture.name, parsedTexture.renderTargetSize, scene);
            cast(texture, RenderTargetTexture)._waitingRenderList = parsedTexture.renderList;
        } 
		else {
            texture = new Texture(rootUrl + parsedTexture.name, scene);
        }
		
        texture.name = parsedTexture.name;
        texture.hasAlpha = parsedTexture.hasAlpha;
		texture.getAlphaFromRGB = parsedTexture.getAlphaFromRGB;
        texture.level = parsedTexture.level;
		
        texture.coordinatesIndex = parsedTexture.coordinatesIndex;
        texture.coordinatesMode = parsedTexture.coordinatesMode;
        texture.uOffset = parsedTexture.uOffset;
        texture.vOffset = parsedTexture.vOffset;
        texture.uScale = parsedTexture.uScale;
        texture.vScale = parsedTexture.vScale;
        texture.uAng = parsedTexture.uAng;
        texture.vAng = parsedTexture.vAng;
        texture.wAng = parsedTexture.wAng;
		
        texture.wrapU = parsedTexture.wrapU;
        texture.wrapV = parsedTexture.wrapV;
		
        // Animations
        if (parsedTexture.animations != null) {
            for (animationIndex in 0...parsedTexture.animations.length) {
                var parsedAnimation = parsedTexture.animations[animationIndex];
				
                texture.animations.push(Animation.Parse(parsedAnimation));
            }
        }
		
        return texture;
    }
	
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		if (this.name == null) {
			return null;
		}
		
		serializationObject.name = this.name;
		serializationObject.hasAlpha = this.hasAlpha;
		serializationObject.level = this.level;
		
		serializationObject.coordinatesIndex = this.coordinatesIndex;
		serializationObject.coordinatesMode = this.coordinatesMode;
		serializationObject.wrapU = this.wrapU;
		serializationObject.wrapV = this.wrapV;
		
		// Animations
		Animation.AppendSerializedAnimations(this, serializationObject);
		
		return serializationObject;
	}
	
}
