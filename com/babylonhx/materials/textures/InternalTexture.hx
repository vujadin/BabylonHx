package com.babylonhx.materials.textures;

import com.babylonhx.tools.Observable;
import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.math.SphericalPolynomial;

import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class InternalTexture implements ISmartArrayCompatible {
	
	public static inline var DATASOURCE_UNKNOWN:Int = 0;
	public static inline var DATASOURCE_URL:Int = 1;
	public static inline var DATASOURCE_TEMP:Int = 2;
	public static inline var DATASOURCE_RAW:Int = 3;
	public static inline var DATASOURCE_DYNAMIC:Int = 4;
	public static inline var DATASOURCE_RENDERTARGET:Int = 5;
	public static inline var DATASOURCE_MULTIRENDERTARGET:Int = 6;
	public static inline var DATASOURCE_CUBE:Int = 7;
	public static inline var DATASOURCE_CUBELOD:Int = 8;
	public static inline var DATASOURCE_CUBERAW:Int = 9;

	public var isReady:Bool = false;
	public var isCube:Bool = false;
	public var url:String;
	public var samplingMode:Int;
	public var generateMipMaps:Bool;
	public var samples:Int;
	public var type:Int = -1;
	public var format:Int;
	public var onLoadedObservable:Observable<InternalTexture> = new Observable<InternalTexture>();
	public var width:Int = 1;
	public var height:Int = 1;
	public var baseWidth:Int = 1;
	public var baseHeight:Int = 1;
	public var invertY:Bool = false;

	// Private
	private var _dataSource:Int = InternalTexture.DATASOURCE_UNKNOWN;
	public var _size:Int = -1;
	//public var _workingCanvas:HTMLCanvasElement;
	//public var _workingContext:CanvasRenderingContext2D;
	public var _framebuffer:GLFramebuffer;
	public var _depthStencilBuffer:GLRenderbuffer;
	public var _MSAAFramebuffer:GLFramebuffer;
	public var _MSAARenderBuffer:GLRenderbuffer;
	public var _cachedCoordinatesMode:Int = -1;
	public var _cachedWrapU:Int = -1;
	public var _cachedWrapV:Int = -1;
	public var _isDisabled:Bool;
	public var _generateStencilBuffer:Bool;
	public var _generateDepthBuffer:Bool;
	public var _sphericalPolynomial:SphericalPolynomial;
	// The following three fields helps sharing generated fixed LODs for texture filtering
	// In environment not supporting the textureLOD extension like EDGE. They are for internal use only.
	// They are at the level of the gl texture to benefit from the cache.
	public var _lodTextureHigh:BaseTexture;
	public var _lodTextureMid:BaseTexture;
	public var _lodTextureLow:BaseTexture;
	
	public var _webGLTexture:GLTexture;
	public var _references:Int = 1;
	private var _engine:Engine;
	
	public var dataSource(get, never):Int;
	inline private function get_dataSource():Int {
		return this._dataSource;
	}
	
	public var __smartArrayFlags:Array<Int> = [];
	

	public function new(engine:Engine, dataSource:Int, ?url:String) {
		this._engine = engine;
		this._dataSource = dataSource;
		
		if (url != null) {
			this.url = url;
		}
		
		this._webGLTexture = engine._createTexture();
	}

	public function incrementReferences() {
		this._references++;
	}

	public function updateSize(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		this._size = Std.int(width * height);
		this.baseWidth = width;
		this.baseHeight = height;
	}
	
	public function _rebuild() {
		// this._engine.createTexture(this.url, !this.generateMipMaps, this.invertY, scene, this.samplingMode, null, null, this._buffer, null, this._format);
    }
	
	public function dispose() {
		if (this._webGLTexture == null) {
			return;
		}
		
		this._references--;
		if (this._references == 0) {			
			this._engine._releaseTexture(this);
			this._webGLTexture = null;
		}
	}
	
}
