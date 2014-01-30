package com.gamestudiohx.babylonhx.materials.textures;

import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.materials.textures.BaseTexture;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.animations.Animation;
import flash.Lib;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLRenderbuffer;
import openfl.gl.GLTexture;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class BabylonTexture {
	
	public var data:GLTexture;
	
	// TODO - Are these really members of this class
	public var _framebuffer:GLFramebuffer;
	public var _depthBuffer:GLRenderbuffer;
	public var generateMipMaps:Bool;	
	public var isCube:Bool;
	public var _size:Float;
	
	public var isReady:Bool;
	public var noMipmap:Bool = true;
	public var references:Int;
	public var url:String;
	
	public var _baseHeight:Int;
	public var _baseWidth:Int;
	public var _cachedWrapU:Int;
	public var _cachedWrapV:Int;
	
	public var _width:Float;	
	public var _height:Float;
	
	
	public function new(url:String, data:GLTexture) {
		this.url = url;
		this.data = data;
		
		this._framebuffer = null;
		this._depthBuffer = null;
		this.generateMipMaps = false;
		this.isCube = false;
		
		this._size = 1;
		this._width = 1;
		this._height = 1;
		this._baseHeight = 1;
		this._baseWidth = 1;
		this._cachedWrapU = -1;
		this._cachedWrapV = -1;
		
		this.isReady = false;
		this.noMipmap = false;
		this.references = 0;
	}
	
}
 
class Texture extends BaseTexture {
	
	// Constants
    public static var NEAREST_SAMPLINGMODE:Int = 1;
    public static var BILINEAR_SAMPLINGMODE:Int = 2;
    public static var TRILINEAR_SAMPLINGMODE:Int = 3;

    public static var EXPLICIT_MODE:Int = 0;
    public static var SPHERICAL_MODE:Int = 1;
    public static var PLANAR_MODE:Int = 2;
    public static var CUBIC_MODE:Int = 3;
    public static var PROJECTION_MODE:Int = 4;
    public static var SKYBOX_MODE:Int = 5;

    public static var CLAMP_ADDRESSMODE:Int = 0;
    public static var WRAP_ADDRESSMODE:Int = 1;
    public static var MIRROR_ADDRESSMODE:Int = 2;
	
	public var uOffset:Float;
	public var _cachedUOffset:Float;
    public var vOffset:Float;
	public var _cachedVOffset:Float;
    public var uScale:Float;
	public var _cachedUScale:Float;
    public var vScale:Float;
	public var _cachedVScale:Float;
    public var uAng:Float;
	public var _cachedUAng:Float;
    public var vAng:Float;
	public var _cachedVAng:Float;
    public var wAng:Float;
	public var _cachedWAng:Float;
    public var wrapU:Int;
    public var wrapV:Int;
    public var coordinatesIndex:Float;
    public var coordinatesMode:Float;
	public var _cachedCoordinatesMode:Float;
    public var anisotropicFilteringLevel:Float;
	public var _cachedAnisotropicFilteringLevel:Float;
	
	public var _rowGenerationMatrix:Matrix;
	public var _cachedTextureMatrix:Matrix;
	public var _projectionModeMatrix:Matrix;
	
	public var _t0:Vector3;
	public var _t1:Vector3;
	public var _t2:Vector3;
	
	public var name:String;
	public var url:String;
	public var animations:Array<Animation>;
	public var _noMipmap:Bool;
	public var _invertY:Null<Bool>;
	
