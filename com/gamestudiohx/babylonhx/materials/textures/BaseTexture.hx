package com.gamestudiohx.babylonhx.materials.textures;

import com.gamestudiohx.babylonhx.materials.textures.Texture;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.Engine;
import flash.display.BitmapData;
import openfl.gl.GLTexture;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class BaseTexture {
	
	public var _scene:Scene;
	public var delayLoadState:Int;
    public var hasAlpha:Bool = false;
    public var level:Float = 1.0;
	
	public var _texture:BabylonTexture;		// TODO - it can be BabylonTexture or Texture ?

    public var onDispose:Void->Void;

	public function new(url:String, scene:Scene) {
		this._scene = scene;
        this._scene.textures.push(this);
		delayLoadState = Engine.DELAYLOADSTATE_NONE;
	}
	
	public function getInternalTexture():BabylonTexture {
        return this._texture;
    }
	
	public function isReady():Bool {
        if (this._texture != null) {
            return this._texture.isReady;
        }
		
        return false;
    }
	
	public function getSize():Dynamic {
        if (this._texture._width != -1) {
            return { width: this._texture._width, height: this._texture._height };
        }

        if (this._texture._size != -1) {
            return { width: this._texture._size, height: this._texture._size };
        }

        return { width: 0, height: 0 };
    }
	
	public function getBaseSize():Dynamic {
        if (!this.isReady())
            return { width: 0, height: 0 };

        if (this._texture._size != -1) {
            return { width: this._texture._size, height: this._texture._size };
        }

        return { width: this._texture._baseWidth, height: this._texture._baseHeight };
    }
	
	public function _getFromCache(url:String, noMipmap:Bool):BabylonTexture {
        var texturesCache:Array<BabylonTexture> = this._scene.getEngine().getLoadedTexturesCache();
        for (index in 0...texturesCache.length) {
            var texturesCacheEntry:BabylonTexture = texturesCache[index];

            if (texturesCacheEntry.url == url && texturesCacheEntry.noMipmap == noMipmap) {
                texturesCacheEntry.references++;
                return texturesCacheEntry;
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
            //var index = Lambda.indexOf(texturesCache, this._texture);
            //texturesCache.splice(index, 1);
			texturesCache.remove(this._texture);

            this._scene.getEngine()._releaseTexture(this._texture);

            this._texture = null;
        }
    }
	
	public function dispose() {
        // Remove from scene
        var index:Int = Lambda.indexOf(this._scene.textures, this);

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
