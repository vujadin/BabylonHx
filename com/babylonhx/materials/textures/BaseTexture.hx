package com.babylonhx.materials.textures;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.math.Matrix;

#if nme
import nme.gl.GLTexture;
#elseif openfl
import openfl.gl.GLTexture;
#elseif snow
import snow.render.opengl.GL;
#elseif kha

#end

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
	public var onDispose:Void->Void;
	public var coordinatesIndex:Int = 0;
	public var coordinatesMode:Int = Texture.EXPLICIT_MODE;
	public var wrapU:Int = Texture.WRAP_ADDRESSMODE;
	public var wrapV:Int = Texture.WRAP_ADDRESSMODE;
	public var anisotropicFilteringLevel:Int = 4;
	public var _cachedAnisotropicFilteringLevel:Int;
	
	public var __smartArrayFlags:Array<Int>;

	private var _scene:Scene;
	public var _texture:BabylonTexture;
	

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

	public function getInternalTexture():BabylonTexture {
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
		if (!this.isReady())
			return { width: 0, height: 0 };
			
		if (this._texture._size != null) {
			return { width: this._texture._size, height: this._texture._size };
		}
		
		return { width: this._texture._baseWidth, height: this._texture._baseHeight };
	}

	public function scale(ratio:Float) {
	}

	/*public var canRescale(get, never):Bool;
	private function get_canRescale():Bool {
		return false;
	}*/

	public function _removeFromCache(url:String, noMipmap:Bool) {
		var texturesCache:Array<BabylonTexture> = this._scene.getEngine().getLoadedTexturesCache();
		for (index in 0...texturesCache.length) {
			var texturesCacheEntry = texturesCache[index];
			
			if (texturesCacheEntry.url == url && texturesCacheEntry.noMipmap == noMipmap) {
				texturesCache.splice(index, 1);
				return;
			}
		}
	}

	public function _getFromCache(url:String, noMipmap:Bool, ?sampling:Int):BabylonTexture {
        var texturesCache:Array<BabylonTexture> = this._scene.getEngine().getLoadedTexturesCache();
        for (index in 0...texturesCache.length) {
            var texturesCacheEntry:BabylonTexture = texturesCache[index];
			
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
		
        var texturesCache:Array<BabylonTexture> = this._scene.getEngine().getLoadedTexturesCache();
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
		if (this.onDispose != null) {
			this.onDispose();
		}
	}
	
}
