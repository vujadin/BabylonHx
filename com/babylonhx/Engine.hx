package com.babylonhx;

import com.babylonhx.states._AlphaState;
import com.babylonhx.states._DepthCullingState;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.textures.WebGLTexture;
import com.babylonhx.materials.textures.VideoTexture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.EffectFallbacks;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Viewport;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.states._StencilState;
import com.babylonhx.tools.Tools;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.GLProgram;
import com.babylonhx.utils.GL.GLUniformLocation;
import com.babylonhx.utils.typedarray.UInt8Array;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Int32Array;
import com.babylonhx.utils.typedarray.Int16Array;
import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.GL.GLFramebuffer;
import com.babylonhx.utils.GL.GLBuffer;
import com.babylonhx.utils.Image;


import haxe.ds.Vector;


#if (js || purejs)
import com.babylonhx.audio.AudioEngine;
import js.Browser;
using com.babylonhx.utils.GL;
#else
import com.babylonhx.utils.GL in Gl;
#end

#if openfl
import openfl.display.OpenGLView;
#elseif nme
import nme.display.OpenGLView;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef BufferPointer = { 
	indx:Int,
	size:Int,
	type:Int,
	normalized:Bool,
	stride:Int,
	offset:Int,
	buffer:WebGLBuffer
}

