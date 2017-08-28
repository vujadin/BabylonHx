package com.babylonhx.materials.textures;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.SphericalPolynomial;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.hdr.CubeMapToSphericalPolynomialTools;

import lime.utils.ArrayBufferView;
import lime.utils.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BaseTexture') class BaseTexture implements IAnimatable implements ISmartArrayCompatible {
	
	public static var DEFAULT_ANISOTROPIC_FILTERING_LEVEL:Int = 4;
	
	@serialize()
	public var name:String;

	@serialize("hasAlpha")
	private var _hasAlpha:Bool = false;
	public var hasAlpha(get, set):Bool;
	private function set_hasAlpha(value:Bool):Bool {
		if (this._hasAlpha == value) {
			return value;
		}
		this._hasAlpha = value;
		this._scene.markAllMaterialsAsDirty(Material.TextureDirtyFlag);
		return value;
	}
	private function get_hasAlpha():Bool {
		return this._hasAlpha;
	}    

	@serialize()
	public var getAlphaFromRGB:Bool = false;

	@serialize()
	public var level:Float = 1;

	@serialize()
	public var coordinatesIndex:Int = 0;

	@serialize("coordinatesMode")
	private var _coordinatesMode:Int = Texture.EXPLICIT_MODE;
	public var coordinatesMode(get, set):Int;
	private function set_coordinatesMode(value:Int):Int {
		if (this._coordinatesMode == value) {
			return value;
		}
		this._coordinatesMode = value;
		this._scene.markAllMaterialsAsDirty(Material.TextureDirtyFlag);
		return value;
	}
	inline private function get_coordinatesMode():Int {
		return this._coordinatesMode;
	}
	
	@serialize()
	public var uOffset:Float = 0;
	
	@serialize()
	public var vOffset:Float = 0;
	
	@serialize()
	public var uScale:Float = 1.0;
	
	@serialize()
	public var vScale:Float = 1.0;
	
	@serialize()
	public var uAng:Float = 0;
	
	@serialize()
	public var vAng:Float = 0;
	
	@serialize()
	public var wAng:Float = 0;

	@serialize()
	public var wrapU:Int = Texture.WRAP_ADDRESSMODE;

	@serialize()
	public var wrapV:Int = Texture.WRAP_ADDRESSMODE;

	@serialize()
	public var anisotropicFilteringLevel:Int = BaseTexture.DEFAULT_ANISOTROPIC_FILTERING_LEVEL;

	@serialize()
	public var isCube:Bool = false;
	
	@serialize()
	public var gammaSpace:Bool = true;

	@serialize()
	public var invertZ:Bool = false;

	@serialize()
	public var lodLevelInAlpha:Bool = false;

	@serialize()
	public var lodGenerationOffset:Float = 0.0;

	@serialize()
	public var lodGenerationScale:Float = 0.8;

	@serialize()
	public var isRenderTarget:Bool = false;

	public var uid(get, never):String;
	private function get_uid():String {
		if (this._uid == null) {
			this._uid = Tools.uuid();
		}
		return this._uid;
	}
	
	private function toString():String {
		return this.name;
	}
	
	public function getClassName():String {
		return "BaseTexture";
	}

	public var animations:Array<Animation> = [];
	
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
	
	public var delayLoadState:Int = Engine.DELAYLOADSTATE_NONE;

	public var _cachedAnisotropicFilteringLevel:Int;

	private var _scene:Scene;
	public var _texture:InternalTexture;
	private var _uid:String;
	
	private var _isBlocking:Bool = true;
	@serialize()
	public var isBlocking(get, set):Bool;
	private function set_isBlocking(value:Bool):Bool {
		return this._isBlocking = value;
	}
	private function get_isBlocking():Bool {
		return this._isBlocking;
	}
	
	public var __smartArrayFlags:Array<Int> = [];	// BHX
	
	public var __serializableMembers:Dynamic;		// BHX
	

	public function new(scene:Scene) {
		this._scene = scene;
		this._scene.textures.push(this);
		this._uid = null;
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

	public function getInternalTexture():InternalTexture {
		return this._texture;
	}
	
	public function isReadyOrNotBlocking():Bool {
		return !this.isBlocking || this.isReady();
	}

	public function isReady():Bool {
		if (this.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) {
			this.delayLoad();
			return true;
		}
		
		if (this._texture != null) {
			return this._texture.isReady;
		}
		
		return false;
	}

	public function getSize():Dynamic  {
		if (this._texture.width != -1 && this._texture.width != 0) {
			return { width: this._texture.width, height: this._texture.height };
		}
		
		if (this._texture._size != -1) {
			return { width: this._texture._size, height: this._texture._size };
		}
		
		return { width: 0, height: 0 };
	}

	public function getBaseSize():Dynamic {
		if (!this.isReady() || this._texture == null) {
			return { width: 0, height: 0 };
		}
		
		if (this._texture._size != -1) {
			return { width: this._texture._size, height: this._texture._size };
		}
		
		return { width: this._texture.baseWidth, height: this._texture.baseHeight };
	}

	public function scale(ratio:Float) { }

	/*public var canRescale(get, never):Bool;
	private function get_canRescale():Bool {
		return false;
	}*/

	public function _getFromCache(url:String, noMipmap:Bool, ?sampling:Int):InternalTexture {
        var texturesCache:Array<InternalTexture> = this._scene.getEngine().getLoadedTexturesCache();
        for (index in 0...texturesCache.length) {
            var texturesCacheEntry:InternalTexture = texturesCache[index];
			
            if (texturesCacheEntry.url == url && texturesCacheEntry.generateMipMaps == !noMipmap) {
				if(sampling == null || sampling == texturesCacheEntry.samplingMode) {
					texturesCacheEntry.incrementReferences();
					return texturesCacheEntry;
				}
            }
        }
		
        return null;
    }
	
	public function _rebuild() {
		
	}

	public function delayLoad() {
		
	}
	
	public var textureType(get, never):Int;
	private function get_textureType():Int {
		if (this._texture == null) {
			return Engine.TEXTURETYPE_UNSIGNED_INT;
		}
		
		return (this._texture.type != -1) ? this._texture.type : Engine.TEXTURETYPE_UNSIGNED_INT;
	}
	
	public function readPixels(faceIndex:Int = 0, lodIndex:Int = 0):ArrayBufferView {
		if (this._texture == null) {
			return null;
		}
		
		var size = this.getSize();
		var engine = this.getScene().getEngine();
		
		if (this._texture.isCube) {
			return engine._readTexturePixels(this._texture, size.width, size.height, faceIndex);
		}
		
		return engine._readTexturePixels(this._texture, size.width, size.height, -1);
	}

	public function releaseInternalTexture() {
        if (this._texture != null) {
			this._texture.dispose();
			this._texture = null;
		}
    }
	
	public var sphericalPolynomial(get, set):SphericalPolynomial;
	private function get_sphericalPolynomial():SphericalPolynomial {
		if (this._texture == null || !this.isReady()) {
			return null;
		}
		
		if (this._texture._sphericalPolynomial == null) {
			this._texture._sphericalPolynomial = CubeMapToSphericalPolynomialTools.ConvertCubeMapTextureToSphericalPolynomial(this);
		}
		
		return this._texture._sphericalPolynomial;
	}
	private function set_sphericalPolynomial(value:SphericalPolynomial):SphericalPolynomial {
		if (this._texture != null) {
			this._texture._sphericalPolynomial = value;
		}
		return value;
	}

	public var _lodTextureHigh(get, never):BaseTexture;
	private function get__lodTextureHigh():BaseTexture {
		if (this._texture != null) {
			return this._texture._lodTextureHigh;
		}
		return null;
	}
	
	public var _lodTextureMid(get, never):BaseTexture;
	private function get__lodTextureMid():BaseTexture {
		if (this._texture != null) {
			return this._texture._lodTextureMid;
		}
		return null;
	}

	public var _lodTextureLow(get, never):BaseTexture;
	private function get__lodTextureLow():BaseTexture {
		if (this._texture != null) {
			return this._texture._lodTextureLow;
		}
		return null;
	}

	public function clone():BaseTexture {
		return null;
	}

	public function dispose() {
		// Animations
        this.getScene().stopAnimation(this);
		
		// Remove from scene
		this._scene._removePendingData(this);
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
