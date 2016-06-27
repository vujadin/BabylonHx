package com.babylonhx.materials.textures;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Plane;
import com.babylonhx.animations.Animation;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Texture') class Texture extends BaseTexture {
	
	// Constants
	public static inline var NEAREST_SAMPLINGMODE:Int = 1;
	public static inline var BILINEAR_SAMPLINGMODE:Int = 2;
	public static inline var TRILINEAR_SAMPLINGMODE:Int = 3;

	public static inline var EXPLICIT_MODE:Int = 0;
	public static inline var SPHERICAL_MODE:Int = 1;
	public static inline var PLANAR_MODE:Int = 2;
	public static inline var CUBIC_MODE:Int = 3;
	public static inline var PROJECTION_MODE:Int = 4;
	public static inline var SKYBOX_MODE:Int = 5;
	public static inline var INVCUBIC_MODE:Int = 6;
	public static inline var EQUIRECTANGULAR_MODE:Int = 7;
	public static inline var FIXED_EQUIRECTANGULAR_MODE:Int = 8;

	public static inline var CLAMP_ADDRESSMODE:Int = 0;
	public static inline var WRAP_ADDRESSMODE:Int = 1;
	public static inline var MIRROR_ADDRESSMODE:Int = 2;

	// Members
	public var url:String;
	public var uOffset:Float = 0;
	public var vOffset:Float = 0;
	public var uScale:Float = 1.0;
	public var vScale:Float = 1.0;
	public var uAng:Float = 0;
	public var vAng:Float = 0;
	public var wAng:Float = 0;

	private var _noMipmap:Bool;
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
	private var _cachedCoordinatesMode:Int;
	public var _samplingMode:Int;
	private var _buffer:Dynamic;
	private var _deleteBuffer:Bool;

	
	public function new(url:String, scene:Scene, noMipmap:Bool = false, invertY:Bool = true, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, onLoad:Void->Void = null, onError:Void->Void = null, buffer:Dynamic = null, deleteBuffer:Bool = false) {
		super(scene);
		
		this.name = url;
		this.url = url;
		this._noMipmap = noMipmap;
		this._invertY = invertY;
		this._samplingMode = samplingMode;
		this._buffer = buffer;
		this._deleteBuffer = deleteBuffer;
		
		if (url == null || StringTools.trim(url) == "") {
			return;
		}
		
		this._texture = this._getFromCache(url, noMipmap, samplingMode);
		
		if (this._texture == null) {
			if (!scene.useDelayedTextureLoading) {
				if(url.indexOf(".") != -1) {	// protection for cube texture, url is not full path !
					this._texture = scene.getEngine().createTexture(url, noMipmap, invertY, scene, this._samplingMode, onLoad, onError, this._buffer);
					if (deleteBuffer) {
						this._buffer = null;
					}
				}
			} 
			else {
				this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
			}
		}
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
	}
	
	public function updateSamplingMode(samplingMode:Int) {
        if (this._texture == null) {
            return;
        }
		
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
		
		return this._cachedTextureMatrix;
	}

	override public function getReflectionTextureMatrix():Matrix {
		if (
			this.uOffset == this._cachedUOffset &&
			this.vOffset == this._cachedVOffset &&
			this.uScale == this._cachedUScale &&
			this.vScale == this._cachedVScale &&
			this.coordinatesMode == this._cachedCoordinatesMode) {
			return this._cachedTextureMatrix;
		}
		
		if (this._cachedTextureMatrix == null) {
			this._cachedTextureMatrix = Matrix.Zero();
			this._projectionModeMatrix = Matrix.Zero();
		}
		
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
				
				this.getScene().getProjectionMatrix().multiplyToRef(this._projectionModeMatrix, this._cachedTextureMatrix);
				
			default:
				Matrix.IdentityToRef(this._cachedTextureMatrix);
			
		}
		
		return this._cachedTextureMatrix;
	}

	override public function clone():Texture {
		var newTexture = new Texture(this._texture.url, this.getScene(), this._noMipmap, this._invertY, this._samplingMode);
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		newTexture.wrapU = this.wrapU;
		newTexture.wrapV = this.wrapV;
		newTexture.coordinatesIndex = this.coordinatesIndex;
		newTexture.coordinatesMode = this.coordinatesMode;
		
		// Texture
		newTexture.uOffset = this.uOffset;
		newTexture.vOffset = this.vOffset;
		newTexture.uScale = this.uScale;
		newTexture.vScale = this.vScale;
		newTexture.uAng = this.uAng;
		newTexture.vAng = this.vAng;
		newTexture.wAng = this.wAng;
		newTexture.anisotropicFilteringLevel = this.anisotropicFilteringLevel;
		newTexture.getAlphaFromRGB = this.getAlphaFromRGB;
		
		return newTexture;
	}
	
	override public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject = super.serialize();
		
		serializationObject.uOffset = this.uOffset;
		serializationObject.vOffset = this.vOffset;
		serializationObject.uScale = this.uScale;
		serializationObject.vScale = this.vScale;
		serializationObject.uAng = this.uAng;
		serializationObject.vAng = this.vAng;
		serializationObject.wAng = this.wAng;
		serializationObject.anisotropicFilteringLevel = this.anisotropicFilteringLevel;
		serializationObject.getAlphaFromRGB = this.getAlphaFromRGB;
		
		return serializationObject;
	}
	
	// Statics
	public static function CreateFromBase64String(data:String, name:String, scene:Scene, ?noMipmap:Bool, ?invertY:Bool, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, ?onLoad:Void->Void, ?onError:Void->Void):Texture {
		return new Texture("data:" + name, scene, noMipmap, invertY, samplingMode, onLoad, onError, data);
	}
	
	public static function Parse(parsedTexture:Dynamic, scene:Scene, rootUrl:String):BaseTexture {
		if (parsedTexture.isCube) {
			return CubeTexture.Parse(parsedTexture, scene, rootUrl);
		}
		
		if (parsedTexture.name == null && !parsedTexture.isRenderTarget) {
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