@:expose('BABYLON.Engine') class Engine {
	
	// Const statics

	public static inline var ALPHA_DISABLE:Int = 0;
	public static inline var ALPHA_ADD:Int = 1;
	public static inline var ALPHA_COMBINE:Int = 2;
	public static inline var ALPHA_SUBTRACT:Int = 3;
	public static inline var ALPHA_MULTIPLY:Int = 4;
	public static inline var ALPHA_MAXIMIZED:Int = 5;
	public static inline var ALPHA_ONEONE:Int = 6;

	public static inline var DELAYLOADSTATE_NONE:Int = 0;
	public static inline var DELAYLOADSTATE_LOADED:Int = 1;
	public static inline var DELAYLOADSTATE_LOADING:Int = 2;
	public static inline var DELAYLOADSTATE_NOTLOADED:Int = 4;
	
	public static inline var TEXTUREFORMAT_ALPHA:Int = 0;
	public static inline var TEXTUREFORMAT_LUMINANCE:Int = 1;
	public static inline var TEXTUREFORMAT_LUMINANCE_ALPHA:Int = 2;
	public static inline var TEXTUREFORMAT_RGB:Int = 4;
	public static inline var TEXTUREFORMAT_RGBA:Int = 5;

	public static inline var TEXTURETYPE_UNSIGNED_INT:Int = 0;
	public static inline var TEXTURETYPE_FLOAT:Int = 1;
	public static inline var TEXTURETYPE_HALF_FLOAT:Int = 2;
	
	public static var HALF_FLOAT_OES:Int = 0x8D61;
	
	// Depht or Stencil test Constants.
	
	// Passed to depthFunction or stencilFunction to specify depth or stencil tests will never pass. i.e. Nothing will be drawn.
	public static inline var NEVER:Int = 0x0200;	
	// Passed to depthFunction or stencilFunction to specify depth or stencil tests will always pass. i.e. Pixels will be drawn in the order they are drawn.
	public static inline var ALWAYS:Int = 0x0207; 
	// Passed to depthFunction or stencilFunction to specify depth or stencil tests will pass if the new depth value is less than the stored value.
	public static inline var LESS:Int = 0x0201; 
	// Passed to depthFunction or stencilFunction to specify depth or stencil tests will pass if the new depth value is equals to the stored value.
	public static inline var EQUAL:Int = 0x0202;
	// Passed to depthFunction or stencilFunction to specify depth or stencil tests will pass if the new depth value is less than or equal to the stored value.
	public static inline var LEQUAL:Int = 0x0203;
	// Passed to depthFunction or stencilFunction to specify depth or stencil tests will pass if the new depth value is greater than the stored value.
	public static inline var GREATER:Int = 0x0204;
	// Passed to depthFunction or stencilFunction to specify depth or stencil tests will pass if the new depth value is greater than or equal to the stored value.
	public static inline var GEQUAL:Int = 0x0206; 
	//  Passed to depthFunction or stencilFunction to specify depth or stencil tests will pass if the new depth value is not equal to the stored value.
	public static inline var NOTEQUAL:Int = 0x0205; 
	
	
	// Stencil Actions Constants.
	public static inline var KEEP:Int = 0x1E00;
	public static inline var REPLACE:Int = 0x1E01;
	public static inline var INCR:Int = 0x1E02;
	public static inline var DECR:Int = 0x1E03;
	public static inline var INVERT:Int = 0x150A;
	public static inline var INCR_WRAP:Int = 0x8507;
	public static inline var DECR_WRAP:Int = 0x8508;
	

	public static var Version:String = "2.0.0";

	// Updatable statics so stick with vars here
	public static var CollisionsEpsilon:Float = 0.001;
	public static var ShadersRepository:String = "assets/shaders/";


	// Public members
	public var isFullscreen:Bool = false;
	public var isPointerLock:Bool = false;
	public var cullBackFaces:Bool = true;
	public var renderEvenInBackground:Bool = true;
	public var scenes:Array<Scene> = [];

	// Private Members
	#if (js || purejs)
	public var Gl:js.html.webgl.RenderingContext;
	#else
	public var Gl = com.babylonhx.utils.GL;
	#end
	private var _renderingCanvas:Dynamic;

	private var _windowIsBackground:Bool = false;

	private var _onBlur:Void->Void;
	private var _onFocus:Void->Void;
	private var _onFullscreenChange:Void->Void;
	private var _onPointerLockChange:Void->Void;
	
	public var onAfterRender:Array<Void->Void> = [];

	private var _hardwareScalingLevel:Float;	
	private var _caps:EngineCapabilities;
	private var _pointerLockRequested:Bool;
	private var _alphaTest:Bool;
	private var _isStencilEnable:Bool;
		
	private var _drawCalls:Int = 0;
	public var drawCalls(get, never):Int;
	private function get_drawCalls():Int {
		return this._drawCalls;
	}
	
	private var _glVersion:String;
	private var _glExtensions:Array<String>;
	private var _glRenderer:String;
	private var _glVendor:String;

	private var _videoTextureSupported:Null<Bool>;
	
	private var _renderingQueueLaunched:Bool = false;
	private var _activeRenderLoops:Array<Dynamic> = [];
	
	// FPS
	public var fpsRange:Float = 60.0;
	public var previousFramesDuration:Array<Float> = [];
	public var fps:Float = 60.0;
	public var deltaTime:Float = 0.0;

	// States
	private var _depthCullingState:_DepthCullingState = new _DepthCullingState();
	private var _stencilState:_StencilState = new _StencilState();
	private var _alphaState:_AlphaState = new _AlphaState();
	private var _alphaMode:Int = Engine.ALPHA_DISABLE;

	// Cache
	private var _loadedTexturesCache:Array<WebGLTexture> = [];
	private var _maxTextureChannels:Int = 16;
	private var _activeTexture:Int;
	public var _activeTexturesCache:Vector<GLTexture>;
	private var _currentEffect:Effect;
	private var _currentProgram:GLProgram;
	private var _compiledEffects:Map<String, Effect> = new Map<String, Effect>();
	private var _vertexAttribArraysEnabled:Array<Bool> = [];
	private var _cachedViewport:Viewport;
	private var _cachedVertexBuffers:Dynamic; // WebGLBuffer | Map<String, VertexBuffer>;
	private var _cachedIndexBuffer:WebGLBuffer;
	private var _cachedEffectForVertexBuffers:Effect;
	private var _currentRenderTarget:WebGLTexture;
	private var _uintIndicesCurrentlySet:Bool = false;
	private var _currentBoundBuffer:Map<Int, WebGLBuffer> = new Map();
	private var _currentFramebuffer:GLFramebuffer;
	private var _currentBufferPointers:Array<BufferPointer> = [];
	private var _currentInstanceLocations:Array<Int> = [];
	private var _currentInstanceBuffers:Array<WebGLBuffer> = [];
	private var _textureUnits:Int32Array;

	public var _canvasClientRect:Dynamic = { x: 0, y: 0, width: 960, height: 640 };

	private var _workingCanvas:Image;
	#if (openfl || nme)
	public var _workingContext:OpenGLView; 
	#end
	
	// quick and dirty solution to handle mouse/keyboard 
	public var mouseDown:Array<Dynamic> = [];
	public var mouseUp:Array<Dynamic> = [];
	public var mouseMove:Array<Dynamic> = [];
	public var mouseWheel:Array<Dynamic> = [];
	public var touchDown:Array<Dynamic> = [];
	public var touchUp:Array<Dynamic> = [];
	public var touchMove:Array<Dynamic> = [];
	public var keyUp:Array<Dynamic> = [];
	public var keyDown:Array<Dynamic> = [];
	public var onResize:Array<Void->Void> = [];

	public var width:Int;
	public var height:Int;
	
	#if (js || purejs)
	public var audioEngine:AudioEngine = new AudioEngine();
	#end
	
	
	public function new(canvas:Dynamic, antialias:Bool = false, ?options:Dynamic, adaptToDeviceRatio:Bool = false) {		
		this._renderingCanvas = canvas;
		this._canvasClientRect.width = Reflect.getProperty(canvas, "width") != null ? Reflect.getProperty(canvas, "width") : 960;// canvas.width;
		this._canvasClientRect.height = Reflect.getProperty(canvas, "height") != null ? Reflect.getProperty(canvas, "height") : 640;// canvas.height;
		
		options = options != null ? options : {};
		options.antialias = antialias;
		
		if (options.preserveDrawingBuffer == null) {
			options.preserveDrawingBuffer = false;
		}
		
		#if (purejs || js)
			#if lime
			if(!Std.is(this._renderingCanvas, js.html.CanvasElement))
				this._renderingCanvas = Browser.document.getElementsByTagName('canvas')[0];
			#end

		Gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("webgl", options);
		if (Gl == null) {
			Gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("experimental-webgl", options);
		}
		#end
		
		#if (openfl || nme)
		this._workingContext = new OpenGLView();
		this._workingContext.render = this._renderLoop;
		canvas.addChild(this._workingContext);
		#end
		
		// Checks if some of the format renders first to allow the use of webgl inspector.
		var renderToFullFloat = this._canRenderToFloatTexture();
		var renderToHalfFloat = this._canRenderToHalfFloatTexture();
		
		if (options.stencil == null) {
			options.stencil = true;
		}
		
		width = this._canvasClientRect.width;
		height = this._canvasClientRect.height;		
		
		this._onBlur = function() {
			this._windowIsBackground = true;
		};
		
		this._onFocus = function() {
			this._windowIsBackground = false;
		};
		
		// Viewport
		#if (js || purejs || web)
		this._hardwareScalingLevel = 1;// adaptToDeviceRatio ? 1.0 / (untyped Browser.window.devicePixelRatio || 1.0) : 1.0; 
		#else
		this._hardwareScalingLevel = 1;// Std.int(1.0 / (Capabilities.pixelAspectRatio));	
		#end
		this.resize();
		
		// Caps
		this._isStencilEnable = options.stencil;
		this._caps = new EngineCapabilities();
		this._caps.maxTexturesImageUnits = Gl.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
		this._caps.maxTextureSize = Gl.getParameter(GL.MAX_TEXTURE_SIZE);
		this._caps.maxCubemapTextureSize = Gl.getParameter(GL.MAX_CUBE_MAP_TEXTURE_SIZE);
		this._caps.maxRenderTextureSize = Gl.getParameter(GL.MAX_RENDERBUFFER_SIZE);
		this._caps.maxVertexAttribs = Gl.getParameter(GL.MAX_VERTEX_ATTRIBS);
		this._caps.maxVaryingVectors = Gl.getParameter(GL.MAX_VARYING_VECTORS);
        this._caps.maxFragmentUniformVectors = Gl.getParameter(GL.MAX_FRAGMENT_UNIFORM_VECTORS);
        this._caps.maxVertexUniformVectors = Gl.getParameter(GL.MAX_VERTEX_UNIFORM_VECTORS);
		
		// Infos
		this._glVersion = Gl.getParameter(GL.VERSION);
		this._glVendor = Gl.getParameter(GL.VENDOR);
		this._glRenderer = Gl.getParameter(GL.RENDERER);
		this._glExtensions = Gl.getSupportedExtensions();
		//for (ext in this._glExtensions) {
			//trace(ext);
		//}
		//trace(this._glExtensions);
		
		#if (!snow || (js && snow))
		// Extensions
		try {
			this._caps.standardDerivatives = Gl.getExtension('OES_standard_derivatives') != null;
			this._caps.s3tc = Gl.getExtension('WEBGL_compressed_texture_s3tc');
			this._caps.textureFloat = (Gl.getExtension('OES_texture_float') != null);
			this._caps.textureAnisotropicFilterExtension = Gl.getExtension('EXT_texture_filter_anisotropic') || Gl.getExtension('WEBKIT_EXT_texture_filter_anisotropic') || Gl.getExtension("MOZ_EXT_texture_filter_anisotropic");
			this._caps.maxAnisotropy = this._caps.textureAnisotropicFilterExtension != null ? Gl.getParameter(this._caps.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 0;
			
			#if (!mobile && cpp)
			this._caps.instancedArrays = Gl.getExtension("GL_ARB_instanced_arrays");
			/*this._caps.instancedArrays = { 
				vertexAttribDivisorANGLE: Gl.getExtension('glVertexAttribDivisorARB'),
				drawElementsInstancedANGLE: Gl.getExtension('glDrawElementsInstancedARB'),
				drawArraysInstancedANGLE: Gl.getExtension('glDrawElementsInstancedARB')
			};*/
			#else
			this._caps.instancedArrays = Gl.getExtension("ANGLE_instanced_arrays");
			#end
			
			this._caps.uintIndices = Gl.getExtension("OES_element_index_uint") != null;
			this._caps.fragmentDepthSupported = Gl.getExtension("EXT_frag_depth") != null;
			this._caps.highPrecisionShaderSupported = true;
			if (Gl.getShaderPrecisionFormat != null) {
				var highp = Gl.getShaderPrecisionFormat(GL.FRAGMENT_SHADER, GL.HIGH_FLOAT);
				this._caps.highPrecisionShaderSupported = highp != null && highp.precision != 0;
			}
			this._caps.drawBuffersExtension = Gl.getExtension("WEBGL_draw_buffers");
			this._caps.textureFloatLinearFiltering = Gl.getExtension("OES_texture_float_linear") != null;
			this._caps.textureLOD = Gl.getExtension('EXT_shader_texture_lod') != null;
			if (this._caps.textureLOD) {
				this._caps.textureLODExt = "GL_EXT_shader_texture_lod";
				this._caps.textureCubeLodFnName = "textureCubeLodEXT";
			}
			
			this._caps.textureHalfFloat = (Gl.getExtension('OES_texture_half_float') != null);
			this._caps.textureHalfFloatLinearFiltering = Gl.getExtension('OES_texture_half_float_linear');
			this._caps.textureHalfFloatRender = renderToHalfFloat;
		} 
		catch (err:Dynamic) {
			trace(err);
		}
		#if (!js && !purejs)
			if (this._caps.s3tc == null) {
				this._caps.s3tc = this._glExtensions.indexOf("GL_EXT_texture_compression_s3tc") != -1;
			}
			if (this._caps.textureAnisotropicFilterExtension == null || this._caps.textureAnisotropicFilterExtension == false) {
				if (this._glExtensions.indexOf("GL_EXT_texture_filter_anisotropic") != -1) {
					this._caps.textureAnisotropicFilterExtension = { };
					this._caps.textureAnisotropicFilterExtension.TEXTURE_MAX_ANISOTROPY_EXT = 0x84FF;
				}
			}
			if (this._caps.maxRenderTextureSize == 0) {
				this._caps.maxRenderTextureSize = 16384;
			}
			if (this._caps.maxCubemapTextureSize == 0) {
				this._caps.maxCubemapTextureSize = 16384;
			}
			if (this._caps.maxTextureSize == 0) {
				this._caps.maxTextureSize = 16384;
			}
			if (this._caps.uintIndices == null) {
				this._caps.uintIndices = true;
			}
			if (this._caps.standardDerivatives == false) {
				this._caps.standardDerivatives = true;
			}
			if (this._caps.maxAnisotropy == 0) {
				this._caps.maxAnisotropy = 16;
			}
			if (this._caps.textureFloat == false) {
				this._caps.textureFloat = this._glExtensions.indexOf("GL_ARB_texture_float") != -1;
			}
			if (this._caps.fragmentDepthSupported == false) {
				this._caps.fragmentDepthSupported = Gl.getExtension("GL_EXT_frag_depth") != null;
			}
			if (this._caps.drawBuffersExtension == null) {
				this._caps.drawBuffersExtension = Gl.getExtension("GL_ARB_draw_buffers");
			}
			if (this._caps.textureFloatLinearFiltering == false) {
				this._caps.textureFloatLinearFiltering = true;
			}
			if (this._caps.textureLOD == false) {
				this._caps.textureLOD = this._glExtensions.indexOf("GL_ARB_shader_texture_lod") != -1;
				if (this._caps.textureLOD) {
					this._caps.textureLODExt = "GL_ARB_shader_texture_lod";
					this._caps.textureCubeLodFnName = "textureCubeLod";
				}
			}
			this._caps.textureHalfFloat = (GL.getExtension('OES_texture_half_float') != null);
			this._caps.textureHalfFloatLinearFiltering = GL.getExtension('OES_texture_half_float_linear');
			this._caps.textureHalfFloatRender = renderToHalfFloat;
		#end
		#else
		this._caps.maxRenderTextureSize = 16384;
		this._caps.maxCubemapTextureSize = 16384;
		this._caps.maxTextureSize = 16384;
		this._caps.uintIndices = true;
		this._caps.standardDerivatives = true;
		this._caps.maxAnisotropy = 16;
		this._caps.highPrecisionShaderSupported = true;
		this._caps.textureFloat = this._glExtensions.indexOf("GL_ARB_texture_float") != -1;
		this._caps.fragmentDepthSupported = this._glExtensions.indexOf("GL_EXT_frag_depth") != -1;
		this._caps.drawBuffersExtension = null;
		this._caps.textureFloatLinearFiltering = false;
		this._caps.textureLOD = this._glExtensions.indexOf("GL_ARB_shader_texture_lod") != -1;
		if (this._caps.textureLOD) {
			this._caps.textureLODExt = "GL_ARB_shader_texture_lod";
			this._caps.textureCubeLodFnName = "textureCubeLod";
		}
		trace(this._caps.textureLODExt);
		this._caps.instancedArrays = null;
		#end
		
		// Depth buffer
		this.setDepthBuffer(true);
		this.setDepthFunctionToLessOrEqual();
		this.setDepthWrite(true);
		
		// Fullscreen
		this.isFullscreen = false;
		
		// Pointer lock
		this.isPointerLock = false;	
		
		this._activeTexturesCache = new Vector<GLTexture>(this._maxTextureChannels);
		
		var msg:String = "BabylonHx - Cross-Platform 3D Engine | " + Date.now().getFullYear() + " | www.babylonhx.com";
		msg +=  " | GL version: " + this._glVersion + " | GL vendor: " + this._glVendor + " | GL renderer: " + this._glVendor; 
		trace(msg);
	}
	
	public static function compileShader(#if (js || purejs) Gl:js.html.webgl.RenderingContext, #end source:String, type:String, defines:String):GLShader {
		var shader:GLShader = Gl.createShader(type == "vertex" ? GL.VERTEX_SHADER : GL.FRAGMENT_SHADER);
		
		Gl.shaderSource(shader, (defines != null ? defines + "\n" : "") + source);
		Gl.compileShader(shader);
		
		if (Gl.getShaderParameter(shader, GL.COMPILE_STATUS) == 0) {
			throw(Gl.getShaderInfoLog(shader));
		}
		
		return shader;
	}
	
	public static function getWebGLTextureType(type:Int):Int {
		if (type == Engine.TEXTURETYPE_FLOAT) {
			return GL.FLOAT;
		}
		else if (type == Engine.TEXTURETYPE_HALF_FLOAT) {
			// Add Half Float Constant.
			return HALF_FLOAT_OES;
		}
		
		return GL.UNSIGNED_BYTE;
	}

	public static function getSamplingParameters(samplingMode:Int, generateMipMaps:Bool):Dynamic {
		var magFilter = GL.NEAREST;
		var minFilter = GL.NEAREST;
		if (samplingMode == Texture.BILINEAR_SAMPLINGMODE) {
			magFilter = GL.LINEAR;
			if (generateMipMaps) {
				minFilter = GL.LINEAR_MIPMAP_NEAREST;
			}
			else {
				minFilter = GL.LINEAR;
			}
		}
		else if (samplingMode == Texture.TRILINEAR_SAMPLINGMODE) {
			magFilter = GL.LINEAR;
			if (generateMipMaps) {
				minFilter = GL.LINEAR_MIPMAP_LINEAR;
			}
			else {
				minFilter = GL.LINEAR;
			}
		}
		else if (samplingMode == Texture.NEAREST_SAMPLINGMODE) {
			magFilter = GL.NEAREST;
			if (generateMipMaps) {
				minFilter = GL.NEAREST_MIPMAP_LINEAR;
			}
			else {
				minFilter = GL.NEAREST;
			}
		}
		
		return {
			min: minFilter,
			mag: magFilter
		}
	}

	public function prepareTexture(texture:WebGLTexture, scene:Scene, width:Int, height:Int, invertY:Bool, noMipmap:Bool, isCompressed:Bool, processFunction:Int->Int->Void, ?onLoad:Void->Void, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
		var engine = scene.getEngine();
		var potWidth = com.babylonhx.math.Tools.GetExponentOfTwo(width, engine.getCaps().maxTextureSize);
		var potHeight = com.babylonhx.math.Tools.GetExponentOfTwo(height, engine.getCaps().maxTextureSize);
		
		if (potWidth != width || potHeight != height) {
			trace("Texture '" + texture.url + "' is not power of two !");
		}
		
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		/*#if js
		Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY == null ? 1 : (invertY ? 1 : 0));
		#end*/
		
		texture._baseWidth = width;
		texture._baseHeight = height;
		texture._width = potWidth;
		texture._height = potHeight;
		texture.isReady = true;
		
		processFunction(Std.int(potWidth), Std.int(potHeight));
		
		var filters = getSamplingParameters(samplingMode, !noMipmap);
		
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
		
		if (!noMipmap && !isCompressed) {
			Gl.generateMipmap(GL.TEXTURE_2D);
		}
		
		this._bindTextureDirectly(GL.TEXTURE_2D, null);
		
		resetTextureCache();
		scene._removePendingData(texture);
		
		if (texture.onLoadedCallbacks != null) {
			for (cb in texture.onLoadedCallbacks) {
				if (cb != null) {
					cb();
				}
			}
		}
		
		if (onLoad != null) {
			onLoad();
		}
	}

	public static function partialLoad(url:String, index:Int, loadedImages:Dynamic, scene:Scene, onfinish:Dynamic->Void) {
		/*var img:Dynamic = null;

		var onload = function() {
			loadedImages[index] = img;
			loadedImages._internalCount++;

			scene._removePendingData(img);

			if (loadedImages._internalCount == 6) {
				onfinish(loadedImages);
			}
		};

		var onerror = function() {
			scene._removePendingData(img);
		};

		img = Tools.LoadImage(url, onload, onerror, scene.database);
		scene._addPendingData(img);*/
	}

	public static function cascadeLoad(rootUrl:String, scene:Scene, onfinish:Dynamic->Void, extensions:Array<String>) {
		/*var loadedImages:Array<Dynamic> = [];
		loadedImages._internalCount = 0;

		for (index in 0...6) {
			partialLoad(rootUrl + extensions[index], index, loadedImages, scene, onfinish);
		}*/
	}
	
	public function getExtensions():Array<String> {
		return this._glExtensions;
	}
	
	/**
	 * Returns true if the stencil buffer has been enabled through the creation option of the context.
	 */
	public var isStencilEnable(get, never):Bool;
	private function get_isStencilEnable():Bool {
		return this._isStencilEnable;
	}
	
	public function resetTextureCache() {
		for (index in 0...this._maxTextureChannels) {
			this._activeTexturesCache[index] = null;
		}
	}

	public function getAspectRatio(camera:Camera, useScreen:Bool = false):Float {
		var viewport = camera.viewport;
		
		return (this.getRenderWidth(useScreen) * viewport.width) / (this.getRenderHeight(useScreen) * viewport.height);
	}

	public function getRenderWidth(useScreen:Bool = false):Int {
		if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget._width;
		}
		
		#if (js || purejs)
		return this._renderingCanvas.width;
		#else
		return this.width;
		#end
	}

	public function getRenderHeight(useScreen:Bool = false):Int {
		if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget._height;
		}
		
		#if (js || purejs)
		return this._renderingCanvas.height;
		#else
		return this.height;
		#end
	}

	public function getRenderingCanvas():Dynamic {
		return this._renderingCanvas;
	}

	public function setHardwareScalingLevel(level:Float) {
		this._hardwareScalingLevel = level;
		this.resize();
	}

	public function getHardwareScalingLevel():Float {
		return this._hardwareScalingLevel;
	}

	public function getLoadedTexturesCache():Array<WebGLTexture> {
		return this._loadedTexturesCache;
	}

	public function getCaps():EngineCapabilities {
		return this._caps;
	}

	// Methods
	inline public function resetDrawCalls() {
		this._drawCalls = 0;
	}
	
	inline public function setDepthFunctionToGreater() {
		this._depthCullingState.depthFunc = GL.GREATER;
	}

	inline public function setDepthFunctionToGreaterOrEqual() {
		this._depthCullingState.depthFunc = GL.GEQUAL;
	}

	inline public function setDepthFunctionToLess() {
		this._depthCullingState.depthFunc = GL.LESS;
	}

	inline public function setDepthFunctionToLessOrEqual() {
		this._depthCullingState.depthFunc = GL.LEQUAL;
	}
	
	inline public function getStencilBuffer():Bool {
		return this._stencilState.stencilTest;
	}

	inline public function setStencilBuffer(enable:Bool) {
		this._stencilState.stencilTest = enable;
	}

	inline public function getStencilMask():Int {
		return this._stencilState.stencilMask;
	}

	inline public function setStencilMask(mask:Int) {
		this._stencilState.stencilMask = mask;
	}

	inline public function getStencilFunction():Int {
		return this._stencilState.stencilFunc;
	}

	inline public function getStencilFunctionReference():Int {
		return this._stencilState.stencilFuncRef;
	}

	inline public function getStencilFunctionMask():Int {
		return this._stencilState.stencilFuncMask;
	}

	inline public function setStencilFunction(stencilFunc:Int) {
		this._stencilState.stencilFunc = stencilFunc;
	}
	
	inline public function setStencilFunctionReference(reference:Int) {
		this._stencilState.stencilFuncRef = reference;
	}
	
	inline public function setStencilFunctionMask(mask:Int) {
		this._stencilState.stencilFuncMask = mask;
	}

	inline public function getStencilOperationFail():Int {
		return this._stencilState.stencilOpStencilFail;
	}

	inline public function getStencilOperationDepthFail():Int {
		return this._stencilState.stencilOpDepthFail;
	}

	inline public function getStencilOperationPass():Int {
		return this._stencilState.stencilOpStencilDepthPass;
	}

	inline public function setStencilOperationFail(operation:Int) {
		this._stencilState.stencilOpStencilFail = operation;
	}

	inline public function setStencilOperationDepthFail(operation:Int) {
		this._stencilState.stencilOpDepthFail = operation;
	}

	inline public function setStencilOperationPass(operation:Int) {
		this._stencilState.stencilOpStencilDepthPass = operation;
	}

	/**
	 * stop executing a render loop function and remove it from the execution array
	 * @param {Function} [renderFunction] the function to be removed. If not provided all functions will be removed.
	 */
	public function stopRenderLoop(?renderFunction:Void->Void) {
		if (renderFunction == null) {
			this._activeRenderLoops = [];
			return;
		}
		
		var index = this._activeRenderLoops.indexOf(renderFunction);
		
		if (index >= 0) {
			this._activeRenderLoops.splice(index, 1);
		}
	}

	public function _renderLoop(?rect:Dynamic) {
		var shouldRender = true;
		if (!this.renderEvenInBackground && this._windowIsBackground) {
			shouldRender = false;
		}
		
		if (shouldRender) {
			// Start new frame
			this.beginFrame();
			
			for (index in 0...this._activeRenderLoops.length) {
				var renderFunction = this._activeRenderLoops[index];
				renderFunction();
			}
			
			// Present
			this.endFrame();
			
			for (f in onAfterRender) {
				f();
			}
		}
		
		#if purejs
		if (this._activeRenderLoops.length > 0) {
			// Register new frame
			Tools.QueueNewFrame(this._renderLoop);
		} else {
			this._renderingQueueLaunched = false;
		}
		#end
	}

	inline public function runRenderLoop(renderFunction:Void->Void) {
		if (this._activeRenderLoops.indexOf(renderFunction) != -1) {
			return;
		}
		
		this._activeRenderLoops.push(renderFunction);
		
		#if purejs
		if (!this._renderingQueueLaunched) {
			this._renderingQueueLaunched = true;
			Tools.QueueNewFrame(this._renderLoop);
		}
		#end
	}

	public function switchFullscreen(requestPointerLock:Bool) {
		// TODO
		/*if (this.isFullscreen) {
			Tools.ExitFullscreen();
		} else {
			this._pointerLockRequested = requestPointerLock;
			Tools.RequestFullscreen(this._renderingCanvas);
		}*/
	}

	inline public function clear(color:Dynamic, backBuffer:Bool, depth:Bool, stencil:Bool = false) {
		this.applyStates();
		
		var mode = 0;
		if (backBuffer) {
			if(Std.is(color, Color4)) {
				Gl.clearColor(color.r, color.g, color.b, color.a);
			} 
			else {
				Gl.clearColor(color.r, color.g, color.b, 1.0);
			}
			mode |= GL.COLOR_BUFFER_BIT;
		}
		
		if (depth) {
			Gl.clearDepth(1.0);
			mode |= GL.DEPTH_BUFFER_BIT;
		}
		
		if (stencil) {
			Gl.clearStencil(0);
			mode |= GL.STENCIL_BUFFER_BIT;
		}
		
		Gl.clear(mode);
	}
	
	public function scissorClear(x:Int, y:Int, width:Int, height:Int, clearColor:Color4) {
		// Save state
		var curScissor = Gl.getParameter(GL.SCISSOR_TEST);
		var curScissorBox = Gl.getParameter(GL.SCISSOR_BOX);
		
		// Change state
		Gl.enable(GL.SCISSOR_TEST);
		Gl.scissor(x, y, width, height);
		
		// Clear
		this.clear(clearColor, true, true, true);
		
		// Restore state
		Gl.scissor(curScissorBox[0], curScissorBox[1], curScissorBox[2], curScissorBox[3]);
		
		if (curScissor == true) {
			Gl.enable(GL.SCISSOR_TEST);
		} 
		else {
			Gl.disable(GL.SCISSOR_TEST);
		}
	}

	/**
	 * Set the WebGL's viewport
	 * @param {BABYLON.Viewport} viewport - the viewport element to be used.
	 * @param {number} [requiredWidth] - the width required for rendering. If not provided the rendering canvas' width is used.
	 * @param {number} [requiredHeight] - the height required for rendering. If not provided the rendering canvas' height is used.
	 */
	inline public function setViewport(viewport:Viewport, requiredWidth:Float = 0, requiredHeight:Float = 0) {
		var width = requiredWidth == 0 ? getRenderWidth() : requiredWidth;
		var height = requiredHeight == 0 ? getRenderHeight() : requiredHeight;
		
		var x = viewport.x;
		var y = viewport.y;

		this._cachedViewport = viewport;
		Gl.viewport(Std.int(x * width), Std.int(y * height), Std.int(width * viewport.width), Std.int(height * viewport.height));
	}

	inline public function setDirectViewport(x:Int, y:Int, width:Int, height:Int):Viewport {
		var currentViewport = this._cachedViewport;
		this._cachedViewport = null;
		
		Gl.viewport(x, y, width, height);
		
		return currentViewport;
	}

	inline public function beginFrame() {
		this._measureFps();
	}

	inline public function endFrame() {
		this.flushFramebuffer();
	}
	
	public function getVertexShaderSource(program:GLProgram):String {
		var shaders = Gl.getAttachedShaders(program);
		
		return Gl.getShaderSource(shaders[0]);
	}

	public function getFragmentShaderSource(program:GLProgram):String {
		var shaders = Gl.getAttachedShaders(program);
		
		return Gl.getShaderSource(shaders[1]);
	}
	
	// FPS
	inline public function getFps():Float {
		return this.fps;
	}

	inline public function getDeltaTime():Float {
		return this.deltaTime;
	}

	inline private function _measureFps() {
		this.previousFramesDuration.push(Tools.Now());
		var length = this.previousFramesDuration.length;
		
		if (length >= 2) {
			this.deltaTime = this.previousFramesDuration[length - 1] - this.previousFramesDuration[length - 2];
		}
		
		if (length >= this.fpsRange) {
			
			if (length > this.fpsRange) {
				this.previousFramesDuration.splice(0, 1);
				length = this.previousFramesDuration.length;
			}
			
			var sum = 0.0;
			for (id in 0...length - 1) {
				sum += this.previousFramesDuration[id + 1] - this.previousFramesDuration[id];
			}
			
			this.fps = 1000.0 / (sum / (length - 1));
		}
	}

	/**
	 * resize the view according to the canvas' size.
	 * @example
	 *   window.addEventListener("resize", function () {
	 *      engine.resize();
	 *   });
	 */
	public function resize() {
		#if (purejs)
		width = untyped Browser.navigator.isCocoonJS ? Browser.window.innerWidth : this._renderingCanvas.clientWidth;
		height = untyped Browser.navigator.isCocoonJS ? Browser.window.innerHeight : this._renderingCanvas.clientHeight;
		
		this.setSize(Std.int(width / this._hardwareScalingLevel), Std.int(height / this._hardwareScalingLevel));
		#end
		
		for (fn in onResize) {
			fn();
		}
	}
	
	/**
	 * force a specific size of the canvas
	 * @param {number} width - the new canvas' width
	 * @param {number} height - the new canvas' height
	 */
	public function setSize(width:Int, height:Int) {
		#if purejs
		this._renderingCanvas.width = width;
		this._renderingCanvas.height = height;
				
		for (index in 0...this.scenes.length) {
			var scene = this.scenes[index];
			
			for (camIndex in 0...scene.cameras.length) {
				var cam = scene.cameras[camIndex];
				cam._currentRenderId = 0;
			}
		}
		#end
	}

	public function bindFramebuffer(texture:WebGLTexture, faceIndex:Int = 0, ?requiredWidth:Int, ?requiredHeight:Int) {
		this._currentRenderTarget = texture;		
		this.bindUnboundFramebuffer(texture._framebuffer);
		
		if (texture.isCube) {
			Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture.data, 0);
		}
		else {
			Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.data, 0);
		}
		
		Gl.viewport(0, 0, requiredWidth != null ? requiredWidth : texture._width, requiredHeight != null ? requiredHeight : texture._height);
		
		this.wipeCaches();
	}
	
	inline private function bindUnboundFramebuffer(framebuffer:GLFramebuffer) {
		if (this._currentFramebuffer != framebuffer) {
			Gl.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
			this._currentFramebuffer = framebuffer;
		}
	}

	inline public function unBindFramebuffer(texture:WebGLTexture, disableGenerateMipMaps:Bool = false) {
		this._currentRenderTarget = null;
		
		if (texture.generateMipMaps && !disableGenerateMipMaps) {
			this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
			Gl.generateMipmap(GL.TEXTURE_2D);
			this._bindTextureDirectly(GL.TEXTURE_2D, null);
		}
		
		this.bindUnboundFramebuffer(null);
	}
	
	public function generateMipMapsForCubemap(texture:WebGLTexture) {
		if (texture.generateMipMaps) {
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
			Gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
		}
	}

	inline public function flushFramebuffer() {
		//Gl.flush();
	}

	inline public function restoreDefaultFramebuffer() {
		this._currentRenderTarget = null;
		this.bindUnboundFramebuffer(null);
		
		this.setViewport(this._cachedViewport);
		
		this.wipeCaches();
	}

	// VBOs
	inline private function _resetVertexBufferBinding() {
		this.bindArrayBuffer(null);
		this._cachedVertexBuffers = null;
	}

	inline public function createVertexBuffer(vertices:Array<Float>):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);
		this.bindArrayBuffer(ret);
		
		Gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(vertices), GL.STATIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}
	
	inline public function createVertexBuffer2(vertices:Float32Array):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);
		this.bindArrayBuffer(ret);
		
		Gl.bufferData(GL.ARRAY_BUFFER, vertices, GL.STATIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}

	inline public function createDynamicVertexBuffer(vertices:Array<Float>):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindArrayBuffer(ret);		
		
		Gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(vertices), GL.DYNAMIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}
	
	inline public function createDynamicVertexBuffer2(vertices:Float32Array):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindArrayBuffer(ret);		
		
		Gl.bufferData(GL.ARRAY_BUFFER, vertices, GL.DYNAMIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}

	inline public function updateDynamicVertexBuffer(vertexBuffer:WebGLBuffer, vertices:Array<Float>, offset:Int = 0, count:Int = -1) {
		this.bindArrayBuffer(vertexBuffer);
		
		if (count == -1 || (count == vertices.length && offset == 0)) {
			Gl.bufferSubData(GL.ARRAY_BUFFER, offset, new Float32Array(vertices));
		}
		else {
			Gl.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(vertices.splice(offset, offset + count)));// ).subarray(offset, offset + count));
		}
		
		this._resetVertexBufferBinding();
	}
	
	inline public function updateDynamicVertexBuffer2(vertexBuffer:WebGLBuffer, vertices:Float32Array, offset:Int = 0, count:Int = -1) {
		this.bindArrayBuffer(vertexBuffer);
		
		if (count == -1) {
			Gl.bufferSubData(GL.ARRAY_BUFFER, offset, vertices);
		}
		else {
			Gl.bufferSubData(GL.ARRAY_BUFFER, 0, vertices.subarray(offset, offset + count));
		}
		
		this._resetVertexBufferBinding();
	}

	inline private function _resetIndexBufferBinding() {
		this.bindIndexBuffer(null);
		this._cachedIndexBuffer = null;
	}

	inline public function createIndexBuffer(indices:Array<Int>):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);
		
		this.bindIndexBuffer(ret);
		
		// Check for 32 bits indices
		var arrayBuffer:ArrayBufferView = null;
		var need32Bits = false;
		
		if (this._caps.uintIndices) {			
			for (index in 0...indices.length) {
				if (indices[index] > 65535) {
					need32Bits = true;
					break;
				}
			}
			
			arrayBuffer = need32Bits ? new Int32Array(indices) : new Int16Array(indices);
		} 
		else {
			arrayBuffer = new Int16Array(indices);
		}
		
		Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, arrayBuffer, GL.STATIC_DRAW);
		this._resetIndexBufferBinding();
		ret.references = 1;
		ret.is32Bits = need32Bits;
		
		return ret;
	}
	
	inline public function bindArrayBuffer(buffer:WebGLBuffer) {
		this.bindBuffer(buffer, GL.ARRAY_BUFFER);
	}
	
	inline private function bindIndexBuffer(buffer:WebGLBuffer) {
		this.bindBuffer(buffer, GL.ELEMENT_ARRAY_BUFFER);
	}
	
	inline private function bindBuffer(buffer:WebGLBuffer, target:Int) {
		if (this._currentBoundBuffer[target] != buffer) {
			Gl.bindBuffer(target, buffer == null ? null : buffer.buffer);
			this._currentBoundBuffer[target] = (buffer == null ? null : buffer);
		}
	}

	inline public function updateArrayBuffer(data:Float32Array) {
		Gl.bufferSubData(GL.ARRAY_BUFFER, 0, data);
	}
	
	private function vertexAttribPointer(buffer:WebGLBuffer, indx:Int, size:Int, type:Int, normalized:Bool, stride:Int, offset:Int) {
		var pointer:BufferPointer = this._currentBufferPointers[indx];
		
		var changed:Bool = false;
		if (pointer == null) {
			changed = true;
			this._currentBufferPointers[indx] = { indx: indx, size: size, type: type, normalized: normalized, stride: stride, offset: offset, buffer: buffer };
		} 
		else {
			if (pointer.buffer != buffer) { 
				pointer.buffer = buffer; 
				changed = true; 
			}
			if (pointer.size != size) { 
				pointer.size = size; 
				changed = true; 
			}
			if (pointer.type != type) { 
				pointer.type = type; 
				changed = true; 
			}
			if (pointer.normalized != normalized) { 
				pointer.normalized = normalized; 
				changed = true; 
			}
			if (pointer.stride != stride) { 
				pointer.stride = stride; 
				changed = true; 
			}
			if (pointer.offset != offset) { 
				pointer.offset = offset; 
				changed = true; 
			}
		}
		
		if (changed) {
			this.bindArrayBuffer(buffer);
			Gl.vertexAttribPointer(indx, size, type, normalized, stride, offset);
		}
	}

	public function bindBuffersDirectly(vertexBuffer:WebGLBuffer, indexBuffer:WebGLBuffer, vertexDeclaration:Array<Int>, vertexStrideSize:Int, effect:Effect) {
		if (this._cachedVertexBuffers != vertexBuffer || this._cachedEffectForVertexBuffers != effect) {
			this._cachedVertexBuffers = vertexBuffer;
			this._cachedEffectForVertexBuffers = effect;
			
			var attributesCount = effect.getAttributesCount();
			
			var offset:Int = 0;
			for (index in 0...attributesCount) {
				if (index < vertexDeclaration.length) {
					var order = effect.getAttributeLocation(index);
					
					if (order >= 0) {
						if (!this._vertexAttribArraysEnabled[order]) {
							Gl.enableVertexAttribArray(order);
							this._vertexAttribArraysEnabled[order] = true;
						}
						
						this.vertexAttribPointer(vertexBuffer, order, vertexDeclaration[index], GL.FLOAT, false, vertexStrideSize, offset);
					}
					
					offset += Std.int(vertexDeclaration[index] * 4);
				}
				else {
					//disable effect attributes that have no data
					var order = effect.getAttributeLocation(index);
					if (this._vertexAttribArraysEnabled[order]) {
						Gl.disableVertexAttribArray(order);
						this._vertexAttribArraysEnabled[order] = false;
					}
				}
			}
		}
		
		if (this._cachedIndexBuffer != indexBuffer) {
			this._cachedIndexBuffer = indexBuffer;
			this.bindIndexBuffer(indexBuffer);
			this._uintIndicesCurrentlySet = indexBuffer.is32Bits;
		}
	}

	static var _order:Int = 0;
	static var _vertexBuffer:VertexBuffer = null;
	static var _attributes:Array<String> = null;
	inline public function bindBuffers(vertexBuffers:Map<String, VertexBuffer>, indexBuffer:WebGLBuffer, effect:Effect) {
		if (this._cachedVertexBuffers != vertexBuffers || this._cachedEffectForVertexBuffers != effect) {
			this._cachedVertexBuffers = vertexBuffers;
			this._cachedEffectForVertexBuffers = effect;
			
			_attributes = effect.getAttributesNames();
			
			for (index in 0..._attributes.length) {
				_order = effect.getAttributeLocation(index);
				
				if (_order >= 0) {
					_vertexBuffer = vertexBuffers[_attributes[index]];
					
					if (_vertexBuffer == null) {
						if (this._vertexAttribArraysEnabled[_order]) {
							Gl.disableVertexAttribArray(_order);
							this._vertexAttribArraysEnabled[_order] = false;
						}
						
						continue;
					}
					
					if (!this._vertexAttribArraysEnabled[_order]) {
						Gl.enableVertexAttribArray(_order);
						this._vertexAttribArraysEnabled[_order] = true;
					}
					
					var buffer = _vertexBuffer.getBuffer();
					this.vertexAttribPointer(buffer, _order, _vertexBuffer.getSize(), GL.FLOAT, false, _vertexBuffer.getStrideSize() * 4, _vertexBuffer.getOffset() * 4);
					
					if (_vertexBuffer.getIsInstanced()) {
						this._caps.instancedArrays.vertexAttribDivisorANGLE(_order, 1);
						this._currentInstanceLocations.push(_order);
						this._currentInstanceBuffers.push(buffer);
					}
				}
			}
		}
		
		if (indexBuffer != null && this._cachedIndexBuffer != indexBuffer) {
			this._cachedIndexBuffer = indexBuffer;
			this.bindIndexBuffer(indexBuffer);
			this._uintIndicesCurrentlySet = indexBuffer.is32Bits;
		}
	}
	
	public function unbindInstanceAttributes() {
		var boundBuffer:WebGLBuffer = null;
		for (i in 0...this._currentInstanceLocations.length) {
			var instancesBuffer = this._currentInstanceBuffers[i];
			if (boundBuffer != instancesBuffer) {
				boundBuffer = instancesBuffer;
				this.bindArrayBuffer(instancesBuffer);
			}
			var offsetLocation = this._currentInstanceLocations[i];
			this._caps.instancedArrays.vertexAttribDivisorANGLE(offsetLocation, 0);
		}
		
		this._currentInstanceBuffers.splice(0, this._currentInstanceBuffers.length - 1);
		this._currentInstanceLocations.splice(0, this._currentInstanceLocations.length - 1);
	}
	
	inline public function _releaseBuffer(buffer:WebGLBuffer):Bool {
		buffer.references--;
		
		if (buffer.references == 0) {
			Gl.deleteBuffer(buffer.buffer);
			return true;
		}
		
		return false;
	}

	inline public function createInstancesBuffer(capacity:Int):WebGLBuffer {
		var buffer = new WebGLBuffer(Gl.createBuffer());
		
		buffer.capacity = capacity;
		
		Gl.bindBuffer(GL.ARRAY_BUFFER, buffer.buffer);
		Gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(capacity), GL.DYNAMIC_DRAW);
		
		return buffer;
	}

	public function deleteInstancesBuffer(buffer:WebGLBuffer) {
		Gl.deleteBuffer(buffer.buffer);
		buffer = null;
	}
	
	public function updateAndBindInstancesBuffer(instancesBuffer:WebGLBuffer, data: #if (js || html5 || purejs) Float32Array #else Array<Float> #end , offsetLocations:Array<Dynamic>) {
		this.bindArrayBuffer(instancesBuffer);
		
		if (data != null) {
			#if (js || html5 || purejs) 
			Gl.bufferSubData(GL.ARRAY_BUFFER, 0, cast data);
			#else
			Gl.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(data));
			#end
		}
		
		if (Std.is(offsetLocations[0], InstancingAttributeInfo)) {
			var stride = 0;
			for (i in 0...offsetLocations.length) {
				var ai:InstancingAttributeInfo = offsetLocations[i];
				stride += ai.attributeSize * 4;
			}
			for (i in 0...offsetLocations.length) {
				var ai = offsetLocations[i];
				
				if (!this._vertexAttribArraysEnabled[ai.index]) {
					Gl.enableVertexAttribArray(ai.index);
					this._vertexAttribArraysEnabled[ai.index] = true;
				}
				
				this.vertexAttribPointer(instancesBuffer, ai.index, ai.attributeSize, ai.attribyteType, ai.normalized, stride, ai.offset);
				this._caps.instancedArrays.vertexAttribDivisorANGLE(ai.index, 1);
				this._currentInstanceLocations.push(ai.index);
				this._currentInstanceBuffers.push(instancesBuffer);
			}
		}
		else {
				for (index in 0...4) {
					var offsetLocation:Int = offsetLocations[index];
					
					if (!this._vertexAttribArraysEnabled[offsetLocation]) {
						Gl.enableVertexAttribArray(offsetLocation);
						this._vertexAttribArraysEnabled[offsetLocation] = true;
					}
					
					this.vertexAttribPointer(instancesBuffer, offsetLocation, 4, GL.FLOAT, false, 64, index * 16);
					this._caps.instancedArrays.vertexAttribDivisorANGLE(offsetLocation, 1);
					this._currentInstanceLocations.push(offsetLocation);
					this._currentInstanceBuffers.push(instancesBuffer);
				}
		}
	}

	public function unBindInstancesBuffer(instancesBuffer:WebGLBuffer, offsetLocations:Array<Int>) {
		Gl.bindBuffer(GL.ARRAY_BUFFER, instancesBuffer.buffer);
		for (index in 0...4) {
			var offsetLocation = offsetLocations[index];
			Gl.disableVertexAttribArray(offsetLocation);
			
			this._caps.instancedArrays.vertexAttribDivisorANGLE(offsetLocation, 0);
		}
	}

	inline public function applyStates() {
		this._depthCullingState.apply(#if (js || purejs) Gl #end);
		this._stencilState.apply(#if (js || purejs) Gl #end);
		this._alphaState.apply(#if (js || purejs) Gl #end);
	}

	public function draw(useTriangles:Bool, indexStart:Int, indexCount:Int, instancesCount:Int = 0) {
		// Apply states
		this.applyStates();
		
		this._drawCalls++;
		
		// Render
		var indexFormat = this._uintIndicesCurrentlySet ? GL.UNSIGNED_INT : GL.UNSIGNED_SHORT;
		var mult:Int = this._uintIndicesCurrentlySet ? 4 : 2;
		if (instancesCount > 0) {
			this._caps.instancedArrays.drawElementsInstancedANGLE(useTriangles ? GL.TRIANGLES : GL.LINES, indexCount, indexFormat, indexStart * mult, instancesCount);
			
			return;
		}
		
		Gl.drawElements(useTriangles ? GL.TRIANGLES : GL.LINES, indexCount, indexFormat, Std.int(indexStart * mult));
	}

	public function drawPointClouds(verticesStart:Int, verticesCount:Int, instancesCount:Int = -1) {
		// Apply states
		this.applyStates();
		
		this._drawCalls++;
		
		if (instancesCount != -1) {
			this._caps.instancedArrays.drawArraysInstancedANGLE(GL.POINTS, verticesStart, verticesCount, instancesCount);
			
			return;
		}
		
		Gl.drawArrays(GL.POINTS, verticesStart, verticesCount);
	}
	
	public function drawUnIndexed(useTriangles:Bool, verticesStart:Int, verticesCount:Int, instancesCount:Int = -1) {
		// Apply states
		this.applyStates();
		
		this._drawCalls++;
		
		if (instancesCount != -1) {
			this._caps.instancedArrays.drawArraysInstancedANGLE(useTriangles ? GL.TRIANGLES : GL.LINES, verticesStart, verticesCount, instancesCount);
			
			return;
		}
		
		Gl.drawArrays(useTriangles ? GL.TRIANGLES : GL.LINES, verticesStart, verticesCount);
	}

	// Shaders
	public function _releaseEffect(effect:Effect) {
		if (this._compiledEffects.exists(effect._key)) {
			this._compiledEffects.remove(effect._key);
			if (effect.getProgram() != null) {
				Gl.deleteProgram(effect.getProgram());
			}
		}
	}

	public function createEffect(baseName:Dynamic, attributesNames:Array<String>, uniformsNames:Array<String>, samplers:Array<String>, defines:String, ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void, ?indexParameters:Dynamic):Effect {
		var vertex = baseName.vertexElement != null ? baseName.vertexElement : (baseName.vertex != null ? baseName.vertex : baseName);
		var fragment = baseName.fragmentElement != null ? baseName.fragmentElement : (baseName.fragment != null ? baseName.fragment : baseName);
		
		var name = vertex + "+" + fragment + "@" + defines;
		if (this._compiledEffects.exists(name)) {
			return this._compiledEffects.get(name);
		}
		
		var effect = new Effect(baseName, attributesNames, uniformsNames, samplers, this, defines, fallbacks, onCompiled, onError, indexParameters);
		effect._key = name;
		this._compiledEffects.set(name, effect);
		
		return effect;
	}

	public function createEffectForParticles(fragmentName:String, ?uniformsNames:Array<String>, ?samplers:Array<String>, defines:String = "", ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void):Effect {
		if (uniformsNames == null) {
			uniformsNames = [];
		}
		if (samplers == null) {
			samplers = [];
		}
		
		return this.createEffect(
			{
				vertex: "particles",
				fragment: fragmentName
			},
			["position", "color", "options"],
			["view", "projection"].concat(uniformsNames),
			["diffuseSampler"].concat(samplers), 
			defines, 
			fallbacks, 
			onCompiled, 
			onError
		);
	}

	public function createShaderProgram(vertexCode:String, fragmentCode:String, defines:String):GLProgram {
		var vertexShader = compileShader(#if (js || purejs) Gl, #end vertexCode, "vertex", defines);
		var fragmentShader = compileShader(#if (js || purejs) Gl, #end fragmentCode, "fragment", defines);
		
		var shaderProgram = Gl.createProgram();
		Gl.attachShader(shaderProgram, vertexShader);
		Gl.attachShader(shaderProgram, fragmentShader);
		
		Gl.linkProgram(shaderProgram);
		var linked = Gl.getProgramParameter(shaderProgram, GL.LINK_STATUS);
		
		if (linked == 0) {
			var error = Gl.getProgramInfoLog(shaderProgram);
			if (error != "") {
				throw(error);
			}
		}
		
		Gl.deleteShader(vertexShader);
		Gl.deleteShader(fragmentShader);
		
		return shaderProgram;
	}

	inline public function getUniforms(shaderProgram:GLProgram, uniformsNames:Array<String>):Map<String, GLUniformLocation> {
		var results:Map<String, GLUniformLocation> = new Map();
		
		for (name in uniformsNames) {
			var uniform = Gl.getUniformLocation(shaderProgram, name);
			#if (purejs || js || html5 || web || snow)
			if (uniform != null) {
			#else 
			if (uniform != -1) {
			#end
				results.set(name, uniform);
			}
		}
		
		return results;
	}

	inline public function getAttributes(shaderProgram:GLProgram, attributesNames:Array<String>):Array<Int> {
		var results:Array<Int> = [];
		
		for (index in 0...attributesNames.length) {
			try {
				results.push(Gl.getAttribLocation(shaderProgram, attributesNames[index]));
			}
			catch (e:Dynamic) {
				trace("getAttributes() -> ERROR: " + e);
				results.push(-1);
			}
		}
		
		return results;
	}

	inline public function enableEffect(effect:Effect) {
		/*if (effect == null || effect.getAttributesCount() == 0 || this._currentEffect == effect) {
			if (effect != null && effect.onBind != null) {
				effect.onBind(effect);
			}
			
			return;
		}*/
		
		// Use program
		this.setProgram(effect.getProgram());
		
		this._currentEffect = effect;
		
		if (effect.onBind != null) {
			effect.onBind(effect);
		}	
	}
	
	inline public function setArray(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform1fv(uniform, new Float32Array(array));
	}
	
	inline public function setArray2(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (array.length % 2 == 0) {
			Gl.uniform2fv(uniform, new Float32Array(array));
		}
	}

	inline public function setArray3(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (array.length % 3 == 0) {
			Gl.uniform3fv(uniform, new Float32Array(array));
		}
	}

	inline public function setArray4(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (array.length % 4 == 0) {
			Gl.uniform4fv(uniform, new Float32Array(array));
		}
	}

	inline public function setMatrices(uniform:GLUniformLocation, matrices: #if (js || purejs) Float32Array #else Array<Float> #end ) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniformMatrix4fv(uniform, false, #if (js || purejs) matrices #else new Float32Array(matrices) #end);
	}

	inline public function setMatrix(uniform:GLUniformLocation, matrix:Matrix) {	
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniformMatrix4fv(uniform, false, #if (js || purejs) matrix.m #else new Float32Array(matrix.m) #end );
	}
	
	inline public function setMatrix3x3(uniform:GLUniformLocation, matrix:Float32Array) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniformMatrix3fv(uniform, false, matrix);
	}

	inline public function setMatrix2x2(uniform:GLUniformLocation, matrix:Float32Array) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniformMatrix2fv(uniform, false, matrix);
	}

	inline public function setFloat(uniform:GLUniformLocation, value:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform1f(uniform, value);
	}

	inline public function setFloat2(uniform:GLUniformLocation, x:Float, y:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform2f(uniform, x, y);
	}

	inline public function setFloat3(uniform:GLUniformLocation, x:Float, y:Float, z:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform3f(uniform, x, y, z);
	}

	inline public function setBool(uniform:GLUniformLocation, bool:Bool) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform1i(uniform, bool ? 1 : 0);
	}

	public function setFloat4(uniform:GLUniformLocation, x:Float, y:Float, z:Float, w:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform4f(uniform, x, y, z, w);
	}

	inline public function setColor3(uniform:GLUniformLocation, color3:Color3) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform3f(uniform, color3.r, color3.g, color3.b);
	}

	inline public function setColor4(uniform:GLUniformLocation, color3:Color3, alpha:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		Gl.uniform4f(uniform, color3.r, color3.g, color3.b, alpha);
	}

	// States
	inline public function setState(culling:Bool, zOffset:Float = 0, force:Bool = false, reverseSide:Bool = false) {
		// Culling        
		var showSide = reverseSide ? GL.FRONT : GL.BACK;
		var hideSide = reverseSide ? GL.BACK : GL.FRONT;
		var cullFace = this.cullBackFaces ? showSide : hideSide;
			
		if (this._depthCullingState.cull != culling || force || this._depthCullingState.cullFace != cullFace) {
			if (culling) {
				this._depthCullingState.cullFace = cullFace;
				this._depthCullingState.cull = true;
			} 
			else {
				this._depthCullingState.cull = false;
			}
		}
		
		// Z offset
		this._depthCullingState.zOffset = zOffset;
	}

	inline public function setDepthBuffer(enable:Bool) {
		this._depthCullingState.depthTest = enable;
	}

	inline public function getDepthWrite():Bool {
		return this._depthCullingState.depthMask;
	}

	inline public function setDepthWrite(enable:Bool) {
		this._depthCullingState.depthMask = enable;
	}

	inline public function setColorWrite(enable:Bool) {
		Gl.colorMask(enable, enable, enable, enable);
	}

	inline public function setAlphaMode(mode:Int, noDepthWriteChange:Bool = false) {
		if (this._alphaMode == mode) {
			return;
		}
		
		switch (mode) {
			case Engine.ALPHA_DISABLE:
				this._alphaState.alphaBlend = false;
				
			case Engine.ALPHA_COMBINE:
				this._alphaState.setAlphaBlendFunctionParameters(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_ONEONE:
				this._alphaState.setAlphaBlendFunctionParameters(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_ADD:
				this._alphaState.setAlphaBlendFunctionParameters(GL.SRC_ALPHA, GL.ONE, GL.ZERO, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_SUBTRACT:
				this._alphaState.setAlphaBlendFunctionParameters(GL.ZERO, GL.ONE_MINUS_SRC_COLOR, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_MULTIPLY:
				this._alphaState.setAlphaBlendFunctionParameters(GL.DST_COLOR, GL.ZERO, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_MAXIMIZED:
				this._alphaState.setAlphaBlendFunctionParameters(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_COLOR, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
		}
		
		if (!noDepthWriteChange) {
			this.setDepthWrite(mode == Engine.ALPHA_DISABLE);
		}
		
		this._alphaMode = mode;
	}
	
	inline public function getAlphaMode():Int {
		return this._alphaMode;
	}

	inline public function setAlphaTesting(enable:Bool) {
		this._alphaTest = enable;
	}

	inline public function getAlphaTesting():Bool {
		return this._alphaTest;
	}

	// Textures
	public function wipeCaches() {
		this.resetTextureCache();
		this._currentEffect = null;
		
		this._stencilState.reset();
		this._depthCullingState.reset();
		this.setDepthFunctionToLessOrEqual();
		this._alphaState.reset();
		
		this._cachedVertexBuffers = null;
		this._cachedIndexBuffer = null;
		this._cachedEffectForVertexBuffers = null;
	}

	inline public function setSamplingMode(texture:WebGLTexture, samplingMode:Int) {
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		
		var magFilter = GL.NEAREST;
		var minFilter = GL.NEAREST;
		
		if (samplingMode == Texture.BILINEAR_SAMPLINGMODE) {
			magFilter = GL.LINEAR;
			minFilter = GL.LINEAR;
		} 
		else if (samplingMode == Texture.TRILINEAR_SAMPLINGMODE) {
			magFilter = GL.LINEAR;
			minFilter = GL.LINEAR_MIPMAP_LINEAR;
		}
		
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, magFilter);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, minFilter);
		
		this._bindTextureDirectly(GL.TEXTURE_2D, null);
		
		texture.samplingMode = samplingMode;
	}
	
	public function createTextureFromImage(img:Image, noMipmap:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):WebGLTexture {		
		var texture = new WebGLTexture("from_image", Gl.createTexture());		
		
		scene._addPendingData(texture);
		texture.url = "from_image";
		texture.noMipmap = noMipmap;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		this._loadedTexturesCache.push(texture);		
		
		prepareTexture(texture, scene, img.width, img.height, false, noMipmap, false, function(potWidth:Int, potHeight:Int) {	
			Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, potWidth, potHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, img.data);
		}, samplingMode);	
		
		return texture;
	}
	
	public function createTexture(url:String, noMipmap:Bool, invertY:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, onLoad:Void->Void = null, onError:Void->Void = null, buffer:Dynamic = null):WebGLTexture {
		
		var texture = new WebGLTexture(url, Gl.createTexture());
		
		var extension:String = "";
		var fromData:Dynamic = null;
		if (url.substr(0, 5) == "data:") {
			fromData = true;
		}
		
		if (fromData == null) {
			extension = url.substr(url.length - 4, 4).toLowerCase();
		}
		else {
			var oldUrl = url;
			fromData = oldUrl.split(':');
			url = oldUrl;
			extension = fromData[1].substr(fromData[1].length - 4, 4).toLowerCase();
		}
		
		var isDDS = this.getCaps().s3tc && (extension == ".dds");
		var isTGA = (extension == ".tga");
		
		scene._addPendingData(texture);
		texture.url = url;
		texture.noMipmap = noMipmap;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		this._loadedTexturesCache.push(texture);
		
		var onerror = function(e:Dynamic) {
			scene._removePendingData(texture);
			
			if (onError != null) {
				onError();
			}
		};
		
		if (isTGA) {
			/*var callback = function(arrayBuffer:Dynamic) {
				var data = new UInt8Array(arrayBuffer);
				
				var header = Internals.TGATools.GetTGAHeader(data);
				
				prepareTexture(texture, scene, header.width, header.height, invertY, noMipmap, false, () => {
					Internals.TGATools.UploadContent(GL, data);
					
					if (onLoad) {
						onLoad();
					}
				}, samplingMode);
			};
			
			if (!(fromData instanceof Array))
				Tools.LoadFile(url, arrayBuffer => {
					callback(arrayBuffer);
				}, onerror, scene.database, true);
			else
				callback(buffer);*/
				
		} else if (isDDS) {
			/*var callback = function(data:Dynamic) {
				var info = Internals.DDSTools.GetDDSInfo(data);
				
				var loadMipmap = (info.isRGB || info.isLuminance || info.mipmapCount > 1) && !noMipmap && ((info.width >> (info.mipmapCount - 1)) == 1);
				prepareTexture(texture, scene, info.width, info.height, invertY, !loadMipmap, info.isFourCC, () => {
				
					Internals.DDSTools.UploadDDSLevels(GL, this.getCaps().s3tc, data, info, loadMipmap, 1);
					
					if (onLoad) {
						onLoad();
					}
				}, samplingMode);
			};
			
			if (!(fromData instanceof Array))
				Tools.LoadFile(url, data => {
					callback(data);
				}, onerror, scene.database, true);
			else
				callback(buffer);*/
				
		} 
		else {
			var onload = function(img:Image) {
				prepareTexture(texture, scene, img.width, img.height, invertY, noMipmap, false, function(potWidth:Int, potHeight:Int) {	
					Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, potWidth, potHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, img.data);
					
					if (onLoad != null) {
						onLoad();
					}
				}, samplingMode);				
			};
			
			if (!Std.is(fromData, Array)) {
				Tools.LoadImage(url, onload, onerror, scene.database);
			}
			else {
				Tools.LoadImage(buffer, onload, onerror, scene.database);
			}
		}
		
		return texture;
	}
	
	/*function flipBitmapData(bd:BitmapData, axis:String = "y"):BitmapData {
		var matrix:openfl.geom.Matrix = if(axis == "x") {
			new openfl.geom.Matrix( -1, 0, 0, 1, bd.width, 0);
		} else {
			new openfl.geom.Matrix( 1, 0, 0, -1, 0, bd.height);
		}
		
		bd.draw(bd, matrix, null, null, null, true);
		
		return bd;
	}*/
	
	public function updateTextureSize(texture:WebGLTexture, width:Int, height:Int) {
		texture._width = width;
		texture._height = height;
		texture._size = width * height;
		texture._baseWidth = width;
		texture._baseHeight = height;
	}
	
	public function createRawCubeTexture(url:String, scene:Scene, size:Int, format:Int, type:Int, noMipmap:Bool = false, callback:ArrayBuffer->Array<ArrayBufferView>, mipmmapGenerator:Array<ArrayBufferView>->Array<Array<ArrayBufferView>>):WebGLTexture {
		var texture = new WebGLTexture("", Gl.createTexture());
		scene._addPendingData(texture);
		texture.isCube = true;
		texture.references = 1;
		texture.url = url;
		
		var internalFormat = this._getInternalFormat(format);
		
		var textureType = GL.UNSIGNED_BYTE;
		if (type == Engine.TEXTURETYPE_FLOAT) {
			textureType = GL.FLOAT;
		}
		
		var width = size;
		var height = width;
		var isPot = (com.babylonhx.math.Tools.IsExponentOfTwo(width) && com.babylonhx.math.Tools.IsExponentOfTwo(height));
		
		texture._width = width;
		texture._height = height;
		
		var onerror:Void->Void = function() {
			scene._removePendingData(texture);
		};
		
		var internalCallback = function(data:Dynamic) {
			var rgbeDataArrays = callback(data);
			
			var facesIndex = [
				GL.TEXTURE_CUBE_MAP_POSITIVE_X, GL.TEXTURE_CUBE_MAP_POSITIVE_Y, GL.TEXTURE_CUBE_MAP_POSITIVE_Z,
				GL.TEXTURE_CUBE_MAP_NEGATIVE_X, GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, GL.TEXTURE_CUBE_MAP_NEGATIVE_Z
			];
			
			width = texture._width;
			height = texture._height;
			isPot = (com.babylonhx.math.Tools.IsExponentOfTwo(width) && com.babylonhx.math.Tools.IsExponentOfTwo(height));
			
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
			//Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 0);
			
			if (!noMipmap && isPot) {
				if (mipmmapGenerator != null) {
					var arrayTemp:Array<ArrayBufferView> = [];
					// Data are known to be in +X +Y +Z -X -Y -Z
					// mipmmapGenerator data is expected to be order in +X -X +Y -Y +Z -Z
					arrayTemp.push(rgbeDataArrays[0]); // +X
					arrayTemp.push(rgbeDataArrays[3]); // -X
					arrayTemp.push(rgbeDataArrays[1]); // +Y
					arrayTemp.push(rgbeDataArrays[4]); // -Y
					arrayTemp.push(rgbeDataArrays[2]); // +Z
					arrayTemp.push(rgbeDataArrays[5]); // -Z
					
					var mipData = mipmmapGenerator(arrayTemp);
					for (level in 0...mipData.length) {
						var mipSize = width >> level;
						
						// mipData is order in +X -X +Y -Y +Z -Z
						Gl.texImage2D(facesIndex[0], level, internalFormat, mipSize, mipSize, 0, internalFormat, textureType, mipData[level][0]);
						Gl.texImage2D(facesIndex[1], level, internalFormat, mipSize, mipSize, 0, internalFormat, textureType, mipData[level][2]);
						Gl.texImage2D(facesIndex[2], level, internalFormat, mipSize, mipSize, 0, internalFormat, textureType, mipData[level][4]);
						Gl.texImage2D(facesIndex[3], level, internalFormat, mipSize, mipSize, 0, internalFormat, textureType, mipData[level][1]);
						Gl.texImage2D(facesIndex[4], level, internalFormat, mipSize, mipSize, 0, internalFormat, textureType, mipData[level][3]);
						Gl.texImage2D(facesIndex[5], level, internalFormat, mipSize, mipSize, 0, internalFormat, textureType, mipData[level][5]);
					}
				}
				else {
					// Data are known to be in +X +Y +Z -X -Y -Z
					for (index in 0...facesIndex.length) {
						var faceData = rgbeDataArrays[index];
						Gl.texImage2D(facesIndex[index], 0, internalFormat, width, height, 0, internalFormat, textureType, faceData);
					}
					
					Gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
				}
			}
			else {
				noMipmap = true;
			}
			
			if (textureType == GL.FLOAT && !this._caps.textureFloatLinearFiltering) {
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			}
			else if (textureType == HALF_FLOAT_OES && !this._caps.textureHalfFloatLinearFiltering) {
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			}
			else {
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, noMipmap ? GL.LINEAR : GL.LINEAR_MIPMAP_LINEAR);
			}
			
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
			
			texture.isReady = true;
			
			this.resetTextureCache();
			scene._removePendingData(texture);
		};
		
		Tools.LoadFile(url, function(data:Dynamic) {
			internalCallback(data);
		}, "hdr");
		
		return texture;
	}
		
	public function createRawTexture(data:ArrayBufferView, width:Int, height:Int, format:Int, generateMipMaps:Bool, invertY:Bool, samplingMode:Int, compression:String = ""):WebGLTexture {
		
		var texture = new WebGLTexture("", Gl.createTexture());
		texture._baseWidth = width;
		texture._baseHeight = height;
		texture._width = width;
		texture._height = height;
		texture.generateMipMaps = generateMipMaps;
		texture.samplingMode = samplingMode;
		texture.references = 1;
		
		this.updateRawTexture(texture, data, format, invertY, compression);
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	private function _getInternalFormat(format:Int):Int {
		var internalFormat = GL.RGBA;
		switch (format) {
			case Engine.TEXTUREFORMAT_ALPHA:
				internalFormat = GL.ALPHA;
				
			case Engine.TEXTUREFORMAT_LUMINANCE:
				internalFormat = GL.LUMINANCE;
				
			case Engine.TEXTUREFORMAT_LUMINANCE_ALPHA:
				internalFormat = GL.LUMINANCE_ALPHA;
				
			case Engine.TEXTUREFORMAT_RGB:
				internalFormat = GL.RGB;
				
			case Engine.TEXTUREFORMAT_RGBA:
				internalFormat = GL.RGBA;
				
		}
		
		return internalFormat;
	}
	
	inline public function updateRawTexture(texture:WebGLTexture, data:ArrayBufferView, format:Int, invertY:Bool = false, compression:String = "") {
		var internalFormat = this._getInternalFormat(format);
		
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		//Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);
		
		if (texture._width % 4 != 0) {
			Gl.pixelStorei(GL.UNPACK_ALIGNMENT, 1);
		}
		
		if (compression != "") {
			Gl.compressedTexImage2D(GL.TEXTURE_2D, 0, Reflect.getProperty(this.getCaps().s3tc, compression), texture._width, texture._height, 0, data);
		}
		else {
			Gl.texImage2D(GL.TEXTURE_2D, 0, internalFormat, texture._width, texture._height, 0, internalFormat, GL.UNSIGNED_BYTE, data);
		}
		
		// Filters
		var filters = getSamplingParameters(texture.samplingMode, texture.generateMipMaps);		
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
		
		if (texture.generateMipMaps) {
			Gl.generateMipmap(GL.TEXTURE_2D);
		}
		
		this._bindTextureDirectly(GL.TEXTURE_2D, null);
		this.resetTextureCache();
		texture.isReady = true;
	}

	public function createDynamicTexture(width:Int, height:Int, generateMipMaps:Bool, samplingMode:Int):WebGLTexture {
		var texture = new WebGLTexture("", Gl.createTexture());
		
		texture._baseWidth = width;
		texture._baseHeight = height;
		
		if (generateMipMaps) {
			width = com.babylonhx.math.Tools.GetExponentOfTwo(width, this._caps.maxTextureSize);
			height = com.babylonhx.math.Tools.GetExponentOfTwo(height, this._caps.maxTextureSize);
		}
		
		this.resetTextureCache();		
		texture._width = width;
		texture._height = height;
		texture.isReady = false;
		texture.generateMipMaps = generateMipMaps;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		
		this.updateTextureSamplingMode(samplingMode, texture);
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	inline public function updateDynamicTexture(texture:WebGLTexture, canvas:Image, invertY:Bool, premulAlpha:Bool = false) {
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		//Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);
		if (premulAlpha) {
			Gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
		}
		Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, canvas.width, canvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, cast canvas.data);
		if (texture.generateMipMaps) {
			Gl.generateMipmap(GL.TEXTURE_2D);
		}
		this._bindTextureDirectly(GL.TEXTURE_2D, null);
		if (premulAlpha) {
			Gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 0);
		}
		this.resetTextureCache();
		texture.isReady = true;
	}
	
	inline public function updateTextureSamplingMode(samplingMode:Int, texture:WebGLTexture) {
		var filters = getSamplingParameters(samplingMode, texture.generateMipMaps);
		
		if (texture.isCube) {
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
			
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, filters.mag);
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, filters.min);
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
		}
		else {
			this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
			
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
			this._bindTextureDirectly(GL.TEXTURE_2D, null);
		}
	}

	public function updateVideoTexture(texture:WebGLTexture, video:Dynamic, invertY:Bool) {
		#if (html5 || js || web || purejs)
		
		if (texture._isDisabled) {
			return;
		}
		
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY ? 0 : 1); // Video are upside down by default
		
		try {
			// Testing video texture support
			if(_videoTextureSupported == null) {
				untyped Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, video);
				if(Gl.getError() != 0) {
					_videoTextureSupported = false;
				}
				else {
					_videoTextureSupported = true;
				}
			}
			
			// Copy video through the current working canvas if video texture is not supported
			if (!_videoTextureSupported) {
				if(texture._workingCanvas == null) {
					texture._workingCanvas = cast(Browser.document.createElement("canvas"), js.html.CanvasElement);
					texture._workingContext = texture._workingCanvas.getContext("2d");
					texture._workingCanvas.width = texture._width;
					texture._workingCanvas.height = texture._height;
				}
				
				texture._workingContext.drawImage(video, 0, 0, video.videoWidth, video.videoHeight, 0, 0, texture._width, texture._height);
				
				untyped Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, texture._workingCanvas);
			}
			else {
				untyped Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, cast(video, js.html.VideoElement));
			}
			
			if(texture.generateMipMaps) {
				Gl.generateMipmap(GL.TEXTURE_2D);
			}
			
			this._bindTextureDirectly(GL.TEXTURE_2D, null);
			resetTextureCache();
			texture.isReady = true;
		}
		catch(e:Dynamic) {
			// Something unexpected
			// Let's disable the texture
			texture._isDisabled = true;
		}
		
		#end
	}

	public function createRenderTargetTexture(size:Dynamic, options:Dynamic):WebGLTexture {
		// old version had a "generateMipMaps" arg instead of options.
		// if options.generateMipMaps is undefined, consider that options itself if the generateMipmaps value
		// in the same way, generateDepthBuffer is defaulted to true
		var generateMipMaps = false;
		var generateDepthBuffer = true;
		var generateStencilBuffer = false;
		
		var type = Engine.TEXTURETYPE_UNSIGNED_INT;
		var samplingMode = Texture.TRILINEAR_SAMPLINGMODE;
		if (options != null) {
			generateMipMaps = options.generateMipMaps != null ? options.generateMipMaps : options;
			generateDepthBuffer = options.generateDepthBuffer != null ? options.generateDepthBuffer : true;
			generateStencilBuffer = options.generateStencilBuffer != null ? options.generateStencilBuffer : generateDepthBuffer;
			
			type = options.type == null ? type : options.type;
			if (options.samplingMode != null) {
				samplingMode = options.samplingMode;
			}
			if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloatLinearFiltering) {
				// if floating point (gl.FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
			else if (type == Engine.TEXTURETYPE_HALF_FLOAT && !this._caps.textureHalfFloatLinearFiltering) {
				// if floating point linear (HALF_FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
		}
		
		var texture = new WebGLTexture("", Gl.createTexture());
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		
		var width:Int = size.width != null ? size.width : size;
		var height:Int = size.height != null ? size.height : size;
		
		var filters = getSamplingParameters(samplingMode, generateMipMaps);
		
		if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloat) {
			type = Engine.TEXTURETYPE_UNSIGNED_INT;
			trace("Float textures are not supported. Render target forced to TEXTURETYPE_UNSIGNED_BYTE type");
		}
		
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		#if (snow && cpp)
		var arrBuffEmpty:ArrayBufferView = null;
		Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, getWebGLTextureType(type), arrBuffEmpty);
		#else
		Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, getWebGLTextureType(type), null);
		#end
		
		var depthStencilBuffer:GLRenderbuffer = null;
		// Create the depth/stencil buffer
		if (generateStencilBuffer) {
			depthStencilBuffer = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, depthStencilBuffer);
			Gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_STENCIL, width, height);
		}
		else if (generateDepthBuffer) {
			depthStencilBuffer = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, depthStencilBuffer);
			Gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);
		}
		
		// Create the framebuffer
		var framebuffer = Gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		
		// Manage attachments
		if (generateStencilBuffer) {
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, depthStencilBuffer);
		}
		else if (generateDepthBuffer) {
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depthStencilBuffer);
		}
		Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.data, 0);
		
		if (generateMipMaps) {
			Gl.generateMipmap(GL.TEXTURE_2D);
		}
		
		// Unbind
		this._bindTextureDirectly(GL.TEXTURE_2D, null);
		Gl.bindRenderbuffer(GL.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		texture._framebuffer = framebuffer;
		if (generateDepthBuffer) {
			texture._depthBuffer = depthStencilBuffer;
		}
		texture._baseWidth = width;
		texture._baseHeight = height;
		texture._width = width;
		texture._height = height;
		texture.isReady = true;
		texture.generateMipMaps = generateMipMaps;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		texture.type = type;
		
		this.resetTextureCache();
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createRenderTargetCubeTexture(size:Dynamic, ?options:Dynamic):WebGLTexture {
		var texture = new WebGLTexture("", Gl.createTexture());
		
		var generateMipMaps:Bool = true;
		var generateDepthBuffer:Bool = true;
		var generateStencilBuffer:Bool = false;
		
		var samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE;
		if (options != null) {
			generateMipMaps = options.generateMipMaps == null ? options : options.generateMipMaps;
			generateDepthBuffer = options.generateDepthBuffer == null ? true : options.generateDepthBuffer;
			generateStencilBuffer = options.generateStencilBuffer != null ? options.generateStencilBuffer : generateDepthBuffer;
			
			if (options.samplingMode != null) {
				samplingMode = options.samplingMode;
			}
		}
		
		texture.isCube = true;
		texture.generateMipMaps = generateMipMaps;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		
		var filters = getSamplingParameters(samplingMode, generateMipMaps);
		
		this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
		
		for (face in 0...6) {
			#if (snow && cpp)
			var arrBuffEmtpy:ArrayBufferView = null;
			Gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + face, 0, GL.RGBA, size.width, size.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, arrBuffEmtpy);
			#else
			Gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + face, 0, GL.RGBA, size.width, size.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
			#end
		}
		
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, filters.mag);
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, filters.min);
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		var depthStencilBuffer:GLRenderbuffer = null;

		// Create the depth/stencil buffer
		if (generateStencilBuffer) {
			depthStencilBuffer = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, depthStencilBuffer);
			Gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_STENCIL, size.width, size.height);
		}
		else if (generateDepthBuffer) {
			depthStencilBuffer = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, depthStencilBuffer);
			Gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, size.width, size.height);
		}
		
		// Create the framebuffer
		var framebuffer = Gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		
		// Manage attachments
		if (generateStencilBuffer) {
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, depthStencilBuffer);
		}
		else if (generateDepthBuffer) {
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depthStencilBuffer);
		}
		
		// Mipmaps
		if (texture.generateMipMaps) {
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
			Gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
		}
		
		// Unbind
		this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
		Gl.bindRenderbuffer(GL.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		texture._framebuffer = framebuffer;
		if (generateDepthBuffer) {
			texture._depthBuffer = depthStencilBuffer;
		}
		texture._width = size.width;
		texture._height = size.height;
		texture.isReady = true;
		
		this.resetTextureCache();
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}

	public function createCubeTexture(rootUrl:String, scene:Scene, files:Array<String> = null, noMipmap:Bool = false):WebGLTexture {
		var texture = new WebGLTexture(rootUrl, Gl.createTexture());
		texture.isCube = true;
		texture.url = rootUrl;
		texture.references = 1;
		//this._loadedTexturesCache.push(texture);
		
		var extension = rootUrl.substr(rootUrl.length - 4, 4).toLowerCase();
		var isDDS = this.getCaps().s3tc && (extension == ".dds");
		
		if (isDDS) {
			/*Tools.LoadFile(rootUrl, data => {
				var info = Internals.DDSTools.GetDDSInfo(data);
				
				var loadMipmap = (info.isRGB || info.isLuminance || info.mipmapCount > 1) && !noMipmap;
				
				Gl.bindTexture(gl.TEXTURE_CUBE_MAP, texture);
				Gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
				
				Internals.DDSTools.UploadDDSLevels(GL, this.getCaps().s3tc, data, info, loadMipmap, 6);
				
				if (!noMipmap && !info.isFourCC && info.mipmapCount == 1) {
					Gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
				}
				
				Gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				Gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, loadMipmap ? gl.LINEAR_MIPMAP_LINEAR :gl.LINEAR);
				Gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				Gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				
				Gl.bindTexture(gl.TEXTURE_CUBE_MAP, null);
				
				this._activeTexturesCache = [];
				
				texture._width = info.width;
				texture._height = info.height;
				texture.isReady = true;
			}, null, null, true);*/
		} 
		else {
			
			var faces = [
				GL.TEXTURE_CUBE_MAP_POSITIVE_X, GL.TEXTURE_CUBE_MAP_POSITIVE_Y, GL.TEXTURE_CUBE_MAP_POSITIVE_Z,
				GL.TEXTURE_CUBE_MAP_NEGATIVE_X, GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, GL.TEXTURE_CUBE_MAP_NEGATIVE_Z
			];
			
			var imgs:Array<Image> = [];
			
			function _setTex(img:Image, index:Int) {					
				/*var potWidth = Tools.GetExponantOfTwo(img.image.width, this._caps.maxTextureSize);
				var potHeight = Tools.GetExponantOfTwo(img.image.height, this._caps.maxTextureSize);
				var isPot = (img.image.width == potWidth && img.image.height == potHeight);*/
				this._workingCanvas = img;
					
				Gl.texImage2D(faces[index], 0, GL.RGBA, this._workingCanvas.width, this._workingCanvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, img.data);
			}
			
			function generate() {
				var width = com.babylonhx.math.Tools.GetExponentOfTwo(imgs[0].width, this._caps.maxCubemapTextureSize);
				var height = width;
				
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
				
				/*#if js
				Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 0);
				#end*/
					
				for (index in 0...faces.length) {
					_setTex(imgs[index], index);
				}
				
				if (!noMipmap) {
					Gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
				}
				
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, noMipmap ? GL.LINEAR :GL.LINEAR_MIPMAP_LINEAR);
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
				
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
				
				this.resetTextureCache();
				
				texture._width = width;
				texture._height = height;
				texture.isReady = true;
			}
			
			var i:Int = 0;
			
			function loadImage() {
				Tools.LoadImage(files[i], function(bd:Image) {
					imgs.push(bd);
					if (++i == files.length) {
						generate();
					} 
					else {
						loadImage();
					}
				});
			}
			
			loadImage();
		}
		
		return texture;
	}

	public function _releaseTexture(texture:WebGLTexture) {
		if (texture._framebuffer != null) {
			Gl.deleteFramebuffer(texture._framebuffer);
		}
		
		if (texture._depthBuffer != null) {
			Gl.deleteRenderbuffer(texture._depthBuffer);
		}
		
		Gl.deleteTexture(texture.data);
		
		// Unbind channels
		this.unbindAllTextures();		
		
		var index = this._loadedTexturesCache.indexOf(texture);
		if (index != -1) {
			this._loadedTexturesCache.splice(index, 1);
		}
		
		texture = null;
	}
	
	public function unbindAllTextures() {
		for (channel in 0...this._caps.maxTexturesImageUnits) {
			this.activateTexture(getGLTexture(channel));
			this._bindTextureDirectly(GL.TEXTURE_2D, null);
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
		}
	}
	
	inline function getGLTexture(channel:Int):Int {
		return GL.TEXTURE0 + channel;
	}
	
	inline function setProgram(program:GLProgram) {
		if (this._currentProgram != program) {
			Gl.useProgram(program);
			this._currentProgram = program;
		}
	}

	inline public function bindSamplers(effect:Effect) {
		this.setProgram(effect.getProgram());
		var samplers = effect.getSamplers();
		
		for (index in 0...samplers.length) {
			var uniform = effect.getUniform(samplers[index]);
			Gl.uniform1i(uniform, index);
		}
		this._currentEffect = null;
	}
	
	inline private function activateTexture(texture:Int) {
		if (this._activeTexture != texture - GL.TEXTURE0) {
			Gl.activeTexture(texture);
			this._activeTexture = texture - GL.TEXTURE0;
		}
	}

	inline public function _bindTextureDirectly(target:Int, texture:GLTexture) {
		if (this._activeTexturesCache[this._activeTexture] != texture) {
			Gl.bindTexture(target, texture);
			this._activeTexturesCache[this._activeTexture] = texture;
		}
	}

	inline public function _bindTexture(channel:Int, texture:GLTexture) {
		if (channel < 0) {
			return;
		}
		
		this.activateTexture(getGLTexture(channel));
		this._bindTextureDirectly(GL.TEXTURE_2D, texture);
	}

	inline public function setTextureFromPostProcess(channel:Int, postProcess:PostProcess) {
		if (postProcess._textures.length > 0) {
			this._bindTexture(channel, postProcess._textures.data[postProcess._currentRenderTextureInd].data);
		}
	}

	public function setTexture(channel:Int, uniform:GLUniformLocation, texture:BaseTexture) {
		if (channel < 0) {
			return;
		}
		
		Gl.uniform1i(uniform, channel);
		this._setTexture(channel, texture);
	}
	
	private function _setTexture(channel:Int, texture:BaseTexture) {
		// Not ready?
		if (texture == null || !texture.isReady()) {
			if (this._activeTexturesCache[channel] != null) {
				this.activateTexture(getGLTexture(channel));
				this._bindTextureDirectly(GL.TEXTURE_2D, null);
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
			}
			
			return;
		}
		
		// Video
		var alreadyActivated = false;
		if (Std.is(texture, VideoTexture)) {
			this.activateTexture(getGLTexture(channel));
			alreadyActivated = true;
			cast(texture, VideoTexture).update();
		} 
		else if (texture.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) { // Delay loading
			texture.delayLoad();
			return;
		}
		
		var internalTexture = texture.getInternalTexture();
		
		if (this._activeTexturesCache[channel] == internalTexture.data) {
			return;
		}
		
		if(!alreadyActivated) {
			this.activateTexture(getGLTexture(channel));
		}
		
		if (internalTexture.isCube) {
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, internalTexture.data);
			
			if (internalTexture._cachedCoordinatesMode != texture.coordinatesMode) {
				internalTexture._cachedCoordinatesMode = texture.coordinatesMode;
				// CUBIC_MODE and SKYBOX_MODE both require CLAMP_TO_EDGE.  All other modes use REPEAT.
				var textureWrapMode = (texture.coordinatesMode != Texture.CUBIC_MODE && texture.coordinatesMode != Texture.SKYBOX_MODE) ? GL.REPEAT : GL.CLAMP_TO_EDGE;
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, textureWrapMode);
				Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, textureWrapMode);
			}
			
			this._setAnisotropicLevel(GL.TEXTURE_CUBE_MAP, texture);
		} 
		else {
			this._bindTextureDirectly(GL.TEXTURE_2D, internalTexture.data);
			
			if (internalTexture._cachedWrapU != texture.wrapU) {
				internalTexture._cachedWrapU = texture.wrapU;
				
				switch (texture.wrapU) {
					case Texture.WRAP_ADDRESSMODE:
						Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.MIRRORED_REPEAT);
						
				}
			}
			
			if (internalTexture._cachedWrapV != texture.wrapV) {
				internalTexture._cachedWrapV = texture.wrapV;
				switch (texture.wrapV) {
					case Texture.WRAP_ADDRESSMODE:
						Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.MIRRORED_REPEAT);
						
				}
			}
			
			this._setAnisotropicLevel(GL.TEXTURE_2D, texture);
		}
	}
	
	public function setTextureArray(channel:Int, uniform:GLUniformLocation, textures:Array<BaseTexture>) {
		if (channel < 0) {
			return;
		}
		
		if (this._textureUnits == null || this._textureUnits.length != textures.length) {
			this._textureUnits = new Int32Array(textures.length);
		}
		for (i in 0...textures.length) {
			this._textureUnits[i] = channel + i;
		}
		Gl.uniform1iv(uniform, this._textureUnits);
		
		for (index in 0...textures.length) {
			this._setTexture(channel + index, textures[index]);
		}
	}

	public function _setAnisotropicLevel(key:Int, texture:BaseTexture) {
		var anisotropicFilterExtension = this._caps.textureAnisotropicFilterExtension;
		
		var value = texture.anisotropicFilteringLevel;
		
		if (texture.getInternalTexture().samplingMode == Texture.NEAREST_SAMPLINGMODE) {
			value = 1;
		}
		
		if (anisotropicFilterExtension != null && texture._cachedAnisotropicFilteringLevel != value) {
			Gl.texParameterf(key, anisotropicFilterExtension.TEXTURE_MAX_ANISOTROPY_EXT, Math.min(texture.anisotropicFilteringLevel, this._caps.maxAnisotropy));
			texture._cachedAnisotropicFilteringLevel = value;
		}
	}

	inline public function readPixels(x:Int, y:Int, width:Int, height:Int): #if (js || purejs) UInt8Array #else Array<Int> #end {
		var data = #if (js || purejs) new UInt8Array(height * width * 4) #else [] #end ;
		Gl.readPixels(x, y, width, height, GL.RGBA, GL.UNSIGNED_BYTE, cast data);
		
		return data;
	}
	
	/**
	 * Remove an externaly attached data from the Engine instance
	 * @param key the unique key that identifies the data
	 * @return true if the data was successfully removed, false if it doesn't exist
	 */
	/*public function removeExternalData(key:String):Bool {
		return this._externalData.remove(key);
	}*/

	public function releaseInternalTexture(?texture:WebGLTexture) {
		if (texture == null) {
			return;
		}
		
		texture.references--;
		
		// Final reference ?
		if (texture.references == 0) {
			var texturesCache = this.getLoadedTexturesCache();
			var index = texturesCache.indexOf(texture);
			
			if (index > -1) {
				texturesCache.splice(index, 1);
			}
			
			this._releaseTexture(texture);
		}
	}
	
	inline public function unbindAllAttributes() {
		for (i in 0...this._vertexAttribArraysEnabled.length) {
			if (i >= this._caps.maxVertexAttribs || !this._vertexAttribArraysEnabled[i]) {
				continue;
			}
			Gl.disableVertexAttribArray(i);
			this._vertexAttribArraysEnabled[i] = false;
		}
	}

	// Dispose
	public function dispose() {
		// TODO
		//this.hideLoadingUI();
		
		this.stopRenderLoop();
		
		// Release scenes
		while (this.scenes.length > 0) {
			this.scenes[0].dispose();
			this.scenes[0] = null;
			this.scenes.shift();
		}
		
		// Release effects
		for (name in this._compiledEffects.keys()) {
			Gl.deleteProgram(this._compiledEffects[name]._program);
		}
		
		// Unbind
		for (i in 0...this._vertexAttribArraysEnabled.length) {
			if (i >= this._caps.maxVertexAttribs || !this._vertexAttribArraysEnabled[i]) {
				continue;
			}
			
			Gl.disableVertexAttribArray(i);
		}
	}
	
	private function _canRenderToFloatTexture():Bool {
		return this._canRenderToTextureOfType(Engine.TEXTURETYPE_FLOAT, 'OES_texture_float');
	}

	private function _canRenderToHalfFloatTexture():Bool {
		return this._canRenderToTextureOfType(Engine.TEXTURETYPE_HALF_FLOAT, 'OES_texture_half_float');
	}

	// Thank you : http://stackoverflow.com/questions/28827511/webgl-ios-render-to-floating-point-texture
	private function _canRenderToTextureOfType(format:Int, extension:String):Bool {
		// extension.
		var ext = Gl.getExtension(extension);
		if (ext == null) {
			return false;
		}
		
		// setup GLSL program
		var vertexCode = "attribute vec4 a_position;\n" +
			"void main() {\n" +
			"	gl_Position = a_position;\n" +
			"}";
		var fragmentCode = "precision mediump float;\n" + 
			"uniform vec4 u_color;\n" +
			"uniform sampler2D u_texture;\n" +
			"void main() {\n" +
			"	gl_FragColor = texture2D(u_texture, vec2(0.5, 0.5)) * u_color;\n" +
			"}";
		var program = this.createShaderProgram(vertexCode, fragmentCode, null);
		Gl.useProgram(program);
		
		// look up where the vertex data needs to go.
		var positionLocation = Gl.getAttribLocation(program, "a_position");
		var colorLoc = Gl.getUniformLocation(program, "u_color");
		
		// provide texture coordinates for the rectangle.
		var positionBuffer = Gl.createBuffer();
		Gl.bindBuffer(GL.ARRAY_BUFFER, positionBuffer);
		Gl.bufferData(GL.ARRAY_BUFFER, new Float32Array([
			-1.0, -1.0,
			1.0, -1.0,
			-1.0, 1.0,
			-1.0, 1.0,
			1.0, -1.0,
			1.0, 1.0]), GL.STATIC_DRAW);
		Gl.enableVertexAttribArray(positionLocation);
		Gl.vertexAttribPointer(positionLocation, 2, GL.FLOAT, false, 0, 0);
		
		var whiteTex = Gl.createTexture();
		Gl.bindTexture(GL.TEXTURE_2D, whiteTex);
		Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE, new UInt8Array([255, 255, 255, 255]));
		
		var tex = Gl.createTexture();
		Gl.bindTexture(GL.TEXTURE_2D, tex);
		Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, getWebGLTextureType(format), null);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		
		var fb = Gl.createFramebuffer();
		Gl.bindFramebuffer(GL.FRAMEBUFFER, fb);
		Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, tex, 0);
		
		var cleanup = function() {
			Gl.deleteProgram(program);
			Gl.disableVertexAttribArray(positionLocation);
			Gl.deleteBuffer(positionBuffer);
			Gl.deleteFramebuffer(fb);
			Gl.deleteTexture(whiteTex);
			Gl.deleteTexture(tex);
		};
		
		var status = Gl.checkFramebufferStatus(GL.FRAMEBUFFER);
		if (status != GL.FRAMEBUFFER_COMPLETE) {
			trace("GL Support: can **NOT** render to " + format + " texture");
			cleanup();
			
			return false;
		}
		
		// Draw the rectangle.
		Gl.bindTexture(GL.TEXTURE_2D, whiteTex);
		Gl.uniform4fv(colorLoc, new Float32Array([0, 10, 20, 1]));
		Gl.drawArrays(GL.TRIANGLES, 0, 6);
		
		Gl.bindTexture(GL.TEXTURE_2D, tex);
		Gl.bindFramebuffer(GL.FRAMEBUFFER, null);
		
		Gl.clearColor(1, 0, 0, 1);
		Gl.clear(GL.COLOR_BUFFER_BIT);
		
		Gl.uniform4fv(colorLoc, new Float32Array([0, 1 / 10, 1 / 20, 1]));
		Gl.drawArrays(GL.TRIANGLES, 0, 6);
		
		var pixel = new UInt8Array(4);
		Gl.readPixels(0, 0, 1, 1, GL.RGBA, GL.UNSIGNED_BYTE, pixel);
		if (pixel[0] != 0 ||
			pixel[1] < 248 ||
			pixel[2] < 248 ||
			pixel[3] < 254) {
			trace("GL Support: Was not able to actually render to " + format + " texture");
			cleanup();
			
			return false;
		}
		
		// Succesfully rendered to "format" texture.
		cleanup();
		
		return true;
	}
	
	#if purejs
	// Statics
	public static function isSupported():Bool {
		try {
			// Avoid creating an unsized context for CocoonJS, since size determined on first creation.  Is not resizable
			if (untyped Browser.navigator.isCocoonJS) {
				return true;
			}
			var tempcanvas = Browser.document.createElement("canvas");
			var gl = untyped tempcanvas.getContext("webgl") || tempcanvas.getContext("experimental-webgl");
			
			return gl != null && untyped !!window.WebGLRenderingContext;
		} 
		catch (e:Dynamic) {
			return false;
		}
	}
	#end
}