	public function new(url:String, scene:Scene, ?noMipmap:Bool, ?invertY:Bool) {
		super(url, scene);
		
        this.name = url;
        this.url = url;
        this._noMipmap = noMipmap;
        this._invertY = invertY;

		// CubeTexture loads its texture before calling super(), so in that case , _texture is not null
		if(this._texture == null) {
			this._texture = this._getFromCache(url, noMipmap);
		}
		
		if (this._texture == null) {			
			this._texture = scene.getEngine().createTexture(url, noMipmap, invertY != null ? 1 : 0, scene);				
		}
		
		this.uOffset = 0;
		this._cachedUOffset = -1.123412341234;
		this.vOffset = 0;
		this._cachedVOffset = -1.123412341234;
		this.uScale = 1.0;
		this._cachedUScale = -1.123412341234;
		this.vScale = 1.0;
		this._cachedVScale = -1.123412341234;
		this.uAng = 0;
		this._cachedUAng = -1.123412341234;
		this.vAng = 0;
		this._cachedVAng = -1.123412341234;
		this.wAng = 0;
		this._cachedWAng = -1.123412341234;
		this.wrapU = Texture.WRAP_ADDRESSMODE;
		this.wrapV = Texture.WRAP_ADDRESSMODE;
		this.coordinatesIndex = 0;
		this.coordinatesMode = Texture.EXPLICIT_MODE;
		this.anisotropicFilteringLevel = 4;

        // Animations
        this.animations = [];
	}
		
	override public function delayLoad() {
        if (this.delayLoadState != Engine.DELAYLOADSTATE_NOTLOADED) {
            return;
        }
        
        this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
        this._texture = this._getFromCache(this.url, this._noMipmap);

        if (this._texture == null) {
            this._texture = this._scene.getEngine().createTexture(this.url, this._noMipmap, this._invertY ? 1 : 0, this._scene);
        }
    }
	
	public function _prepareRowForTextureGeneration(x:Float, y:Float, z:Float, t:Vector3) {
        x -= this.uOffset + 0.5;
        y -= this.vOffset + 0.5;
        z -= 0.5;

        Vector3.TransformCoordinatesFromFloatsToRef(x, y, z, this._rowGenerationMatrix, t);

        t.x *= this.uScale;
        t.y *= this.vScale;

        t.x += 0.5;
        t.y += 0.5;
        t.z += 0.5;
    }
	
	public function _computeTextureMatrix():Matrix {	
		var ret = this._cachedTextureMatrix;
        if (!(
            this.uOffset == this._cachedUOffset &&
            this.vOffset == this._cachedVOffset &&
            this.uScale == this._cachedUScale &&
            this.vScale == this._cachedVScale &&
            this.uAng == this._cachedUAng &&
            this.vAng == this._cachedVAng &&
            this.wAng == this._cachedWAng)) {
				
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
        }

        return this._cachedTextureMatrix;		
    }
	
	public function _computeReflectionTextureMatrix():Matrix {
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

        switch (this.coordinatesMode) {
            case Texture.SPHERICAL_MODE:
                Matrix.IdentityToRef(this._cachedTextureMatrix);
                this._cachedTextureMatrix.m[0] = -0.5 * this.uScale;
                this._cachedTextureMatrix.m[5] = -0.5 * this.vScale;
                this._cachedTextureMatrix.m[12] = 0.5 + this.uOffset;
                this._cachedTextureMatrix.m[13] = 0.5 + this.vOffset;
                
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

                this._scene.getProjectionMatrix().multiplyToRef(this._projectionModeMatrix, this._cachedTextureMatrix);
                
            default:
                Matrix.IdentityToRef(this._cachedTextureMatrix);
                
        }
        return this._cachedTextureMatrix;
    }
	
	public function clone():Texture {
        var newTexture:Texture = new Texture(this._texture.url, this._scene, this._noMipmap, this._invertY);

        // Base texture
        newTexture.hasAlpha = this.hasAlpha;
        newTexture.level = this.level;

        // Texture
        newTexture.uOffset = this.uOffset;
        newTexture.vOffset = this.vOffset;
        newTexture.uScale = this.uScale;
        newTexture.vScale = this.vScale;
        newTexture.uAng = this.uAng;
        newTexture.vAng = this.vAng;
        newTexture.wAng = this.wAng;
        newTexture.wrapU = this.wrapU;
        newTexture.wrapV = this.wrapV;
        newTexture.coordinatesIndex = this.coordinatesIndex;
        newTexture.coordinatesMode = this.coordinatesMode;

        return newTexture;
    }
	
}
