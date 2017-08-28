package com.babylonhx.materials.textures;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Plane;
import com.babylonhx.animations.Animation;
import com.babylonhx.utils.Image;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Texture') class Texture extends BaseTexture {
	
	// Constants
	public static inline var NEAREST_SAMPLINGMODE:Int = 1;
	public static inline var NEAREST_NEAREST_MIPLINEAR:Int = 1; // nearest is mag = nearest and min = nearest and mip = linear
	
	public static inline var BILINEAR_SAMPLINGMODE:Int = 2;
	public static inline var LINEAR_LINEAR_MIPNEAREST:Int = 2; // Bilinear is mag = linear and min = linear and mip = nearest
	
	public static inline var TRILINEAR_SAMPLINGMODE:Int = 3;
	public static inline var LINEAR_LINEAR_MIPLINEAR:Int = 3; // Trilinear is mag = linear and min = linear and mip = linear
	
	public static inline var NEAREST_NEAREST_MIPNEAREST:Int = 4;
	public static inline var NEAREST_LINEAR_MIPNEAREST:Int = 5;
	public static inline var NEAREST_LINEAR_MIPLINEAR:Int = 6;
	public static inline var NEAREST_LINEAR:Int = 7;
	public static inline var NEAREST_NEAREST = 8;
	public static inline var LINEAR_NEAREST_MIPNEAREST:Int = 9;
	public static inline var LINEAR_NEAREST_MIPLINEAR:Int = 10;
	public static inline var LINEAR_LINEAR:Int = 11;
	public static inline var LINEAR_NEAREST:Int = 12;

	public static inline var EXPLICIT_MODE:Int = 0;
	public static inline var SPHERICAL_MODE:Int = 1;
	public static inline var PLANAR_MODE:Int = 2;
	public static inline var CUBIC_MODE:Int = 3;
	public static inline var PROJECTION_MODE:Int = 4;
	public static inline var SKYBOX_MODE:Int = 5;
	public static inline var INVCUBIC_MODE:Int = 6;
	public static inline var EQUIRECTANGULAR_MODE:Int = 7;
	public static inline var FIXED_EQUIRECTANGULAR_MODE:Int = 8;
	public static inline var FIXED_EQUIRECTANGULAR_MIRRORED_MODE:Int = 9;

	public static inline var CLAMP_ADDRESSMODE:Int = 0;
	public static inline var WRAP_ADDRESSMODE:Int = 1;
	public static inline var MIRROR_ADDRESSMODE:Int = 2;

	// Members
	@serialize()
	public var url:String;
	
	// VK: Moved to BaseTexture.hx to avoid casting when using
	/*@serialize()
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
	public var wAng:Float = 0;*/

	private var _noMipmap:Bool;
	
	public var noMipmap(get, never):Bool;
	inline private function get_noMipmap():Bool {
		return this._noMipmap;
	}
	
	public var _invertY:Bool;
	private var _rowGenerationMatrix:Matrix;
	private var _cachedTextureMatrix:Matrix;
	private var _projectionModeMatrix:Matrix;
	private var _t0:Vector3;
	private var _t1:Vector3;
	private var _t2:Vector3;

	private var _cachedUOffset:Float;
	private var _cachedVOffset:Float;
	private var _cachedUScale:Float;
	private var _cachedVScale:Float;
	private var _cachedUAng:Float;
	private var _cachedVAng:Float;
	private var _cachedWAng:Float;
	private var _cachedProjectionMatrixId:Int;
	private var _cachedCoordinatesMode:Int;
	public var _samplingMode:Int;
	private var _buffer:Dynamic;
	private var _deleteBuffer:Bool;
	public var _format:Int;
	private var _delayedOnLoad:Void->Void;
	private var _delayedOnError:Void->Void;
	private var _onLoadObservable:Observable<Bool>;
	
	// MOVED TO BaseTexture for BHX !!!
	/*private var _isBlocking:Bool = true;
	@serialize()
	public var isBlocking(get, set):Bool;
	private function set_isBlocking(value:Bool):Bool {
		return this._isBlocking = value;
	}
	private function get_isBlocking():Bool {
		return this._isBlocking;
	}*/
	
	public var samplingMode(get, never):Int;
	inline private function get_samplingMode():Int {
		return _samplingMode;
	}
	
	// BHx: for creating from Image
	public static var _tmpImage:Image;

	
	public function new(url:String, scene:Scene, noMipmap:Bool = false, invertY:Bool = true, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, onLoad:Void->Void = null, onError:Void->Void = null, buffer:Dynamic = null, deleteBuffer:Bool = false, ?format:Int) {
		super(scene);
		
		this.name = url;
		this.url = url;
		this._noMipmap = noMipmap;
		this._invertY = invertY;
		this._samplingMode = samplingMode;
		this._buffer = buffer;
		this._deleteBuffer = deleteBuffer;
		this._format = format;
		
		if (url == null || StringTools.trim(url) == "") {
			return;
		}
		
		this._texture = this._getFromCache(url, noMipmap, samplingMode);
		
		var load = function() {
			if (this._onLoadObservable != null && this._onLoadObservable.hasObservers()) {
				this.onLoadObservable.notifyObservers(true);
			}
			if (onLoad != null) {
				onLoad();
			}
			
			if (!this.isBlocking) {
				scene.resetCachedMaterial();
			}
		};
		
		if (this._texture == null) {
			if (StringTools.startsWith(url, "from_image") && _tmpImage != null) {	// VK: DO NOT REMOVE!!
				this._texture = scene.getEngine().createTextureFromImage(_tmpImage, noMipmap, scene, this._samplingMode);
				_tmpImage = null;
			}
			else if (!scene.useDelayedTextureLoading) {
				if(url.indexOf(".") != -1) {	// protection for cube texture, url is not full path !
					this._texture = scene.getEngine().createTexture(url, noMipmap, invertY, scene, this._samplingMode, load, onError, this._buffer);
					if (deleteBuffer) {
						this._buffer = null;
					}
				}
			} 
			else {
				this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
				
				this._delayedOnLoad = load;
				this._delayedOnError = onError;
			}
		}
		else {
			if (this._texture.isReady) {
				Tools.SetImmediate(load);
			} 
			else {
				this._texture.onLoadedObservable.add(cast load);
			}
		}
	}
	
	public function updateURL(url:String) {
		this.url = url;
		this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
		this.delayLoad();
	}

	override public function delayLoad() {
		if (this.delayLoadState != Engine.DELAYLOADSTATE_NOTLOADED) {
			return;
		}
		
		this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
		this._texture = this._getFromCache(this.url, this._noMipmap, this._samplingMode);
		
		if (this._texture == null) {
			this._texture = this.getScene().getEngine().createTexture(this.url, this._noMipmap, this._invertY, this.getScene(), this._samplingMode, null, null, this._buffer);
			if (this._deleteBuffer) {
				this._buffer = null;
			}
		}
		else {
			if (this._texture.isReady) {
				Tools.SetImmediate(function() { this._delayedOnLoad(); });
			} 
			else {
				this._texture.onLoadedObservable.add(cast this._delayedOnLoad);
			}
		}
	}
	
	public function updateSamplingMode(samplingMode:Int) {
        if (this._texture == null) {
            return;
        }
		
		this._samplingMode = samplingMode;
        this.getScene().getEngine().updateTextureSamplingMode(samplingMode, this._texture);
    }

	private function _prepareRowForTextureGeneration(x:Float, y:Float, z:Float, t:Vector3) {
		x *= this.uScale;
		y *= this.vScale;
		
		x -= 0.5 * this.uScale;
		y -= 0.5 * this.vScale;
		z -= 0.5;
		
		Vector3.TransformCoordinatesFromFloatsToRef(x, y, z, this._rowGenerationMatrix, t);
		
		t.x += 0.5 * this.uScale + this.uOffset;
		t.y += 0.5 * this.vScale + this.vOffset;
		t.z += 0.5;
	}

	override public function getTextureMatrix():Matrix {
		if (
			this.uOffset == this._cachedUOffset &&
			this.vOffset == this._cachedVOffset &&
			this.uScale == this._cachedUScale &&
			this.vScale == this._cachedVScale &&
			this.uAng == this._cachedUAng &&
			this.vAng == this._cachedVAng &&
			this.wAng == this._cachedWAng) {
			return this._cachedTextureMatrix;
		}
		
		this._cachedUOffset = this.uOffset;
		this._cachedVOffset = this.vOffset;
		this._cachedUScale = this.uScale;
		this._cachedVScale = this.vScale;
		this._cachedUAng = this.uAng;
		this._cachedVAng = this.vAng;
		this._cachedWAng = this.wAng;
		
		if (this._cachedTextureMatrix == null) {
			this._cachedTextureMatrix = Matrix.Zero();
			this._rowGenerationMatrix = new Matrix();
			this._t0 = Vector3.Zero();
			this._t1 = Vector3.Zero();
			this._t2 = Vector3.Zero();
		}
		
		Matrix.RotationYawPitchRollToRef(this.vAng, this.uAng, this.wAng, this._rowGenerationMatrix);
		
		this._prepareRowForTextureGeneration(0, 0, 0, this._t0);
		this._prepareRowForTextureGeneration(1.0, 0, 0, this._t1);
		this._prepareRowForTextureGeneration(0, 1.0, 0, this._t2);
		
		this._t1.subtractInPlace(this._t0);
		this._t2.subtractInPlace(this._t0);
		
		Matrix.IdentityToRef(this._cachedTextureMatrix);
		this._cachedTextureMatrix.m[0] = this._t1.x; this._cachedTextureMatrix.m[1] = this._t1.y; this._cachedTextureMatrix.m[2] = this._t1.z;
		this._cachedTextureMatrix.m[4] = this._t2.x; this._cachedTextureMatrix.m[5] = this._t2.y; this._cachedTextureMatrix.m[6] = this._t2.z;
		this._cachedTextureMatrix.m[8] = this._t0.x; this._cachedTextureMatrix.m[9] = this._t0.y; this._cachedTextureMatrix.m[10] = this._t0.z;
		
		this.getScene().markAllMaterialsAsDirty(Material.TextureDirtyFlag, function(mat:Material) {
            return mat.hasTexture(this);
        });
		
		return this._cachedTextureMatrix;
	}

	override public function getReflectionTextureMatrix():Matrix {
		var scene = this.getScene();
		if (
			this.uOffset == this._cachedUOffset &&
			this.vOffset == this._cachedVOffset &&
			this.uScale == this._cachedUScale &&
			this.vScale == this._cachedVScale &&
			this.coordinatesMode == this._cachedCoordinatesMode) {
			if (this.coordinatesMode == Texture.PROJECTION_MODE) {
				if (this._cachedProjectionMatrixId == scene.getProjectionMatrix().updateFlag) {
					return this._cachedTextureMatrix;
				}
			} 
			else {
				return this._cachedTextureMatrix;
			}
		}
		
		if (this._cachedTextureMatrix == null) {
			this._cachedTextureMatrix = Matrix.Zero();
			this._projectionModeMatrix = Matrix.Zero();
		}
		
		this._cachedUOffset = this.uOffset;
        this._cachedVOffset = this.vOffset;
        this._cachedUScale = this.uScale;
        this._cachedVScale = this.vScale;
		this._cachedCoordinatesMode = this.coordinatesMode;
		
		switch (this.coordinatesMode) {	                
			case Texture.PLANAR_MODE:
				Matrix.IdentityToRef(this._cachedTextureMatrix);
				this._cachedTextureMatrix.m[0] = this.uScale;
				this._cachedTextureMatrix.m[5] = this.vScale;
				this._cachedTextureMatrix.m[12] = this.uOffset;
				this._cachedTextureMatrix.m[13] = this.vOffset;
				
			case Texture.PROJECTION_MODE:
				Matrix.IdentityToRef(this._projectionModeMatrix);
				
				this._projectionModeMatrix.m[0] = 0.5;
				this._projectionModeMatrix.m[5] = -0.5;
				this._projectionModeMatrix.m[10] = 0.0;
				this._projectionModeMatrix.m[12] = 0.5;
				this._projectionModeMatrix.m[13] = 0.5;
				this._projectionModeMatrix.m[14] = 1.0;
				this._projectionModeMatrix.m[15] = 1.0;
				
				var projectionMatrix = scene.getProjectionMatrix();
                this._cachedProjectionMatrixId = projectionMatrix.updateFlag;
                projectionMatrix.multiplyToRef(this._projectionModeMatrix, this._cachedTextureMatrix);
				
			default:
				Matrix.IdentityToRef(this._cachedTextureMatrix);
			
		}
		
		scene.markAllMaterialsAsDirty(Material.TextureDirtyFlag, function(mat:Material) {
            return (mat.getActiveTextures().indexOf(this) != -1);
        });
		
		return this._cachedTextureMatrix;
	}
	
	public static function fromImage(img:Image, scene:Scene, noMipmap:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):Texture {
		Texture._tmpImage = img;
		var tex:Texture = new Texture("from_image", scene, noMipmap, false, samplingMode);
		return tex;
	}
	
	public var onLoadObservable(get, never):Observable<Bool>;
	private function get_onLoadObservable():Observable<Bool> {
		if (this._onLoadObservable == null) {
			this._onLoadObservable = new Observable<Bool>();
		}
		return this._onLoadObservable;
	}

	override public function clone():Texture {
		return SerializationHelper.Clone(function() {
			return new Texture(this._texture.url, this.getScene(), this._noMipmap, this._invertY, this._samplingMode);
		}, this);
	}
	
	override public function serialize():Dynamic {		
		var serializationObject = super.serialize();
		
		if (Std.is(this._buffer, String) && this._buffer.substr(0, 5) == "data:") {
			serializationObject.base64String = this._buffer;
			serializationObject.name = StringTools.replace(serializationObject.name, "data:", "");
		}
		
		return serializationObject;
	}
	
	override public function getClassName():String {
		return "Texture";
	}
	
	override public function dispose() {
        super.dispose();
		
        if (this.onLoadObservable != null) {
            this.onLoadObservable.clear();
            this._onLoadObservable = null;
        }
		
        this._delayedOnLoad = null;
        this._delayedOnError = null;
    }
	
	// Statics
	public static function CreateFromBase64String(data:String, name:String, scene:Scene, ?noMipmap:Bool, ?invertY:Bool, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, ?onLoad:Void->Void, ?onError:Void->Void):Texture {
		return new Texture("data:" + name, scene, noMipmap, invertY, samplingMode, onLoad, onError, data);
	}
	
	public static function CreateFromImage(data:Image, name:String, scene:Scene, ?noMipmap:Bool, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):Texture {
		_tmpImage = data;
		
		return new Texture("from_image" + name, scene, noMipmap, false, samplingMode);
	}
	
	public static function Parse(parsedTexture:Dynamic, scene:Scene, rootUrl:String):BaseTexture {
		if (parsedTexture.customType) { 
			var customTexture = Type.createEmptyInstance(parsedTexture.customType);
			return customTexture.Parse(parsedTexture, scene, rootUrl);
		}
			
		if (parsedTexture.isCube) {
			return CubeTexture.Parse(parsedTexture, scene, rootUrl);
		}
		
		if (parsedTexture.name == null && !parsedTexture.isRenderTarget) {
			return null;
		}
		
		var texture:Texture = null;
		
		if (parsedTexture.mirrorPlane) {
			texture = new MirrorTexture(parsedTexture.name, parsedTexture.renderTargetSize, scene);
			cast(texture, MirrorTexture)._waitingRenderList = parsedTexture.renderList;
			cast(texture, MirrorTexture).mirrorPlane = Plane.FromArray(parsedTexture.mirrorPlane);
		} 
		else if (parsedTexture.isRenderTarget) {
			texture = new RenderTargetTexture(parsedTexture.name, parsedTexture.renderTargetSize, scene);
			cast(texture, RenderTargetTexture)._waitingRenderList = parsedTexture.renderList;
		} 
		else {
			if (parsedTexture.base64String) {
				texture = Texture.CreateFromBase64String(parsedTexture.base64String, parsedTexture.name, scene);
			} 
			else {
				texture = new Texture(rootUrl + parsedTexture.name, scene);
			}
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
	
}
