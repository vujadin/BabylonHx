package com.babylonhx;

import com.babylonhx.materials.EffectCreationOptions;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Scalar;
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
import com.babylonhx.math.Size;
import com.babylonhx.mesh.BufferPointer;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Viewport;
import com.babylonhx.math.Tools in MathTools;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.states._StencilState;
import com.babylonhx.tools.PerfCounter;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.WebGLVertexArrayObject;
import com.babylonhx.tools.Observable;
import com.babylonhx.utils.Image;
import lime.graphics.opengl.WebGLContext;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLContextType;
import lime.graphics.opengl.WebGL2Context;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLShader;
import lime.utils.UInt16Array;
import lime.utils.UInt8Array;
import lime.utils.UInt32Array;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.utils.Int16Array;
import lime.utils.ArrayBufferView;
import lime.utils.ArrayBuffer;

import haxe.ds.Vector;


#if (js || purejs)
import com.babylonhx.audio.AudioEngine;
import js.Browser;
#end

#if openfl
import openfl.display.OpenGLView;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The engine class is responsible for interfacing with all lower-level APIs such as WebGL and Audio.
 */
@:expose('BABYLON.Engine') class Engine {
	
	public static var Instances:Array<Engine> = [];

	public static var LastCreatedEngine(get, never):Engine;
	private static function get_LastCreatedEngine():Engine {
		if (Engine.Instances.length == 0) {
			return null;
		}
		
		return Engine.Instances[Engine.Instances.length - 1];
	}
	
	public static var LastCreatedScene(get, never):Scene;
	private static function get_LastCreatedScene():Scene {
		var lastCreatedEngine = Engine.LastCreatedEngine;
		if (lastCreatedEngine == null) {
			return null;
		}
		
		if (lastCreatedEngine.scenes.length == 0) {
			return null;
		}
		
		return lastCreatedEngine.scenes[lastCreatedEngine.scenes.length - 1];
	}

	/**
	 * Will flag all materials in all scenes in all engines as dirty to trigger new shader compilation
	 */
	public static function MarkAllMaterialsAsDirty(flag:Int, ?predicate:Material->Bool) {
		for (engineIndex in 0...Engine.Instances.length) {
			var engine = Engine.Instances[engineIndex];
			
			for (sceneIndex in 0...engine.scenes.length) {
				engine.scenes[sceneIndex].markAllMaterialsAsDirty(flag, predicate);
			}
		}
	}
	
	// Const statics

	public static inline var ALPHA_DISABLE:Int = 0;
	public static inline var ALPHA_ADD:Int = 1;
	public static inline var ALPHA_COMBINE:Int = 2;
	public static inline var ALPHA_SUBTRACT:Int = 3;
	public static inline var ALPHA_MULTIPLY:Int = 4;
	public static inline var ALPHA_MAXIMIZED:Int = 5;
	public static inline var ALPHA_ONEONE:Int = 6;
	public static inline var ALPHA_PREMULTIPLIED:Int = 7;
	public static inline var ALPHA_PREMULTIPLIED_PORTERDUFF:Int = 8;
	public static inline var ALPHA_INTERPOLATE:Int = 9;
	public static inline var ALPHA_SCREENMODE:Int = 10;

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
	
	public static /*inline*/ var HALF_FLOAT_OES:Int = 0x8D61; // Half floating-point type (16-bit).
	public static /*inline*/ var RGBA16F:Int = 0x881A; // RGBA 16-bit floating-point color-renderable internal sized format.
	public static /*inline*/ var RGBA32F:Int = 0x8814; // RGBA 32-bit floating-point color-renderable internal sized format.
	
	
	// Stencil Actions Constants.
	public static inline var KEEP:Int = 0x1E00;
	public static inline var REPLACE:Int = 0x1E01;
	public static inline var INCR:Int = 0x1E02;
	public static inline var DECR:Int = 0x1E03;
	public static inline var INVERT:Int = 0x150A;
	public static inline var INCR_WRAP:Int = 0x8507;
	public static inline var DECR_WRAP:Int = 0x8508;
	
	// Texture rescaling mode
	public static inline var SCALEMODE_FLOOR:Int = 1;
	public static inline var SCALEMODE_NEAREST:Int = 2;
	public static inline var SCALEMODE_CEILING:Int = 3;	

	// Updatable statics so stick with vars here
	public static var Version:String = "3.0.0";
	public static var CollisionsEpsilon:Float = 0.001;
	public static var ShadersRepository:String = "assets/shaders/";


	// Public members
	public var forcePOTTextures:Bool = false;
	public var isFullscreen:Bool = false;
	public var isPointerLock:Bool = false;
	public var cullBackFaces:Bool = true;
	public var renderEvenInBackground:Bool = true;
	public var preventCacheWipeBetweenFrames = false;
	// To enable/disable IDB support and avoid XHR on .manifest
	//public var enableOfflineSupport = Database;
	public var scenes:Array<Scene> = [];
	
	// Observables

	/**
	 * Observable event triggered each time the rendering canvas is resized
	 */
	public var onResizeObservable:Observable<Engine> = new Observable<Engine>();

	/**
	 * Observable event triggered each time the canvas lost focus
	 */
	#if (js || purejs)
	public var onCanvasBlurObservable:Observable<Engine> = new Observable<Engine>();
	
	
	//WebVR 

	//The new WebVR uses promises.
	//this promise resolves with the current devices available.
	public var vrDisplaysPromise:Dynamic;

	private var _vrDisplays:Dynamic;
	private var _vrDisplayEnabled:Bool;
	private var _oldSize:Size;
	private var _oldHardwareScaleFactor:Float;
	private var _vrAnimationFrameHandler:Float;
	#end
	
	
	// Private Members
	public var gl:WebGL2Context;
	private var _renderingCanvas:Dynamic;
	private var _windowIsBackground:Bool = false;
	private var _webGLVersion:Float = 1.0;
	
	public var webGLVersion(get, never):Float;
	private function get_webGLVersion():Float {
		return _webGLVersion;
	}
	
	public var needPOTTextures(get, never):Bool;
	private function get_needPOTTextures():Bool {
        return this._webGLVersion < 2 || this.forcePOTTextures;
    }
	
	private var _badOS:Bool = false;
	#if (js || purejs)
	public var audioEngine:AudioEngine = new AudioEngine();
	#end

	#if (js || purejs)
	private var _onCanvasBlur:Void->Void;
	#end
	private var _onBlur:Void->Void;
	private var _onFocus:Void->Void;
	private var _onFullscreenChange:Void->Void;
	private var _onPointerLockChange:Void->Void;
	
	private var _hardwareScalingLevel:Float;	
	private var _caps:EngineCapabilities;
	private var _pointerLockRequested:Bool;
	private var _alphaTest:Bool = false;
	private var _isStencilEnable:Bool;
	
	private var _drawCalls:PerfCounter = new PerfCounter();
	
	private var _glVersion:String;
	private var _glExtensions:Array<String>;
	private var _glRenderer:String;
	private var _glVendor:String;
	private var _glType:GLContextType;

	private var _videoTextureSupported:Null<Bool>;
	
	private var _renderingQueueLaunched:Bool = false;
	private var _activeRenderLoops:Array<Dynamic> = [];
	
	// Deterministic lockstepMaxSteps
    private var _deterministicLockstep:Bool = false;
    private var _lockstepMaxSteps:Int = 4;
	
	// FPS
	public var fpsRange:Float = 60.0;
	public var previousFramesDuration:Array<Float> = [];
	public var fps:Float = 60.0;
	public var deltaTime:Float = 0.0;

	// States
	private var _depthCullingState:_DepthCullingState = new _DepthCullingState();
	@:allow(com.babylonhx.layer.HighlightLayer)
	private var _stencilState:_StencilState = new _StencilState();
	private var _alphaState:_AlphaState = new _AlphaState();
	private var _alphaMode:Int = Engine.ALPHA_DISABLE;

	// Cache
	private var _loadedTexturesCache:Array<WebGLTexture> = [];
	private var _maxTextureChannels:Int = 16;
	private var _activeTexture:Int = 0;
	public var _activeTexturesCache:Array<GLTexture>;	// Vector<GLTexture>;	// vector doesn't work with haxe 3.2.*
	private var _currentEffect:Effect;
	private var _currentProgram:GLProgram;
	private var _compiledEffects:Map<String, Effect> = new Map<String, Effect>();
	private var _vertexAttribArraysEnabled:Array<Bool> = [];
	private var _cachedViewport:Viewport;
	private var _cachedVertexArrayObject:GLVertexArrayObject;
	private var _cachedVertexBuffers:Dynamic; // WebGLBuffer | Map<String, VertexBuffer>;
	private var _cachedIndexBuffer:WebGLBuffer;
	private var _cachedEffectForVertexBuffers:Effect;
	private var _currentRenderTarget:WebGLTexture;
	private var _uintIndicesCurrentlySet:Bool = true;// false;
	private var _currentBoundBuffer:Map<Int, WebGLBuffer> = new Map();
	private var _currentFramebuffer:GLFramebuffer;
	private var _currentBufferPointers:Array<BufferPointer> = [];
	private var _currentInstanceLocations:Array<Int> = [];
	private var _currentInstanceBuffers:Array<WebGLBuffer> = [];
	private var _textureUnits:Int32Array;

	public var _canvasClientRect:Dynamic = { x: 0, y: 0, width: 960, height: 640 };

	private var _workingCanvas:Image;
	#if openfl
	public var _workingContext:OpenGLView; 
	#end
	
	private var _rescalePostProcess:PassPostProcess;
	
	private var _dummyFramebuffer:GLFramebuffer;
	
	private var _externalData:Map<String, Dynamic>;
	private var _bindedRenderFunction:Dynamic;

	private var _vaoRecordInProgress:Bool = false;
	private var _mustWipeVertexAttributes:Bool = false;

	private var _emptyTexture:WebGLTexture;
	private var _emptyCubeTexture:WebGLTexture;

	// Hardware supported Compressed Textures
	private var _texturesSupported:Array<String> = [];
	private var _textureFormatInUse:String;

	public var texturesSupported(get, never):Array<String>;
	inline private function get_texturesSupported():Array<String> {
		return this._texturesSupported;
	}

	public var textureFormatInUse(get, never):String;
	inline private function get_textureFormatInUse():String {
		return this._textureFormatInUse;
	}

	// Empty texture
	public var emptyTexture(get, never):WebGLTexture;
	private function get_emptyTexture():WebGLTexture {
		if (this._emptyTexture == null) {
			this._emptyTexture = this.createRawTexture(new UInt8Array(4), 1, 1, Engine.TEXTUREFORMAT_RGBA, false, false, Texture.NEAREST_SAMPLINGMODE);
		}
		
		return this._emptyTexture;
	}
	
	public var emptyCubeTexture(get, never):WebGLTexture;
	private function get_emptyCubeTexture():WebGLTexture {
		if (this._emptyCubeTexture == null) {
			var faceData = new UInt8Array(4);
			var cubeData = [faceData, faceData, faceData, faceData, faceData, faceData];
			this._emptyCubeTexture = this.createRawCubeTexture(cast cubeData, 1, Engine.TEXTUREFORMAT_RGBA, Engine.TEXTURETYPE_UNSIGNED_INT, false, false, Texture.NEAREST_SAMPLINGMODE);
		}
		
		return this._emptyCubeTexture;
	}
	
	function GetExtensionName(lookFor:String):String {
		for (ext in this._glExtensions) {
			if (ext.indexOf(lookFor) != -1) {
				//trace(ext, lookFor);
				return ext;
			}
		}
		return '';
	}
	
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
	
	
	public function new(canvas:Dynamic, _gl:WebGL2Context, antialias:Bool = false, ?options:Dynamic, adaptToDeviceRatio:Bool = false) {
		this.gl = _gl;
		
		this._canvasClientRect.width = Reflect.getProperty(canvas, "width") != null ? Reflect.getProperty(canvas, "width") : 960;
		this._canvasClientRect.height = Reflect.getProperty(canvas, "height") != null ? Reflect.getProperty(canvas, "height") : 640;
		/*this.width = this._canvasClientRect.width;
		this.height = this._canvasClientRect.height;*/
		
		Engine.Instances.push(this); 
		
		options = options != null ? options : {};
		
		options.antialias = antialias;
		
		if (options.preserveDrawingBuffer == null) {
			options.preserveDrawingBuffer = false;
		}
		
		if (options.audioEngine == null) {
			options.audioEngine = true;
		}
		
		if (options.stencil == null) {
			options.stencil = true;
		}
		
		// GL
		/*#if js
		if (!Std.is(this._renderingCanvas, js.html.CanvasElement)) {
			this._renderingCanvas = Browser.document.getElementsByTagName('canvas')[0];
		}
		
		var _gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("webgl2", options);
		if (_gl == null) {
			_gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("experimental-webgl2", options);
		}
		if (_gl != null) {
			this._webGLVersion = 2;
			this.gl = _gl;
		}
		else {				
			_gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("webgl", options);
			if (_gl == null) {
				_gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("experimental-webgl", options);
			}
		}
		#end*/
		
		this._webGLVersion = #if !js 1.0 #else gl.version #end ;
		
		#if openfl
		this._workingContext = new OpenGLView();
		this._workingContext.render = this._renderLoop;
		canvas.addChild(this._workingContext);
		#end		
		
		this._onBlur = function() {
			this._windowIsBackground = true;
		};
		
		this._onFocus = function() {
			this._windowIsBackground = false;
		};
		
		#if (js || purejs)
		this._onCanvasBlur = function() {
			this.onCanvasBlurObservable.notifyObservers(this);
		};
		#end
		
		// Viewport
		this._hardwareScalingLevel = 1;
		this.resize();
		
		// Caps
		this._isStencilEnable = options.stencil;
		this._caps = new EngineCapabilities();
		this._caps.maxTexturesImageUnits = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS);
		this._caps.maxVertexTextureImageUnits = gl.getParameter(gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
		this._caps.maxTextureSize = gl.getParameter(gl.MAX_TEXTURE_SIZE);
		this._caps.maxCubemapTextureSize = gl.getParameter(gl.MAX_CUBE_MAP_TEXTURE_SIZE);
		this._caps.maxRenderTextureSize = gl.getParameter(gl.MAX_RENDERBUFFER_SIZE);
		this._caps.maxVertexAttribs = gl.getParameter(gl.MAX_VERTEX_ATTRIBS);
		this._caps.maxVaryingVectors = gl.getParameter(gl.MAX_VARYING_VECTORS);
        this._caps.maxFragmentUniformVectors = gl.getParameter(gl.MAX_FRAGMENT_UNIFORM_VECTORS);
        this._caps.maxVertexUniformVectors = gl.getParameter(gl.MAX_VERTEX_UNIFORM_VECTORS);
		
		// Infos
		this._glVersion = this.webGLVersion + "";
		this._glVendor = gl.getParameter(gl.VENDOR);
		this._glRenderer = gl.getParameter(gl.RENDERER);
		this._glExtensions = gl.getSupportedExtensions();
		
		/*for (ext in this._glExtensions) {
			trace(ext);
		}*/
		
		Engine.HALF_FLOAT_OES = 0x140B;// 0x8D61; // Half floating-point type (16-bit).	
        Engine.RGBA16F = 0x881A; // RGBA 16-bit floating-point color-renderable internal sized format.
        Engine.RGBA32F = 0x8814; // RGBA 32-bit floating-point color-renderable internal sized format.
		
		// first try js
		this._caps.standardDerivatives = true;// this._webGLVersion > 1 || (gl.getExtension('OES_standard_derivatives') != null);
		
		this._caps.astc = gl.getExtension('WEBGL_compressed_texture_astc');
		this._caps.s3tc = gl.getExtension('WEBGL_compressed_texture_s3tc');
		this._caps.pvrtc = gl.getExtension('WEBGL_compressed_texture_pvrtc');
		this._caps.etc1  = gl.getExtension('WEBGL_compressed_texture_etc1');
		this._caps.etc2  = gl.getExtension('WEBGL_compressed_texture_etc');// || this._gl.getExtension('WEBKIT_WEBGL_compressed_texture_etc'  ) ||
						   //this._gl.getExtension('WEBGL_compressed_texture_es3_0'); // also a requirement of OpenGL ES 3
		
		this._caps.textureAnisotropicFilterExtension = gl.getExtension('EXT_texture_filter_anisotropic');
		this._caps.maxAnisotropy = this._caps.textureAnisotropicFilterExtension ? gl.getParameter(this._caps.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 0;
		
		this._caps.uintIndices = this._webGLVersion > 1 || gl.getExtension('OES_element_index_uint') != null;
		this._caps.fragmentDepthSupported = this._webGLVersion > 1 || gl.getExtension('EXT_frag_depth') != null;
		this._caps.highPrecisionShaderSupported = true;
		
		#if (js && html5) 
		this._caps.drawBuffersExtension = this._webGLVersion > 1 || gl.getExtension('WEBGL_draw_buffers');
		#else
		this._caps.drawBuffersExtension = this._webGLVersion > 1 || gl.getExtension('ARB_draw_buffers');
		#end
		
		// Checks if some of the format renders first to allow the use of webgl inspector.
		#if (js && html5)
		this._caps.colorBufferFloat = this._webGLVersion > 1 && gl.getExtension('EXT_color_buffer_float');
		#else // cpp
		this._caps.colorBufferFloat = this._webGLVersion > 1 && GetExtensionName('_color_buffer_float') != '';
		#end
		
		this._caps.textureFloat = this._webGLVersion > 1 || gl.getExtension('OES_texture_float');
		this._caps.textureFloatLinearFiltering = this._caps.textureFloat && gl.getExtension('OES_texture_float_linear');
		this._caps.textureFloatRender = this._caps.textureFloat && this._canRenderToFloatFramebuffer();
		
		this._caps.textureHalfFloat = this._webGLVersion > 1 || gl.getExtension('OES_texture_half_float');
		this._caps.textureHalfFloatLinearFiltering = this._webGLVersion > 1 || (this._caps.textureHalfFloat && gl.getExtension('OES_texture_half_float_linear'));
		
		this._caps.textureHalfFloatRender = this._caps.textureHalfFloat && this._canRenderToHalfFloatFramebuffer();
		
		this._caps.textureLOD = this._webGLVersion > 1 || gl.getExtension('EXT_shader_texture_lod');
		
		// Vertex array object 
		if (this._webGLVersion > 1) {
			this._caps.vertexArrayObject = true;
		} 
		else {
			var vertexArrayObjectExtension = gl.getExtension('OES_vertex_array_object');
			
			if (vertexArrayObjectExtension != null) {
				this._caps.vertexArrayObject = true;
				//untyped gl.createVertexArray = vertexArrayObjectExtension.createVertexArrayOES;
				//untyped gl.bindVertexArray = vertexArrayObjectExtension.bindVertexArrayOES;
				//untyped gl.deleteVertexArray = vertexArrayObjectExtension.deleteVertexArrayOES;
			} 
			else {
				this._caps.vertexArrayObject = false;
			}
		}
		// Instances count            
		if (this._webGLVersion > 1) {
			this._caps.instancedArrays = true;
		} 
		else {
			var instanceExtension = gl.getExtension('ANGLE_instanced_arrays');
			
			if (instanceExtension != null) {
				this._caps.instancedArrays = true;
				//untyped gl.drawArraysInstanced = instanceExtension.drawArraysInstancedANGLE;
				//untyped gl.drawElementsInstanced = instanceExtension.drawElementsInstancedANGLE;
				//untyped gl.vertexAttribDivisor = instanceExtension.vertexAttribDivisorANGLE;
			} 
			else {
				this._caps.instancedArrays = false;
			}
		}
		
		//#if cpp
		if (this._caps.s3tc == null) {
			this._caps.s3tc = gl.getExtension(GetExtensionName('texture_compression_s3tc'));
		}
		if (this._caps.textureAnisotropicFilterExtension == null || this._caps.textureAnisotropicFilterExtension == false) {
			this._caps.textureAnisotropicFilterExtension = gl.getExtension(GetExtensionName("texture_filter_anisotropic"));
			if (this._caps.textureAnisotropicFilterExtension == null) {
				this._caps.textureAnisotropicFilterExtension = { };
				this._caps.textureAnisotropicFilterExtension.TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE;       // 34046
				this._caps.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FF;	// 34047
			}
		}
		
		this._caps.maxVertexAttribs = gl.getParameter(gl.MAX_VERTEX_ATTRIBS);
		this._caps.maxVaryingVectors = gl.getParameter(gl.MAX_VARYING_VECTORS);
        this._caps.maxFragmentUniformVectors = gl.getParameter(gl.MAX_FRAGMENT_UNIFORM_VECTORS);
        this._caps.maxVertexUniformVectors = gl.getParameter(gl.MAX_VERTEX_UNIFORM_VECTORS);
		
		this._caps.maxAnisotropy = this._caps.textureAnisotropicFilterExtension != null ? gl.getParameter(this._caps.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 16;
		if (this._caps.maxAnisotropy == 0) {
			this._caps.maxAnisotropy = 16;
		}
		//if (this._caps.maxRenderTextureSize == 0) {
			this._caps.maxRenderTextureSize = gl.getParameter(gl.MAX_RENDERBUFFER_SIZE);// 16384;
		//}
		//if (this._caps.maxCubemapTextureSize == 0) {
			this._caps.maxCubemapTextureSize = gl.getParameter(gl.MAX_CUBE_MAP_TEXTURE_SIZE);// 16384;
		//}
		//if (this._caps.maxTextureSize == 0) {
			this._caps.maxTextureSize = gl.getParameter(gl.MAX_TEXTURE_SIZE);// 16384;
		//}
		//if (this._caps.uintIndices == null) {
			this._caps.uintIndices = true;
		//}
			
		if (this._caps.standardDerivatives == false) {
			this._caps.standardDerivatives = true;
		}
		if (this._caps.textureFloat == false) {
			this._caps.textureFloat = gl.getExtension(GetExtensionName("texture_float"));
		}
		if (this._caps.fragmentDepthSupported == false) {
			this._caps.fragmentDepthSupported = gl.getExtension(GetExtensionName("frag_depth"));
		}
		if (this._caps.drawBuffersExtension == false) {
			this._caps.drawBuffersExtension = gl.getExtension(GetExtensionName("draw_buffers"));
		}
		if (this._caps.textureFloatLinearFiltering == false) {
			this._caps.textureFloatLinearFiltering = true;
		}
		if (this._caps.textureLOD == false) {
			this._caps.textureLOD = true;// gl.getExtension(GetExtensionName("shader_texture_lod"));
			if (this._caps.textureLOD) {
				this._caps.textureLODExt = "GL_ARB_shader_texture_lod";
				this._caps.textureCubeLodFnName = "textureCubeLod";
			}
		}
		this._caps.textureHalfFloat = true;// gl.getExtension(GetExtensionName('texture_half_float'));
		this._caps.textureHalfFloatLinearFiltering = true;// gl.getExtension(GetExtensionName('texture_half_float_linear'));
		this._caps.textureHalfFloatRender = true;// this._caps.textureHalfFloat && this._canRenderToHalfFloatFramebuffer();
		
		this._caps.vertexArrayObject = true;
		this._caps.instancedArrays = true;
		this._caps.highPrecisionShaderSupported = true;
		
		this._caps.fragmentDepthSupported = true;
		this._caps.textureFloatLinearFiltering = true;
		this._caps.textureFloatRender = true;
		
		this._caps.textureLOD = true;
		this._caps.drawBuffersExtension = true;
		this._caps.colorBufferFloat = true;
		//#end
		
		// Depth buffer
		this.setDepthBuffer(true);
		this.setDepthFunctionToLessOrEqual();
		this.setDepthWrite(true);
		
		// Fullscreen
		this.isFullscreen = false;
		
		// Pointer lock
		this.isPointerLock = false;	
		
		this._activeTexturesCache = [];// new Vector<GLTexture>(this._maxTextureChannels);
		
		// Prepare buffer pointers
        for (i in 0...this._caps.maxVertexAttribs) {
            this._currentBufferPointers[i] = new BufferPointer();
        }
		
		var msg:String = "BabylonHx - Cross-Platform 3D Engine | " + Date.now().getFullYear() + " | www.babylonhx.com";
		msg +=  " | GL version: " + this._glVersion + " | GL vendor: " + this._glVendor + " | GL renderer: " + this._glVendor; 
		trace(msg);
		trace(gl.getParameter(gl.VERSION));
	}
	
	public static function compileShader(gl:Dynamic, source:String, type:String, defines:String, shaderVersion:String):GLShader {
		var shader:GLShader = gl.createShader(type == "vertex" ? gl.VERTEX_SHADER : gl.FRAGMENT_SHADER);
		
		gl.shaderSource(shader, shaderVersion + (defines != null ? defines + "\n" : "") + source);
		gl.compileShader(shader);
		
		if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0) {
			throw(gl.getShaderInfoLog(shader));
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

	public static function getSamplingParameters(gl:WebGL2Context, samplingMode:Int, generateMipMaps:Bool):Dynamic {
		var magFilter = gl.NEAREST;
		var minFilter = gl.NEAREST;
		
		switch(samplingMode) {
            case Texture.BILINEAR_SAMPLINGMODE:
                magFilter = gl.LINEAR;
                if (generateMipMaps) {
                    minFilter = gl.LINEAR_MIPMAP_NEAREST;
                } 
				else {
                    minFilter = gl.LINEAR;
                }
                
            case Texture.TRILINEAR_SAMPLINGMODE:
                magFilter = gl.LINEAR;
                if (generateMipMaps) {
                    minFilter = gl.LINEAR_MIPMAP_LINEAR;
                } 
				else {
                    minFilter = gl.LINEAR;
                }
                
            case Texture.NEAREST_SAMPLINGMODE:
                magFilter = gl.NEAREST;
                if (generateMipMaps) {
                    minFilter = gl.NEAREST_MIPMAP_LINEAR;
                } 
				else {
                    minFilter = gl.NEAREST;
                }            
                
            case Texture.NEAREST_NEAREST_MIPNEAREST:
                magFilter = gl.NEAREST;
                if (generateMipMaps) {
                    minFilter = gl.NEAREST_MIPMAP_NEAREST;
                } 
				else {
                    minFilter = gl.NEAREST;
                }            
                
            case Texture.NEAREST_LINEAR_MIPNEAREST:
                magFilter = gl.NEAREST;
                if (generateMipMaps) {
                    minFilter = gl.LINEAR_MIPMAP_NEAREST;
                } 
				else {
                    minFilter = gl.LINEAR;
                }            
                  
            case Texture.NEAREST_LINEAR_MIPLINEAR:
                magFilter = gl.NEAREST;
                if (generateMipMaps) {
                    minFilter = gl.LINEAR_MIPMAP_LINEAR;
                } 
				else {
                    minFilter = gl.LINEAR;
                }            
                
            case Texture.NEAREST_LINEAR:
                magFilter = gl.NEAREST;
                minFilter = gl.LINEAR;
                
            case Texture.NEAREST_NEAREST:
                magFilter = gl.NEAREST;
                minFilter = gl.NEAREST;
                
            case Texture.LINEAR_NEAREST_MIPNEAREST:
                magFilter = gl.LINEAR;
                if (generateMipMaps) {
                    minFilter = gl.NEAREST_MIPMAP_NEAREST;
                } 
				else {
                    minFilter = gl.NEAREST;
                }     
                
            case Texture.LINEAR_NEAREST_MIPLINEAR:
                magFilter = gl.LINEAR;
                if (generateMipMaps) {
                    minFilter = gl.NEAREST_MIPMAP_LINEAR;
                } 
				else {
                    minFilter = gl.NEAREST;
                }     
                
            case Texture.LINEAR_LINEAR:
                magFilter = gl.LINEAR;
                minFilter = gl.LINEAR;
                
            case Texture.LINEAR_NEAREST:
                magFilter = gl.LINEAR;
                minFilter = gl.NEAREST;                
        }
		
		return {
			min: minFilter,
			mag: magFilter
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
	
	public function isDeterministicLockStep():Bool {
        return this._deterministicLockstep;
    }

	public function getLockstepMaxSteps():Int {
		return this._lockstepMaxSteps;
    }

	public function getAspectRatio(camera:Camera, useScreen:Bool = false):Float {
		var viewport = camera.viewport;
		
		return (this.getRenderWidth(useScreen) * viewport.width) / (this.getRenderHeight(useScreen) * viewport.height);
	}

	public function getRenderWidth(useScreen:Bool = false):Int {
		/*if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget._width;
		}*/
		
		return this.width;
	}

	public function getRenderHeight(useScreen:Bool = false):Int {
		/*if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget._height;
		}*/
		
		return this.height;
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
	
	public var drawCalls(get, never):Int;
	inline private function get_drawCalls():Int {
		return this._drawCalls.current;
	}

	public var drawCallsPerfCounter(get, never):PerfCounter;
	inline private function get_drawCallsPerfCounter():PerfCounter {
		return this._drawCalls;
	}

	// Methods	
	inline public function setDepthFunctionToGreater() {
		this._depthCullingState.depthFunc = gl.GREATER;
	}

	inline public function setDepthFunctionToGreaterOrEqual() {
		this._depthCullingState.depthFunc = gl.GEQUAL;
	}

	inline public function setDepthFunctionToLess() {
		this._depthCullingState.depthFunc = gl.LESS;
	}

	inline public function setDepthFunctionToLessOrEqual() {
		this._depthCullingState.depthFunc = gl.LEQUAL;
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
	
	public function setDitheringState(value:Bool) {
		if (value) {
			gl.enable(gl.DITHER);
		} 
		else {
			gl.disable(gl.DITHER);
		}
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

	/**
	 * Register and execute a render loop. The engine can have more than one render function.
	 * @param {Function} renderFunction - the function to continuously execute starting the next render loop.
	 * @example
	 * engine.runRenderLoop(function () {
	 *      scene.render()
	 * })
	 */
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

	public function clear(color:Dynamic, backBuffer:Bool, depth:Bool, stencil:Bool = false) {
		this.applyStates();
		
		var mode = 0;
		if (backBuffer && color != null) {
			if (color.getClassName() == 'Color4') {
				gl.clearColor(color.r, color.g, color.b, color.a);
			} 
			else {
				gl.clearColor(color.r, color.g, color.b, 1.0);
			}
			mode |= gl.COLOR_BUFFER_BIT;
		}
		
		if (depth) {
			gl.clearDepth(1.0);
			mode |= gl.DEPTH_BUFFER_BIT;
		}
		
		if (stencil) {
			gl.clearStencil(0);
			mode |= gl.STENCIL_BUFFER_BIT;
		}
		
		gl.clear(mode);
	}
	
	public function scissorClear(x:Int, y:Int, width:Int, height:Int, clearColor:Color4) {
		// Save state
		var curScissor = gl.getParameter(gl.SCISSOR_TEST);
		var curScissorBox = gl.getParameter(gl.SCISSOR_BOX);
		
		// Change state
		gl.enable(gl.SCISSOR_TEST);
		gl.scissor(x, y, width, height);
		
		// Clear
		this.clear(clearColor, true, true, true);
		
		// Restore state
		gl.scissor(curScissorBox[0], curScissorBox[1], curScissorBox[2], curScissorBox[3]);
		
		if (curScissor == true) {
			gl.enable(gl.SCISSOR_TEST);
		} 
		else {
			gl.disable(gl.SCISSOR_TEST);
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
		
		gl.viewport(Std.int(x * width), Std.int(y * height), Std.int(width * viewport.width), Std.int(height * viewport.height));
	}

	inline public function setDirectViewport(x:Int, y:Int, width:Int, height:Int):Viewport {
		var currentViewport = this._cachedViewport;
		this._cachedViewport = null;
		
		gl.viewport(x, y, width, height);
		
		return currentViewport;
	}

	inline public function beginFrame() {
		this._measureFps();
	}

	inline public function endFrame() {
		//force a flush in case we are using a bad OS.
		if (this._badOS) {
			this.flushFramebuffer();
		}
		
		//submit frame to the vr device, if enabled
		/*if (this._vrDisplayEnabled && this._vrDisplayEnabled.isPresenting) {
			this._vrDisplayEnabled.submitFrame()
		}*/
	}
	
	public function getVertexShaderSource(program:GLProgram):String {
		var shaders = gl.getAttachedShaders(program);
		
		return gl.getShaderSource(shaders[0]);
	}

	public function getFragmentShaderSource(program:GLProgram):String {
		var shaders = gl.getAttachedShaders(program);
		
		return gl.getShaderSource(shaders[1]);
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
	}
	
	/**
	 * force a specific size of the canvas
	 * @param {number} width - the new canvas' width
	 * @param {number} height - the new canvas' height
	 */
	public function setSize(width:Int, height:Int) {
		#if purejs
		if (this._renderingCanvas.width == width && this._renderingCanvas.height == height) {
			return;
		}
		
		this._renderingCanvas.width = width;
		this._renderingCanvas.height = height;
		
		for (index in 0...this.scenes.length) {
			var scene = this.scenes[index];
			
			for (camIndex in 0...scene.cameras.length) {
				var cam = scene.cameras[camIndex];
				
				cam._currentRenderId = 0;
			}
		}
		
		if (this.onResizeObservable.hasObservers) {
			this.onResizeObservable.notifyObservers(this);
		}
		#end
	}
	
	#if (js || purejs)
	//WebVR functions
	/*public function isVRDevicePresent(callback:Bool->Void) {
		this.getVRDevice(null, function(device) {
			callback(device != null);
		});
	}

	public function getVRDevice(name:String, callback:Dynamic->Void) {
		if (this.vrDisplaysPromise == null) {
			callback(null);
			return;
		}
		
		this.vrDisplaysPromise.then(function(devices) {
			if (devices.length > 0) {
				if (name != null) {
					var found = devices.some(function(device) {
						if (device.displayName == name) {
							callback(device);
							return true;
						} 
						else {
							return false;
						}
					});
					if (!found) {
						Tools.Warn("Display " + name + " was not found. Using " + devices[0].displayName);
						callback(devices[0]);
					}
				} 
				else {
					//choose the first one
					callback(devices[0]);
				}
			} 
			else {
				Tools.Error("No WebVR devices found!");
				callback(null);
			}
		});            
	}

	public function initWebVR() {
		if (this.vrDisplaysPromise == null) {
			this._getVRDisplays();
		}
	}

	public function enableVR(vrDevice:Dynamic) {
		this._vrDisplayEnabled = vrDevice;
		this._vrDisplayEnabled.requestPresent([{ source: this.getRenderingCanvas() }]).then(this._onVRFullScreenTriggered);
	}

	public function disableVR() {
		if (this._vrDisplayEnabled != null) {
			this._vrDisplayEnabled.exitPresent().then(this._onVRFullScreenTriggered);
		}
	}

	private function _onVRFullScreenTriggered() {
		if (this._vrDisplayEnabled && this._vrDisplayEnabled.isPresenting) {
			//get the old size before we change
			this._oldSize = new BABYLON.Size(this.getRenderWidth(), this.getRenderHeight());
			this._oldHardwareScaleFactor = this.getHardwareScalingLevel();
			
			//get the width and height, change the render size
			var leftEye = this._vrDisplayEnabled.getEyeParameters('left');
			var width, height;
			this.setHardwareScalingLevel(1);
			this.setSize(leftEye.renderWidth * 2, leftEye.renderHeight);
		} 
		else {
			//When the specs are implemented, need to uncomment this.
			//this._vrDisplayEnabled.cancelAnimationFrame(this._vrAnimationFrameHandler);
			this.setHardwareScalingLevel(this._oldHardwareScaleFactor);
			this.setSize(this._oldSize.width, this._oldSize.height);
			this._vrDisplayEnabled = undefined;
		}
	}

	private function _getVRDisplays() {
		var getWebVRDevices = (devices: Array<any>) => {
			var size = devices.length;
			var i = 0;
			
			this._vrDisplays = devices.filter(function (device) {
				return devices[i] instanceof VRDisplay;
			});
			
			return this._vrDisplays;
		}
		
		//using a key due to typescript
		if (navigator.getVRDisplays) {
			this.vrDisplaysPromise = navigator.getVRDisplays().then(getWebVRDevices);
		}
	}*/
	#end
	

	public function bindFramebuffer(texture:WebGLTexture, faceIndex:Int = 0, ?requiredWidth:Int, ?requiredHeight:Int, forceFullscreenViewport:Bool = false) {
		if (this._currentRenderTarget != null) {
			this.unBindFramebuffer(this._currentRenderTarget);
		}
		this._currentRenderTarget = texture;		
		this.bindUnboundFramebuffer(texture._MSAAFramebuffer != null ? texture._MSAAFramebuffer : texture._framebuffer);
		
		if (texture.isCube) {
			gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture.data, 0);
		}
		
		if (this._cachedViewport != null && !forceFullscreenViewport) {
			this.setViewport(this._cachedViewport, requiredWidth, requiredHeight); 
		}
		else {
			gl.viewport(0, 0, requiredWidth != null ? requiredWidth : texture._width, requiredHeight != null ? requiredHeight : texture._height);
		}		
		
		this.wipeCaches();
	}
	
	inline private function bindUnboundFramebuffer(framebuffer:GLFramebuffer) {
		if (this._currentFramebuffer != framebuffer) {
			gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
			this._currentFramebuffer = framebuffer;
		}
	}

	inline public function unBindFramebuffer(texture:WebGLTexture, disableGenerateMipMaps:Bool = false, ?onBeforeUnbind:Void->Void) {
		this._currentRenderTarget = null;
		
		// If MSAA, we need to bitblt back to main texture
		if (texture._MSAAFramebuffer != null) {
			gl.bindFramebuffer(gl.READ_FRAMEBUFFER, texture._MSAAFramebuffer);
			gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, texture._framebuffer);
			gl.blitFramebuffer(0, 0, texture._width, texture._height,
				0, 0, texture._width, texture._height,
				gl.COLOR_BUFFER_BIT, gl.NEAREST);
		}
		
		if (texture.generateMipMaps && !disableGenerateMipMaps && !texture.isCube) {
			this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
			gl.generateMipmap(gl.TEXTURE_2D);
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
		}
		
		if (onBeforeUnbind != null) {
			if (texture._MSAAFramebuffer != null) {
				// Bind the correct framebuffer
				this.bindUnboundFramebuffer(texture._framebuffer);
			}
			onBeforeUnbind();
		}
		
		this.bindUnboundFramebuffer(null);
	}
	
	
	
	public function generateMipMapsForCubemap(texture:WebGLTexture) {
		if (texture.generateMipMaps) {
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
			gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		}
	}

	inline public function flushFramebuffer() {
		gl.flush();
	}

	inline public function restoreDefaultFramebuffer() {
		if (this._currentRenderTarget != null) {
			this.unBindFramebuffer(this._currentRenderTarget);
		} 
		else {
			this.bindUnboundFramebuffer(null);
		}
		if (this._cachedViewport != null) {
			this.setViewport(this._cachedViewport);
		}
		
		this.wipeCaches();
	}
	
	// UBOs	
	public function createUniformBuffer(elements:Float32Array):WebGLBuffer {
		var ubo = gl.createBuffer();
		var ret = new WebGLBuffer(ubo);
		this.bindUniformBuffer(ret);
		
		gl.bufferData(gl.UNIFORM_BUFFER, elements, gl.STATIC_DRAW);
		
		this.bindUniformBuffer(null);
		
		ret.references = 1;
		return ret;
	}
	
	public function createDynamicUniformBuffer(elements:Float32Array):WebGLBuffer {
		var ubo = gl.createBuffer();
		var ret = new WebGLBuffer(ubo);
		this.bindUniformBuffer(ret);
		
		gl.bufferData(gl.UNIFORM_BUFFER, elements, gl.DYNAMIC_DRAW);
		
		this.bindUniformBuffer(null);
		
		ret.references = 1;
		return ret;
	}
	
	public function updateUniformBuffer(uniformBuffer:WebGLBuffer, elements:Float32Array, offset:Int = 0, count:Int = -1) {
		this.bindUniformBuffer(uniformBuffer);
		
		if (count == -1) {
			gl.bufferSubData(gl.UNIFORM_BUFFER, offset, elements);
		} 
		else {
			gl.bufferSubData(gl.UNIFORM_BUFFER, 0, elements.subarray(offset, offset + count));
		}
		
		this.bindUniformBuffer(null);
	}

	// VBOs
	inline private function _resetVertexBufferBinding() {
		this.bindArrayBuffer(null);
		this._cachedVertexBuffers = null;
	}
	
	inline public function createVertexBuffer(vertices:Float32Array):WebGLBuffer {
		var vbo = gl.createBuffer();
		var ret = new WebGLBuffer(vbo);
		this.bindArrayBuffer(ret);
		
		gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
		
		this._resetVertexBufferBinding();
		ret.references = 1;		
		return ret;
	}
	
	inline public function createDynamicVertexBuffer(vertices:Float32Array):WebGLBuffer {
		var vbo = gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindArrayBuffer(ret);		
		
		gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.DYNAMIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}

	// VK TODO: check why this is called every frame in Instances2 demo	
	inline public function updateDynamicVertexBuffer(vertexBuffer:WebGLBuffer, vertices:Float32Array, offset:Int = 0, count:Int = -1) {
		this.bindArrayBuffer(vertexBuffer);
		
		if (count == -1) {
			gl.bufferSubData(gl.ARRAY_BUFFER, offset, vertices);
		}
		else {
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, vertices.subarray(offset, offset + count));
		}
		
		this._resetVertexBufferBinding();
	}

	inline private function _resetIndexBufferBinding() {
		this.bindIndexBuffer(null);
		this._cachedIndexBuffer = null;
	}

	inline public function createIndexBuffer(indices:Int32Array):WebGLBuffer {
		var vbo = gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindIndexBuffer(ret);
		
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
		this._resetIndexBufferBinding();
		ret.references = 1;
		ret.is32Bits = true;		
		return ret;
	}
	
	inline public function bindArrayBuffer(buffer:WebGLBuffer) {
		if (!this._vaoRecordInProgress) {
			this._unbindVertexArrayObject();
		}
		this.bindBuffer(buffer, gl.ARRAY_BUFFER);
	}
	
	inline public function bindUniformBuffer(?buffer:WebGLBuffer) {
		gl.bindBuffer(gl.UNIFORM_BUFFER, buffer == null ? null : buffer.buffer);
	}

	inline public function bindUniformBufferBase(buffer:WebGLBuffer, location:Int) {
		gl.bindBufferBase(gl.UNIFORM_BUFFER, location, buffer.buffer);
	}

	public function bindUniformBlock(shaderProgram:GLProgram, blockName:String, index:Int) {
		var uniformLocation = gl.getUniformBlockIndex(shaderProgram, blockName);
		
		gl.uniformBlockBinding(shaderProgram, uniformLocation, index);
	}
	
	inline private function bindIndexBuffer(buffer:WebGLBuffer) {
		if (!this._vaoRecordInProgress) {
			this._unbindVertexArrayObject();
		}
		this.bindBuffer(buffer, gl.ELEMENT_ARRAY_BUFFER);
	}
	
	inline private function bindBuffer(buffer:WebGLBuffer, target:Int) {
		if (this._vaoRecordInProgress || this._currentBoundBuffer[target] != buffer) {
			gl.bindBuffer(target, buffer == null ? null : buffer.buffer);
			this._currentBoundBuffer[target] = (buffer == null ? null : buffer);
		}
	}

	inline public function updateArrayBuffer(data:Float32Array) {
		gl.bufferSubData(gl.ARRAY_BUFFER, 0, data);
	}
	
	private function vertexAttribPointer(buffer:WebGLBuffer, indx:Int, size:Int, type:Int, normalized:Bool, stride:Int, offset:Int) {
		var pointer:BufferPointer = this._currentBufferPointers[indx];
		
		var changed:Bool = false;
		if (!pointer.active) {
			changed = true;
			pointer.active = true;
			pointer.index = indx;
			pointer.size = size;
			pointer.type = type;
			pointer.normalized = normalized;
			pointer.stride = stride;
			pointer.offset = offset;
			pointer.buffer = buffer;
		} 
		else {
			if (pointer.buffer != buffer) { pointer.buffer = buffer; changed = true; }
			if (pointer.size != size) { pointer.size = size; changed = true; }
			if (pointer.type != type) { pointer.type = type; changed = true; }
			if (pointer.normalized != normalized) { pointer.normalized = normalized; changed = true; }
			if (pointer.stride != stride) { pointer.stride = stride; changed = true; }
			if (pointer.offset != offset) { pointer.offset = offset; changed = true; }
		}
		
		if (changed || this._vaoRecordInProgress) {
			this.bindArrayBuffer(buffer);
			gl.vertexAttribPointer(indx, size, type, normalized, stride, offset);
		}
	}
	
	private function _bindIndexBufferWithCache(indexBuffer:WebGLBuffer) {
		if (indexBuffer == null) {
			return;
		}
		if (this._cachedIndexBuffer != indexBuffer) {
			this._cachedIndexBuffer = indexBuffer;
			this.bindIndexBuffer(indexBuffer);
			this._uintIndicesCurrentlySet = true;// indexBuffer.is32Bits;
		}
	}

	private function _bindVertexBuffersAttributes(vertexBuffers:Map<String, VertexBuffer>, effect:Effect) {
		var attributes = effect.getAttributesNames();
		
		if (!this._vaoRecordInProgress) {
			this._unbindVertexArrayObject();
		}
		
		this.unbindAllAttributes();
		
		for (index in 0...attributes.length) {
			var order = effect.getAttributeLocation(index);
			
			if (order >= 0) {
				var vertexBuffer = vertexBuffers[attributes[index]];
				
				if (vertexBuffer == null) {
					continue;
				}
				
				gl.enableVertexAttribArray(order);
				if (!this._vaoRecordInProgress) {
					this._vertexAttribArraysEnabled[order] = true;
				}
				
				var buffer = vertexBuffer.getBuffer();
				this.vertexAttribPointer(buffer, order, vertexBuffer.getSize(), gl.FLOAT, false, Std.int(vertexBuffer.getStrideSize() * 4), Std.int(vertexBuffer.getOffset() * 4));
				
				if (vertexBuffer.getIsInstanced()) {
					gl.vertexAttribDivisor(order, vertexBuffer.getInstanceDivisor());
					if (!this._vaoRecordInProgress) {
						this._currentInstanceLocations.push(order);
						this._currentInstanceBuffers.push(buffer);
					}
				}
			}
		}
	}

	public function recordVertexArrayObject(vertexBuffers:Map<String, VertexBuffer>, indexBuffer:WebGLBuffer, effect:Effect):GLVertexArrayObject {
		var vao = gl.createVertexArray();
		
		this._vaoRecordInProgress = true;
		
		gl.bindVertexArray(vao);
		
		this._mustWipeVertexAttributes = true;
		this._bindVertexBuffersAttributes(vertexBuffers, effect);
		
		this.bindIndexBuffer(indexBuffer);
		
		this._vaoRecordInProgress = false;
		gl.bindVertexArray(null);
		
		return vao;
	}

	public function bindVertexArrayObject(vertexArrayObject:GLVertexArrayObject, indexBuffer:WebGLBuffer) {
		if (this._cachedVertexArrayObject != vertexArrayObject) {
			this._cachedVertexArrayObject = vertexArrayObject;
			
			gl.bindVertexArray(vertexArrayObject);
			this._cachedVertexBuffers = null;
			this._cachedIndexBuffer = null;
			
			this._uintIndicesCurrentlySet = true;// indexBuffer != null && indexBuffer.is32Bits;
			this._mustWipeVertexAttributes = true;
		}
	}

	public function bindBuffersDirectly(vertexBuffer:WebGLBuffer, indexBuffer:WebGLBuffer, vertexDeclaration:Array<Int>, vertexStrideSize:Int, effect:Effect) {
		if (this._cachedVertexBuffers != vertexBuffer || this._cachedEffectForVertexBuffers != effect) {
			this._cachedVertexBuffers = vertexBuffer;
			this._cachedEffectForVertexBuffers = effect;
			
			var attributesCount = effect.getAttributesCount();
			
			this._unbindVertexArrayObject();
			this.unbindAllAttributes();
			
			var offset:Int = 0;
			for (index in 0...attributesCount) {
				if (index < vertexDeclaration.length) {
					var order = effect.getAttributeLocation(index);
					
					if (order >= 0) {
						gl.enableVertexAttribArray(order);
						this._vertexAttribArraysEnabled[order] = true;						
						this.vertexAttribPointer(vertexBuffer, order, vertexDeclaration[index], gl.FLOAT, false, vertexStrideSize, offset);
					}
					
					offset += Std.int(vertexDeclaration[index] * 4);
				}
			}
		}
		
		this._bindIndexBufferWithCache(indexBuffer);
	}
	
	private function _unbindVertexArrayObject() {
		if (this._cachedVertexArrayObject == null) {
			return;
		}
		
		this._cachedVertexArrayObject = null;
		gl.bindVertexArray(null);
	}

	public function bindBuffers(vertexBuffers:Map<String, VertexBuffer>, indexBuffer:WebGLBuffer, effect:Effect) {
		if (this._cachedVertexBuffers != vertexBuffers || this._cachedEffectForVertexBuffers != effect) {
			this._cachedVertexBuffers = vertexBuffers;
			this._cachedEffectForVertexBuffers = effect;
			
			this._bindVertexBuffersAttributes(vertexBuffers, effect);
		}
		
		this._bindIndexBufferWithCache(indexBuffer);
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
			gl.vertexAttribDivisor(offsetLocation, 0);
		}
		
		this._currentInstanceBuffers.splice(0, this._currentInstanceBuffers.length);
		this._currentInstanceLocations.splice(0, this._currentInstanceLocations.length);
	}
	
	inline public function releaseVertexArrayObject(vao:GLVertexArrayObject) {
		gl.deleteVertexArray(vao);
	}
	
	public function _releaseBuffer(buffer:WebGLBuffer):Bool {
		buffer.references--;
		
		if (buffer.references == 0) {
			gl.deleteBuffer(buffer.buffer);
			return true;
		}
		
		return false;
	}

	public function createInstancesBuffer(capacity:Int):WebGLBuffer {
		var buffer = new WebGLBuffer(gl.createBuffer());
		
		buffer.capacity = capacity;
		
		this.bindArrayBuffer(buffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(capacity), gl.DYNAMIC_DRAW);
		
		return buffer;
	}

	public function deleteInstancesBuffer(buffer:WebGLBuffer) {
		gl.deleteBuffer(buffer.buffer);
		buffer = null;
	}
	
	public function updateAndBindInstancesBuffer(instancesBuffer:WebGLBuffer, data:Float32Array, offsetLocations:Array<Dynamic>) {
		this.bindArrayBuffer(instancesBuffer);
		
		if (data != null) {
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, data);
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
					gl.enableVertexAttribArray(ai.index);
					this._vertexAttribArraysEnabled[ai.index] = true;
				}
				
				this.vertexAttribPointer(instancesBuffer, ai.index, ai.attributeSize, ai.attribyteType, ai.normalized, stride, ai.offset);
				gl.vertexAttribDivisor(ai.index, 1);
				this._currentInstanceLocations.push(ai.index);
				this._currentInstanceBuffers.push(instancesBuffer);
			}
		}
		else {
			for (index in 0...4) {
				var offsetLocation:Int = offsetLocations[index];
				
				if (!this._vertexAttribArraysEnabled[offsetLocation]) {
					gl.enableVertexAttribArray(offsetLocation);
					this._vertexAttribArraysEnabled[offsetLocation] = true;
				}
				
				this.vertexAttribPointer(instancesBuffer, offsetLocation, 4, gl.FLOAT, false, 64, index * 16);
				gl.vertexAttribDivisor(offsetLocation, 1);
				this._currentInstanceLocations.push(offsetLocation);
				this._currentInstanceBuffers.push(instancesBuffer);
			}
		}
	}

	inline public function applyStates() {
		this._depthCullingState.apply(gl);
		this._stencilState.apply(gl);
		this._alphaState.apply(gl);
	}

	public function draw(useTriangles:Bool, indexStart:Int, indexCount:Int, instancesCount:Int = 0) {
		// Apply states
		this.applyStates();
		
		this._drawCalls.addCount(1, false);
		
		// Render
		var indexFormat = this._uintIndicesCurrentlySet ? gl.UNSIGNED_INT : gl.UNSIGNED_SHORT;
		var mult:Int = this._uintIndicesCurrentlySet ? 4 : 2;
		if (instancesCount > 0) {
			gl.drawElementsInstanced(useTriangles ? gl.TRIANGLES : gl.LINES, indexCount, indexFormat, indexStart * mult, instancesCount);
			return;
		}
		
		gl.drawElements(useTriangles ? gl.TRIANGLES : gl.LINES, indexCount, indexFormat, Std.int(indexStart * mult));
	}

	public function drawPointClouds(verticesStart:Int, verticesCount:Int, instancesCount:Int = 0) {
		// Apply states
		this.applyStates();
		this._drawCalls.addCount(1, false);
		
		if (instancesCount > 0) {
			gl.drawArraysInstanced(gl.POINTS, verticesStart, verticesCount, instancesCount);			
			return;
		}
		
		gl.drawArrays(gl.POINTS, verticesStart, verticesCount);
	}
	
	public function drawUnIndexed(useTriangles:Bool, verticesStart:Int, verticesCount:Int, instancesCount:Int = 0) {
		// Apply states
		this.applyStates();
		this._drawCalls.addCount(1, false);
		
		if (instancesCount > 0) {
			gl.drawArraysInstanced(useTriangles ? gl.TRIANGLES : gl.LINES, verticesStart, verticesCount, instancesCount);			
			return;
		}
		
		gl.drawArrays(useTriangles ? gl.TRIANGLES : gl.LINES, verticesStart, verticesCount);
	}

	// Shaders
	public function _releaseEffect(effect:Effect) {
		if (this._compiledEffects.exists(effect._key)) {
			this._compiledEffects.remove(effect._key);
			if (effect.getProgram() != null) {
				gl.deleteProgram(effect.getProgram());
			}
		}
	}

	public function createEffect(baseName:Dynamic, attributesNamesOrOptions:Dynamic, uniformsNamesOrEngine:Dynamic, ?samplers:Array<String>, ?defines:String, ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void, ?indexParameters:Dynamic):Effect {
		var vertex = baseName.vertexElement != null ? baseName.vertexElement : (baseName.vertex != null ? baseName.vertex : baseName);
		var fragment = baseName.fragmentElement != null ? baseName.fragmentElement : (baseName.fragment != null ? baseName.fragment : baseName);
		
		var name = vertex + "+" + fragment + "@" + (defines != null ? defines : attributesNamesOrOptions.defines);
		if (this._compiledEffects.exists(name)) {
			return this._compiledEffects.get(name);
		}
		
		var effect = new Effect(baseName, attributesNamesOrOptions, uniformsNamesOrEngine, samplers, this, defines, fallbacks, onCompiled, onError, indexParameters);
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
		var shaderVersion = (this._webGLVersion > 1) ? "#version 300 es\n" : "";
		var vertexShader = compileShader(gl, vertexCode, "vertex", defines, shaderVersion);
		var fragmentShader = compileShader(gl, fragmentCode, "fragment", defines, shaderVersion);
		
		var shaderProgram = gl.createProgram();
		gl.attachShader(shaderProgram, vertexShader);
		gl.attachShader(shaderProgram, fragmentShader);
		
		gl.linkProgram(shaderProgram);
		
		var linked = gl.getProgramParameter(shaderProgram, gl.LINK_STATUS);
		
		if ( #if (js && html5) linked == null || #end linked == 0) {
			gl.validateProgram(shaderProgram);
			var error = gl.getProgramInfoLog(shaderProgram);
			if (error != "") {
				throw(error);
			}
		}
		
		gl.deleteShader(vertexShader);
		gl.deleteShader(fragmentShader);
		
		return shaderProgram;
	}

	inline public function getUniforms(shaderProgram:GLProgram, uniformsNames:Array<String>):Array<GLUniformLocation> {
		var results:Array<GLUniformLocation> = [];
		
		for (index in 0...uniformsNames.length) {
			results.push(gl.getUniformLocation(shaderProgram, uniformsNames[index]));
		}
		
		return results;
	}

	inline public function getAttributes(shaderProgram:GLProgram, attributesNames:Array<String>):Array<Int> {
		var results:Array<Int> = [];
		
		for (index in 0...attributesNames.length) {
			try {
				results.push(gl.getAttribLocation(shaderProgram, attributesNames[index]));
			}
			catch (e:Dynamic) {
				trace("getAttributes() -> ERROR: " + e);
				results.push(-1);
			}
		}
		
		return results;
	}

	inline public function enableEffect(effect:Effect) {		
		// Use program
		this.setProgram(effect.getProgram());
		
		this._currentEffect = effect;
		
		if (effect.onBind != null) {
			effect.onBind(effect);
		}
		effect.onBindObservable.notifyObservers(effect);
	}
	
	public function setIntArray(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniform1iv(uniform, array);
		}	
	}

	public function setIntArray2(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 2 == 0) {
			gl.uniform2iv(uniform, array);
		}
	}

	public function setIntArray3(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 3 == 0) {
			gl.uniform3iv(uniform, array);
		}
	}

	public function setIntArray4(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 4 == 0) {
			gl.uniform4iv(uniform, array);
		}
	}

	public function setFloatArray(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniform1fv(uniform, array);
		}
	}

	public function setFloatArray2(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 2 == 0) {
			gl.uniform2fv(uniform, array);
		}
	}

	public function setFloatArray3(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 3 == 0) {
			gl.uniform3fv(uniform, array);
		}
	}

	public function setFloatArray4(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 4 == 0) {
			gl.uniform4fv(uniform, array);
		}
	}
	
	inline public function setArray(uniform:GLUniformLocation, array:Array<Float>) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniform1fv(uniform, new Float32Array(array)); 
		}		
	}
	
	inline public function setArray2(uniform:GLUniformLocation, array:Array<Float>) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 2 == 0) {
			gl.uniform2fv(uniform, new Float32Array(array));
		}
	}

	inline public function setArray3(uniform:GLUniformLocation, array:Array<Float>) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 3 == 0) {
			gl.uniform3fv(uniform, new Float32Array(array));
		}
	}

	inline public function setArray4(uniform:GLUniformLocation, array:Array<Float>) {
		if (uniform != #if (js && html5) null #else 0 #end && array.length % 4 == 0) {
			gl.uniform4fv(uniform, new Float32Array(array));
		}
	}

	inline public function setMatrices(uniform:GLUniformLocation, matrices:Float32Array) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniformMatrix4fv(uniform, false, matrices);
		}
	}

	inline public function setMatrix(uniform:GLUniformLocation, matrix:Matrix) {	
		if (uniform != #if (js && html5) null #else 0 #end) { 
			gl.uniformMatrix4fv(uniform, false, matrix.m);
		}
	}
	
	inline public function setMatrix3x3(uniform:GLUniformLocation, matrix:Float32Array) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniformMatrix3fv(uniform, false, matrix);
		}
	}

	inline public function setMatrix2x2(uniform:GLUniformLocation, matrix:Float32Array) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniformMatrix2fv(uniform, false, matrix);
		}
	}

	inline public function setFloat(uniform:GLUniformLocation, value:Float) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniform1f(uniform, value);
		}
	}

	inline public function setFloat2(uniform:GLUniformLocation, x:Float, y:Float) {
		if (uniform != #if (js && html5) null #else 0 #end) { 
			gl.uniform2f(uniform, x, y);
		}
	}

	inline public function setFloat3(uniform:GLUniformLocation, x:Float, y:Float, z:Float) {
		if (uniform != #if (js && html5) null #else 0 #end) { 
			gl.uniform3f(uniform, x, y, z);
		}
	}

	inline public function setBool(uniform:GLUniformLocation, bool:Bool) {
		if (uniform != #if (js && html5) null #else 0 #end) { 
			gl.uniform1i(uniform, bool ? 1 : 0);
		}
	}

	public function setFloat4(uniform:GLUniformLocation, x:Float, y:Float, z:Float, w:Float) {
		if (uniform != #if (js && html5) null #else 0 #end) { 
			gl.uniform4f(uniform, x, y, z, w);
		}
	}

	inline public function setColor3(uniform:GLUniformLocation, color3:Color3) {
		if (uniform != #if (js && html5) null #else 0 #end) { 
			gl.uniform3f(uniform, color3.r, color3.g, color3.b);
		}
	}

	inline public function setColor4(uniform:GLUniformLocation, color3:Color3, alpha:Float) {
		if (uniform != #if (js && html5) null #else 0 #end) { 
			gl.uniform4f(uniform, color3.r, color3.g, color3.b, alpha);
		}
	}

	// States
	inline public function setState(culling:Bool, zOffset:Float = 0, force:Bool = false, reverseSide:Bool = false) {
		// Culling        
		var showSide = reverseSide ? gl.FRONT : gl.BACK;
		var hideSide = reverseSide ? gl.BACK : gl.FRONT;
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
		this.setZOffset(zOffset);
	}
	
	inline public function setZOffset(value:Float) {
		this._depthCullingState.zOffset = value;
	}
	
	inline public function getZOffset():Float {
		return this._depthCullingState.zOffset;
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
		gl.colorMask(enable, enable, enable, enable);
	}
	
	inline public function setAlphaConstants(r:Float, g:Float, b:Float, a:Float) {
		this._alphaState.setAlphaBlendConstants(r, g, b, a);
	}

	inline public function setAlphaMode(mode:Int, noDepthWriteChange:Bool = false) {
		if (this._alphaMode == mode) {
			return;
		}
		
		switch (mode) {
			case Engine.ALPHA_DISABLE:
				this._alphaState.alphaBlend = false;
				
			case Engine.ALPHA_PREMULTIPLIED:
                this._alphaState.setAlphaBlendFunctionParameters(gl.ONE, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE);
                this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_PREMULTIPLIED_PORTERDUFF:
				this._alphaState.setAlphaBlendFunctionParameters(gl.ONE, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_COMBINE:
				this._alphaState.setAlphaBlendFunctionParameters(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_ONEONE:
				this._alphaState.setAlphaBlendFunctionParameters(gl.ONE, gl.ONE, gl.ZERO, gl.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_ADD:
				this._alphaState.setAlphaBlendFunctionParameters(gl.SRC_ALPHA, gl.ONE, gl.ZERO, gl.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_SUBTRACT:
				this._alphaState.setAlphaBlendFunctionParameters(gl.ZERO, gl.ONE_MINUS_SRC_COLOR, gl.ONE, gl.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_MULTIPLY:
				this._alphaState.setAlphaBlendFunctionParameters(gl.DST_COLOR, gl.ZERO, gl.ONE, gl.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_MAXIMIZED:
				this._alphaState.setAlphaBlendFunctionParameters(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_COLOR, gl.ONE, gl.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_INTERPOLATE:
				this._alphaState.setAlphaBlendFunctionParameters(gl.CONSTANT_COLOR, gl.ONE_MINUS_CONSTANT_COLOR, gl.CONSTANT_ALPHA, gl.ONE_MINUS_CONSTANT_ALPHA);
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
	public function wipeCaches(bruteForce:Bool = false) {
		if (this.preventCacheWipeBetweenFrames) {
			return;
		}
		this.resetTextureCache();
		this._currentEffect = null;
		
		// 6/8/2017: deltakosh: Should not be required anymore. 
		// This message is then mostly for the future myself which will scream out loud when seeing that actually it was required :)
		if (bruteForce) {
			this._currentProgram = null;
			
			this._stencilState.reset();
			this._depthCullingState.reset();
			this.setDepthFunctionToLessOrEqual();
			this._alphaState.reset();
		}
		
		this._cachedVertexBuffers = null;
		this._cachedIndexBuffer = null;
		this._cachedEffectForVertexBuffers = null;
		this._unbindVertexArrayObject();
		this.bindIndexBuffer(null);
		this.bindArrayBuffer(null);
	}
	
	/**
	 * Set the compressed texture format to use, based on the formats you have, and the formats
	 * supported by the hardware / browser.
	 * 
	 * Khronos Texture Container (.ktx) files are used to support this.  This format has the
	 * advantage of being specifically designed for OpenGL.  Header elements directly correspond
	 * to API arguments needed to compressed textures.  This puts the burden on the container
	 * generator to house the arcane code for determining these for current & future formats.
	 * 
	 * for description see https://www.khronos.org/opengles/sdk/tools/KTX/
	 * for file layout see https://www.khronos.org/opengles/sdk/tools/KTX/file_format_spec/
	 * 
	 * Note: The result of this call is not taken into account when a texture is base64.
	 * 
	 * @param {Array<string>} formatsAvailable- The list of those format families you have created
	 * on your server.  Syntax: '-' + format family + '.ktx'.  (Case and order do not matter.)
	 * 
	 * Current families are astc, dxt, pvrtc, etc2, & etc1.
	 * @returns The extension selected.
	 */
	public function setTextureFormatToUse(formatsAvailable:Array<String>):String {
		for (i in 0...this.texturesSupported.length) {
			for (j in 0...formatsAvailable.length) {
				if (this._texturesSupported[i] == formatsAvailable[j].toLowerCase()) {
					return this._textureFormatInUse = this._texturesSupported[i];
				}
			}
		}
		// actively set format to nothing, to allow this to be called more than once
		// and possibly fail the 2nd time
		return this._textureFormatInUse = null;
	}
	
	public function createTextureFromImage(img:Image, noMipmap:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):WebGLTexture {		
		var texture = new WebGLTexture("from_image", gl.createTexture());
		
		scene._addPendingData(texture);
		texture.url = "from_image";
		texture.generateMipMaps = noMipmap;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		this._loadedTexturesCache.push(texture);
		
		this._prepareWebGLTexture(texture, scene, img.width, img.height, false, noMipmap, false, function(potWidth:Int, potHeight:Int, continuationCallback:Dynamic) {
			gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, img.width, img.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, img.data);
			return false;
		}, samplingMode);
		
		return texture;
	}
	
	/**
	 * Usually called from BABYLON.Texture.ts.  Passed information to create a WebGLTexture.
	 * @param {string} urlArg- This contains one of the following:
	 *                         1. A conventional http URL, e.g. 'http://...' or 'file://...'
	 *                         2. A base64 string of in-line texture data, e.g. 'data:image/jpg;base64,/...'
	 *                         3. An indicator that data being passed using the buffer parameter, e.g. 'data:mytexture.jpg'
	 *
	 * @param {boolean} noMipmap- When true, no mipmaps shall be generated.  Ignored for compressed textures.  They must be in the file.
	 * @param {boolean} invertY- When true, image is flipped when loaded.  You probably want true. Ignored for compressed textures.  Must be flipped in the file.
	 * @param {Scene} scene- Needed for loading to the correct scene.
	 * @param {number} samplingMode- Mode with should be used sample / access the texture.  Default: TRILINEAR
	 * @param {callback} onLoad- Optional callback to be called upon successful completion.
	 * @param {callback} onError- Optional callback to be called upon failure.
	 * @param {ArrayBuffer | HTMLImageElement} buffer- A source of a file previously fetched as either an ArrayBuffer (compressed or image format) or HTMLImageElement (image format)
	 * @param {WebGLTexture} fallback- An internal argument in case the function must be called again, due to etc1 not having alpha capabilities.
	 * @param {number} format-  Internal format.  Default: RGB when extension is '.jpg' else RGBA.  Ignored for compressed textures.
	 * 
	 * @returns {WebGLTexture} for assignment back into BABYLON.Texture
	 */
	public function createTexture(url:String, noMipmap:Bool, invertY:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, onLoad:Void->Void = null, onError:Void->Void = null, buffer:Dynamic = null, ?fallBack:WebGLTexture, format:Int = -1):WebGLTexture {
		
		var texture = fallBack != null ? fallBack : new WebGLTexture(url, gl.createTexture());
		
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
		
		var isDDS = this.getCaps().s3tc != null && (extension == ".dds");
		var isTGA = (extension == ".tga");
		
		scene._addPendingData(texture);
		texture.url = url;
		texture.generateMipMaps = !noMipmap;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		texture.onLoadedCallbacks = [];
		
		if (onLoad != null) {
			this._loadedTexturesCache.push(texture);
		}
		if (fallBack == null) {
			this._loadedTexturesCache.push(texture);
		}
		
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
				this._prepareWebGLTexture(texture, scene, img.width, img.height, invertY, noMipmap, false, function(potWidth:Int, potHeight:Int, continuationCallback:Dynamic) {	
					var isPot = (img.width == potWidth && img.height == potHeight);
					var internalFormat = gl.RGBA;// format != -1 ? this._getInternalFormat(format) : ((extension == ".jpg") ? gl.RGB : gl.RGBA);
					
					if (isPot) {
						gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, img.width, img.height, 0, internalFormat, gl.UNSIGNED_BYTE, img.data);
						return false;
					}
					
					// Using shaders to rescale because canvas.drawImage is lossy
					var source = gl.createTexture();
					this._bindTextureDirectly(gl.TEXTURE_2D, source);
					gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, img.width, img.height, 0, internalFormat, gl.UNSIGNED_BYTE, img.data);
					
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE); 
					
					this._rescaleTexture(source, texture, scene, internalFormat, function() {
						// BHX start *****************
						//this._releaseTexture(source);		// can't do this in BHX
						gl.deleteTexture(source);
						this.unbindAllTextures();
						source = null;
						// BHX end *******************
						
						this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
						
						continuationCallback();
					});
					
					return true;
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
	
	private function _rescaleTexture(source:GLTexture, destination:WebGLTexture, scene:Scene, internalFormat:Int, onComplete:Void->Void) {
		var rtt = this.createRenderTargetTexture({
				width: destination._width,
				height: destination._height,
			}, {
				generateMipMaps: false,
				type: Engine.TEXTURETYPE_UNSIGNED_INT,
				samplingMode: Texture.BILINEAR_SAMPLINGMODE,
				generateDepthBuffer: false,
				generateStencilBuffer: false
			}
		);
		
		if (this._rescalePostProcess == null) {
			this._rescalePostProcess = new PassPostProcess("rescale", 1, null, Texture.BILINEAR_SAMPLINGMODE, this, false, Engine.TEXTURETYPE_UNSIGNED_INT);
		}
		this._rescalePostProcess.getEffect().executeWhenCompiled(function(_) {
			this._rescalePostProcess.onApply = function (effect:Effect, _) {
				effect._bindTexture("textureSampler", source);
			};
			
			scene.postProcessManager.directRender([this._rescalePostProcess], rtt);
			
			this._bindTextureDirectly(gl.TEXTURE_2D, destination.data);
			gl.copyTexImage2D(gl.TEXTURE_2D, 0, internalFormat, 0, 0, destination._width, destination._height, 0);
			
			this.unBindFramebuffer(rtt);
			this._releaseTexture(rtt);
			
			if (onComplete != null) {
				onComplete();
			}
		});
	}
	
	private function _getInternalFormat(format:Int):Int {
		var internalFormat = gl.RGBA;
		switch (format) {
			case Engine.TEXTUREFORMAT_ALPHA:
				internalFormat = gl.ALPHA;
				
			case Engine.TEXTUREFORMAT_LUMINANCE:
				internalFormat = gl.LUMINANCE;
				
			case Engine.TEXTUREFORMAT_LUMINANCE_ALPHA:
				internalFormat = gl.LUMINANCE_ALPHA;
				
			case Engine.TEXTUREFORMAT_RGB:
				internalFormat = gl.RGB;
				
			case Engine.TEXTUREFORMAT_RGBA:
				internalFormat = gl.RGBA;
				
		}
		
		return internalFormat;
	}
	
	public function updateTextureSize(texture:WebGLTexture, width:Int, height:Int) {
		texture._width = width;
		texture._height = height;
		texture._size = width * height;
		texture._baseWidth = width;
		texture._baseHeight = height;
	}
	
	public function updateRawCubeTexture(texture:WebGLTexture, data:Array<ArrayBufferView>, format:Int, type:Int, invertY:Bool, compression:String = null, level:Int = 0) {
		var textureType = this._getWebGLTextureType(type);
		var internalFormat = this._getInternalFormat(format);
		var internalSizedFomat = this._getRGBABufferInternalSizedFormat(type);
		
		var needConversion = false;
		if (internalFormat == gl.RGB) {
			internalFormat = gl.RGBA;
			needConversion = true;
		}
		
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
		//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY == null ? 1 : (invertY ? 1 : 0));
		
		if (texture._width % 4 != 0) {
			gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
		}
		
		var facesIndex = [
			gl.TEXTURE_CUBE_MAP_POSITIVE_X, gl.TEXTURE_CUBE_MAP_POSITIVE_Y, gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
			gl.TEXTURE_CUBE_MAP_NEGATIVE_X, gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
		];
		
		// Data are known to be in +X +Y +Z -X -Y -Z
		for (index in 0...facesIndex.length) {
			var faceData = data[index];
			
			if (compression != null) {
				gl.compressedTexImage2D(facesIndex[index], level, Reflect.getProperty(this.getCaps().s3tc, compression), texture._width, texture._height, 0, faceData);
			} 
			else {
				if (needConversion) {
					faceData = this._convertRGBtoRGBATextureData(faceData, texture._width, texture._height, type);
				}
				gl.texImage2D(facesIndex[index], level, internalSizedFomat, texture._width, texture._height, 0, internalFormat, textureType, faceData);
			}
		}
		
		var isPot = !this.needPOTTextures || (com.babylonhx.math.Tools.IsExponentOfTwo(texture._width) && com.babylonhx.math.Tools.IsExponentOfTwo(texture._height));
		if (isPot && texture.generateMipMaps && level == 0) {
			gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
		}
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		
		this.resetTextureCache();
		texture.isReady = true;
	}
	
	public function createRawCubeTexture(data:Array<ArrayBufferView>, size:Int, format:Int, type:Int, generateMipMaps:Bool, invertY:Bool, samplingMode:Int, compression:String = null):WebGLTexture {
		var texture = new WebGLTexture("", gl.createTexture());
		texture.isCube = true;
		texture.references = 1;
		texture.generateMipMaps = generateMipMaps;
		texture.format = format;
		texture.type = type;
		
		var textureType = this._getWebGLTextureType(type);
		var internalFormat = this._getInternalFormat(format);
		var internalSizedFomat = this._getRGBABufferInternalSizedFormat(type);
		
		var needConversion = false;
		if (internalFormat == gl.RGB) {
			internalFormat = gl.RGBA;
			needConversion = true;
		}
		
		var width = size;
		var height = width;
		
		texture._width = width;
		texture._height = height;
		
		// Double check on POT to generate Mips.
		var isPot = !this.needPOTTextures || (com.babylonhx.math.Tools.IsExponentOfTwo(texture._width) && com.babylonhx.math.Tools.IsExponentOfTwo(texture._height));
		if (!isPot) {
			generateMipMaps = false;
		}
		
		// Upload data if needed. The texture won't be ready until then.
		if (data != null) {
			this.updateRawCubeTexture(texture, data, format, type, invertY, compression);
		}
		
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
		
		// Filters
		if (data != null && generateMipMaps) {
			gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
		}
		
		if (textureType == gl.FLOAT && !this._caps.textureFloatLinearFiltering) {
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		}
		else if (textureType == Engine.HALF_FLOAT_OES && !this._caps.textureHalfFloatLinearFiltering) {
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		}
		else {
			var filters = getSamplingParameters(gl, samplingMode, generateMipMaps);
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, filters.min);
		}
		
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createRawCubeTextureFromUrl(url:String, scene:Scene, size:Int, format:Int, type:Int, noMipmap:Bool = false, callback:ArrayBuffer->Array<ArrayBufferView>, mipmmapGenerator:Array<ArrayBufferView>->Array<Array<ArrayBufferView>>, onLoad:Void->Void = null, onError:Void->Void = null, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, invertY:Bool = false):WebGLTexture {
		var texture = this.createRawCubeTexture(null, size, format, type, !noMipmap, invertY, samplingMode);
		scene._addPendingData(texture);
		texture.url = url;
		
		var onerror:Void->Void = function() {
			scene._removePendingData(texture);
			if (onError != null) {
				onError();
			}
		};
		
		var internalCallback = function(data:Dynamic) {
			var rgbeDataArrays = callback(data);
			
			var facesIndex = [
				gl.TEXTURE_CUBE_MAP_POSITIVE_X, gl.TEXTURE_CUBE_MAP_POSITIVE_Y, gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
				gl.TEXTURE_CUBE_MAP_NEGATIVE_X, gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
			];
			
			width = texture._width;
			height = texture._height;
			if (mipmmapGenerator != null) {
				// TODO Remove this once Proper CubeMap Blur... This has nothing to do in engine...
				// I ll remove ASAP.
				var textureType = this._getWebGLTextureType(type);
				var internalFormat = this._getInternalFormat(format);
				var internalSizedFomat = this._getRGBABufferInternalSizedFormat(type);
				
				var needConversion = false;
				if (internalFormat == gl.RGB) {
					internalFormat = gl.RGBA;
					needConversion = true;
				}
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
				//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 0);
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
				// mipData is order in +X -X +Y -Y +Z -Z
				var mipFaces = [0, 2, 4, 1, 3, 5];
				for (level in 0...mipData.length) {
					var mipSize = width >> level;
					
					for (mipIndex in mipFaces) {
						var mipFaceData = mipData[level][mipFaces[mipIndex]];
						if (needConversion) {
							mipFaceData = this._convertRGBtoRGBATextureData(mipFaceData, mipSize, mipSize, type);
						}
						gl.texImage2D(facesIndex[mipIndex], level, internalSizedFomat, mipSize, mipSize, 0, internalFormat, textureType, mipFaceData);
					}
				}
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
			}
			else {
				texture.generateMipMaps = !noMipmap;
				this.updateRawCubeTexture(texture, rgbeDataArrays, format, type, invertY);
			}
			
			texture.isReady = true;
			this.resetTextureCache();
			scene._removePendingData(texture);
			
			if (onLoad != null) {
				onLoad();
			}
		};
		
		Tools.LoadFile(url, function(data:Dynamic) {
			internalCallback(data);
		}, "hdr");
		
		return texture;
	}
	
	private function _prepareWebGLTextureContinuation(texture:WebGLTexture, scene:Scene, noMipmap:Bool, isCompressed:Bool, samplingMode:Int) {
		var filters = getSamplingParameters(gl, samplingMode, !noMipmap);
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
		
		if (!noMipmap && !isCompressed) {
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		
		this._bindTextureDirectly(gl.TEXTURE_2D, null);
		
		this.resetTextureCache();
		scene._removePendingData(texture);
		
		if (texture.onLoadedCallbacks != null) {
			for (callback in texture.onLoadedCallbacks) {
				callback();
			}
			texture.onLoadedCallbacks = [];
		}
	}

	private function _prepareWebGLTexture(texture:WebGLTexture, scene:Scene, width:Int, height:Int, invertY:Bool, noMipmap:Bool, isCompressed:Bool, processFunction:Int->Int->Dynamic/*Void->Void*/->Bool, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
		var potWidth = this.needPOTTextures ? MathTools.GetExponentOfTwo(width, this.getCaps().maxTextureSize) : width;
		var potHeight = this.needPOTTextures ? MathTools.GetExponentOfTwo(height, this.getCaps().maxTextureSize) : height;
		
		this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
		//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY == undefined ? 1 : (invertY ? 1 : 0));
		
		texture._baseWidth = width;
		texture._baseHeight = height;
		texture._width = potWidth;
		texture._height = potHeight;
		texture.isReady = true;
		
		if (processFunction(potWidth, potHeight, function() {
			this._prepareWebGLTextureContinuation(texture, scene, noMipmap, isCompressed, samplingMode);
		})) {
			// Returning as texture needs extra async steps
			return;
		}
		
		this._prepareWebGLTextureContinuation(texture, scene, noMipmap, isCompressed, samplingMode);
	}
	
	public function createRawTexture(data:ArrayBufferView, width:Int, height:Int, format:Int, generateMipMaps:Bool, invertY:Bool, samplingMode:Int, compression:String = ""):WebGLTexture {
		
		var texture = new WebGLTexture("", gl.createTexture());
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
	
	inline public function updateRawTexture(texture:WebGLTexture, data:ArrayBufferView, format:Int, invertY:Bool = false, compression:String = "") {
		var internalFormat = this._getInternalFormat(format);
		
		this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
		//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);
		
		if (texture._width % 4 != 0) {
			gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
		}
		
		if (compression != "") {
			gl.compressedTexImage2D(gl.TEXTURE_2D, 0, Reflect.getProperty(this.getCaps().s3tc, compression), texture._width, texture._height, 0, data);
		}
		else {
			gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, texture._width, texture._height, 0, internalFormat, gl.UNSIGNED_BYTE, data);
		}
		
		// Filters
		var filters = getSamplingParameters(gl, texture.samplingMode, texture.generateMipMaps);		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
		
		if (texture.generateMipMaps) {
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		
		this._bindTextureDirectly(gl.TEXTURE_2D, null);
		this.resetTextureCache();
		texture.isReady = true;
	}

	public function createDynamicTexture(width:Int, height:Int, generateMipMaps:Bool, samplingMode:Int):WebGLTexture {
		var texture = new WebGLTexture("", gl.createTexture());		
		texture._baseWidth = width;
		texture._baseHeight = height;
		
		if (generateMipMaps) {
			width = this.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(width, this._caps.maxTextureSize) : width;
			height = this.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(height, this._caps.maxTextureSize) : height;
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
	
	inline public function updateTextureSamplingMode(samplingMode:Int, texture:WebGLTexture) {
		var filters = getSamplingParameters(gl, samplingMode, texture.generateMipMaps);
		
		if (texture.isCube) {
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
			
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, filters.min);
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		}
		else {
			this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
			
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
		}
		
		texture.samplingMode = samplingMode;
	}
	
	inline public function updateDynamicTexture(texture:WebGLTexture, canvas:Image, invertY:Bool, premulAlpha:Bool = false, format:Int = -1) {
		this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
		//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);
		if (premulAlpha) {
			gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
		}
		var internalFormat = format != -1 ? this._getInternalFormat(format) : gl.RGBA;
		gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, canvas.width, canvas.height, 0, internalFormat, gl.UNSIGNED_BYTE, canvas.data);
		if (texture.generateMipMaps) {
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		this._bindTextureDirectly(gl.TEXTURE_2D, null);
		if (premulAlpha) {
			gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 0);
		}
		this.resetTextureCache();
		texture.isReady = true;
	}

	public function updateVideoTexture(texture:WebGLTexture, video:Dynamic, invertY:Bool) {
		#if (html5 || js || web || purejs)
		
		/*if (texture._isDisabled) {
			return;
		}
		
		this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
		gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY ? 0 : 1); // Video are upside down by default
		
		try {
			// Testing video texture support
			if(_videoTextureSupported == null) {
				untyped gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, video.width, video.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, video);
				if(gl.getError() != 0) {
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
				
				untyped gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture._workingCanvas);
			}
			else {
				untyped gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, cast(video, js.html.VideoElement));
			}
			
			if(texture.generateMipMaps) {
				gl.generateMipmap(gl.TEXTURE_2D);
			}
			
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
			resetTextureCache();
			texture.isReady = true;
		}
		catch(e:Dynamic) {
			// Something unexpected
			// Let's disable the texture
			texture._isDisabled = true;
		}*/
		
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
			generateMipMaps = options.generateMipMaps == null ? options : options.generateMipMaps;
			generateDepthBuffer = options.generateDepthBuffer == null ? true : options.generateDepthBuffer;
			generateStencilBuffer = generateDepthBuffer && options.generateStencilBuffer;
			
			type = options.type == null ? type : options.type;
			if (options.samplingMode != null) {
				samplingMode = options.samplingMode;
			}
			if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloatLinearFiltering) {
				// if floating point linear (gl.FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
			else if (type == Engine.TEXTURETYPE_HALF_FLOAT && !this._caps.textureHalfFloatLinearFiltering) {
				// if floating point linear (HALF_FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
		}
		
		var texture = new WebGLTexture("", gl.createTexture());
		this._bindTextureDirectly(gl.TEXTURE_2D, texture.data);
		
		var width = size.width != null ? size.width : size;
		var height = size.height != null ? size.height : size;
		
		var filters = getSamplingParameters(gl, samplingMode, generateMipMaps);
		
		if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloat) {
			type = Engine.TEXTURETYPE_UNSIGNED_INT;
			Tools.Warn("Float textures are not supported. Render target forced to TEXTURETYPE_UNSIGNED_BYTE type");
		}
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(type), width, height, 0, gl.RGBA, this._getWebGLTextureType(type), null);
		
		// Create the framebuffer
		var framebuffer = gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture.data, 0);
		
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(generateStencilBuffer, generateDepthBuffer, width, height);
		
		if (generateMipMaps) {
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		
		// Unbind
		this._bindTextureDirectly(gl.TEXTURE_2D, null);
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		texture._framebuffer = framebuffer;
		texture._baseWidth = width;
		texture._baseHeight = height;
		texture._width = width;
		texture._height = height;
		texture.isReady = true;
		texture.samples = 1;
		texture.generateMipMaps = generateMipMaps;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		texture.type = type;
		texture._generateDepthBuffer = generateDepthBuffer;
		texture._generateStencilBuffer = generateStencilBuffer;
		
		this.resetTextureCache();
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createMultipleRenderTarget(size:Dynamic, options:Dynamic):Array<WebGLTexture> {
		var generateMipMaps = false;
		var generateDepthBuffer = true;
		var generateStencilBuffer = false;
		var generateDepthTexture = false;
		var textureCount = 1;
		
		var defaultType = Engine.TEXTURETYPE_UNSIGNED_INT;
		var defaultSamplingMode = Texture.TRILINEAR_SAMPLINGMODE;
		
		var types:Array<Int> = [];
		var samplingModes:Array<Int> = [];
		
		if (options != null) {
			generateMipMaps = options.generateMipMaps;
			generateDepthBuffer = options.generateDepthBuffer == null ? true : options.generateDepthBuffer;
			generateStencilBuffer = options.generateStencilBuffer;
			generateDepthTexture = options.generateDepthTexture;
			textureCount = options.textureCount != null ? options.textureCount : 1;
			
			if (options.types != null) {
				types = options.types;
			}
			if (options.samplingModes != null) {
				samplingModes = options.samplingModes;
			}
		}
		
		// Create the framebuffer
		var framebuffer = gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		
		var colorRenderbuffer = gl.createRenderbuffer();
		gl.bindRenderbuffer(gl.RENDERBUFFER, colorRenderbuffer);
		gl.renderbufferStorageMultisample(gl.RENDERBUFFER, 4, gl.RGBA8, width, height);
		gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
		gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, colorRenderbuffer);
		gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT1, gl.RENDERBUFFER, colorRenderbuffer);
		gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, colorRenderbuffer);
		
		var width = size.width != null ? size.width : size;
		var height = size.height != null ? size.height : size;
		
		var textures:Array<WebGLTexture> = [];
		var attachments:Array<Int> = [];
		
		var depthStencilBuffer = this._setupFramebufferDepthAttachments(generateStencilBuffer, generateDepthBuffer, width, height);
		
		for (i in 0...textureCount) {
			var samplingMode = samplingModes.length > i ? samplingModes[i] : defaultSamplingMode;
			var type = types.length > i ? types[i] : defaultType;
			
			if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloatLinearFiltering) {
				// if floating point linear (gl.FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
			else if (type == Engine.TEXTURETYPE_HALF_FLOAT && !this._caps.textureHalfFloatLinearFiltering) {
				// if floating point linear (HALF_FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
			
			var filters = getSamplingParameters(gl, samplingMode, generateMipMaps);
			if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloat) {
				type = Engine.TEXTURETYPE_UNSIGNED_INT;
				Tools.Warn("Float textures are not supported. Render target forced to TEXTURETYPE_UNSIGNED_BYTE type");
			}
			
			var texture = new WebGLTexture("", gl.createTexture());
			var attachment = gl.COLOR_ATTACHMENT0 + i;// gl["COLOR_ATTACHMENT" + i];
			textures.push(texture);
			attachments.push(attachment);
			
			gl.activeTexture(gl.TEXTURE0 + i);
			gl.bindTexture(gl.TEXTURE_2D, texture.data);
			
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			
			gl.texImage2D(gl.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(type), width, height, 0, gl.RGBA, this._getWebGLTextureType(type), null);
			
			gl.framebufferTexture2D(gl.DRAW_FRAMEBUFFER, attachment, gl.TEXTURE_2D, texture.data, 0);
			
			if (generateMipMaps) {
				gl.generateMipmap(gl.TEXTURE_2D);
			}
			
			// Unbind
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
			
			texture._framebuffer = framebuffer;
			texture._depthStencilBuffer = depthStencilBuffer;
			texture._baseWidth = width;
			texture._baseHeight = height;
			texture._width = width;
			texture._height = height;
			texture.isReady = true;
			texture.samples = 1;
			texture.generateMipMaps = generateMipMaps;
			texture.references = 1;
			texture.samplingMode = samplingMode;
			texture.type = type;
			texture._generateDepthBuffer = generateDepthBuffer;
			texture._generateStencilBuffer = generateStencilBuffer;
			
			this._loadedTexturesCache.push(texture);
		}
		
		if (generateDepthTexture) {
			// Depth texture
			var depthTexture = new WebGLTexture('', gl.createTexture());
			
			gl.activeTexture(gl.TEXTURE0);
			gl.bindTexture(gl.TEXTURE_2D, depthTexture.data);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			gl.texImage2D(
				gl.TEXTURE_2D,
				0,
				gl.DEPTH_COMPONENT16,
				width,
				height,
				0,
				gl.DEPTH_COMPONENT,
				gl.UNSIGNED_SHORT,
				null
			);
			
			gl.framebufferTexture2D(
				gl.FRAMEBUFFER,
				gl.DEPTH_ATTACHMENT,
				gl.TEXTURE_2D,
				depthTexture.data,
				0
			);
			
			depthTexture._framebuffer = framebuffer;
			depthTexture._baseWidth = width;
			depthTexture._baseHeight = height;
			depthTexture._width = width;
			depthTexture._height = height;
			depthTexture.isReady = true;
			depthTexture.samples = 1;
			depthTexture.generateMipMaps = generateMipMaps;
			depthTexture.references = 1;
			depthTexture.samplingMode = gl.NEAREST;
			depthTexture._generateDepthBuffer = generateDepthBuffer;
			depthTexture._generateStencilBuffer = generateStencilBuffer;
			
			textures.push(depthTexture);
			this._loadedTexturesCache.push(depthTexture);
		}
		
		gl.drawBuffers(attachments);
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		this.resetTextureCache();
		
		return textures;
	}
	
	private function _setupFramebufferDepthAttachments(generateStencilBuffer:Bool, generateDepthBuffer:Bool, width:Int, height:Int, samples:Int = 1):GLRenderbuffer {
		var depthStencilBuffer:GLRenderbuffer = null;

		// Create the depth/stencil buffer
		if (generateStencilBuffer) {
			depthStencilBuffer = gl.createRenderbuffer();
			gl.bindRenderbuffer(gl.RENDERBUFFER, depthStencilBuffer);
			
			if (samples > 1) {
				gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples, gl.DEPTH24_STENCIL8, width, height);
			} 
			else {
				gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_STENCIL, width, height);
			}
			
			gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, depthStencilBuffer);
		}
		else if (generateDepthBuffer) {
			depthStencilBuffer = gl.createRenderbuffer();
			gl.bindRenderbuffer(gl.RENDERBUFFER, depthStencilBuffer);
			
			if (samples > 1) {
				gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples, gl.DEPTH_COMPONENT16, width, height);
			} 
			else {
				gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, width, height);
			}
			
			gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, depthStencilBuffer);
		}
		
		return depthStencilBuffer;
	}

	public function updateRenderTargetTextureSampleCount(texture:WebGLTexture, samples:Int):Int {
		if (this.webGLVersion < 2) {
			return 1;
		}
		
		if (texture.samples == samples) {
			return samples;
		}
		
		samples = cast Math.min(samples, gl.getParameter(gl.MAX_SAMPLES));
		
		// Dispose previous render buffers
		if (texture._depthStencilBuffer != null) {
			gl.deleteRenderbuffer(texture._depthStencilBuffer);
		}
		
		if (texture._MSAAFramebuffer != null) {
			gl.deleteFramebuffer(texture._MSAAFramebuffer);
		}
		
		if (texture._MSAARenderBuffer != null) {
			gl.deleteRenderbuffer(texture._MSAARenderBuffer);
		}
		
		if (samples > 1) {
			texture._MSAAFramebuffer = gl.createFramebuffer();
			this.bindUnboundFramebuffer(texture._MSAAFramebuffer);
			
			var colorRenderbuffer = gl.createRenderbuffer();
			gl.bindRenderbuffer(gl.RENDERBUFFER, colorRenderbuffer);
			gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples, gl.RGBA8, texture._width, texture._height);
			
			gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, colorRenderbuffer);
			
			texture._MSAARenderBuffer = colorRenderbuffer;
		} 
		else {
			this.bindUnboundFramebuffer(texture._framebuffer);
		}
		
		texture.samples = samples;
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(texture._generateStencilBuffer, texture._generateDepthBuffer, texture._width, texture._height, samples);
		
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		return samples;
	}
	
	public function _uploadDataToTexture(target:Int, lod:Int, internalFormat:Int, width:Int, height:Int, format:Int, type:Int, data:ArrayBufferView) {
        gl.texImage2D(target, lod, internalFormat, width, height, 0, format, type, data);
    }

    public function _uploadCompressedDataToTexture(target:Int, lod:Int, internalFormat:Int, width:Int, height:Int, data:ArrayBufferView) {
        gl.compressedTexImage2D(target, lod, internalFormat, width, height, 0, data);
    }
	
	public function createRenderTargetCubeTexture(size:Dynamic, ?options:Dynamic):WebGLTexture {
		var texture = new WebGLTexture("", gl.createTexture());
		
		var generateMipMaps:Bool = true;
		var generateDepthBuffer:Bool = true;
		var generateStencilBuffer:Bool = false;
		
		var samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE;
		if (options != null) {
			generateMipMaps = options.generateMipMaps == null ? options : options.generateMipMaps;
			generateDepthBuffer = options.generateDepthBuffer == null ? true : options.generateDepthBuffer;
			generateStencilBuffer = options.generateStencilBuffer && generateDepthBuffer;
			
			if (options.samplingMode != null) {
				samplingMode = options.samplingMode;
			}
		}
		
		texture.isCube = true;
		texture.generateMipMaps = generateMipMaps;
		texture.references = 1;
		texture.samples = 1;
		texture.samplingMode = samplingMode;
		
		var filters = getSamplingParameters(gl, samplingMode, generateMipMaps);
		
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
		
		for (face in 0...6) {
			gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_X + face, 0, gl.RGBA, size.width, size.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
		}
		
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, filters.mag);
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, filters.min);
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		
		// Create the framebuffer
		var framebuffer = gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(generateStencilBuffer, generateDepthBuffer, size.width, size.height);
		
		// Mipmaps
		if (texture.generateMipMaps) {
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
			gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
		}
		
		// Unbind
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		texture._framebuffer = framebuffer;
		texture._width = size.width;
		texture._height = size.height;
		texture.isReady = true;
		
		this.resetTextureCache();
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createPrefilteredCubeTexture(rootUrl:String, scene:Scene, scale:Float, offset:Float, onLoad:Void->Void, onError:Void->Void = null, ?format:Int, forcedExtension:String = null):WebGLTexture {
		var callback = function(loadData:Dynamic) {
			if (this._caps.textureLOD || loadData == null) {
				// Do not add extra process if texture lod is supported.
				if (onLoad != null) {
					onLoad();
				}
				return;
			}
			
			var mipSlices = 3;
			
			var width:Dynamic = loadData.width;
			if (width == null) {
				return;
			}
			
			var textures:Array<BaseTexture> = [];
			for (i in 0...mipSlices) {
				//compute LOD from even spacing in smoothness (matching shader calculation)
				var smoothness = i / (mipSlices - 1);
				var roughness = 1 - smoothness;
				var kMinimumVariance = 0.0005;
				
				var minLODIndex = offset; // roughness = 0
				var maxLODIndex = Scalar.Log2(width) * scale + offset; // roughness = 1
				
				var lodIndex = minLODIndex + (maxLODIndex - minLODIndex) * roughness;
				var mipmapIndex = Math.round(Math.min(Math.max(lodIndex, 0), maxLODIndex));
				
				var glTextureFromLod = new WebGLTexture('', gl.createTexture());
				glTextureFromLod.isCube = true;
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, glTextureFromLod.data);
				
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				
				// VK TODO:
				/*if (loadData.isDDS) {
					var info: Internals.DDSInfo = loadData.info;
					var data: any = loadData.data;
					gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, info.isCompressed ? 1 : 0);
					
					Internals.DDSTools.UploadDDSLevels(this, data, info, true, 6, mipmapIndex);
				}*/
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
				
				// Wrap in a base texture for easy binding.
				var lodTexture = new BaseTexture(scene);
				lodTexture.isCube = true;
				lodTexture._texture = glTextureFromLod;
				
				glTextureFromLod.isReady = true;
				textures.push(lodTexture);
			}
			
			cast(loadData.texture, WebGLTexture)._lodTextureHigh = textures[2];
			cast(loadData.texture, WebGLTexture)._lodTextureMid = textures[1];
			cast(loadData.texture, WebGLTexture)._lodTextureLow = textures[0];
			
			if (onLoad != null) {
				onLoad();
			}
		};
		
		return this.createCubeTexture(rootUrl, scene, null, false, callback, onError, format, forcedExtension);
	}

	public function createCubeTexture(rootUrl:String, scene:Scene, files:Array<String> = null, noMipmap:Bool = false, onLoad:Dynamic = null, onError:Void->Void = null, ?format:Int, forcedExtension:String = null):WebGLTexture {
		var texture = new WebGLTexture(rootUrl, gl.createTexture());
		texture.isCube = true;
		texture.url = rootUrl;
		texture.references = 1;
		texture.onLoadedCallbacks = [];
		texture.generateMipMaps = !noMipmap;
		
		var lastDot = rootUrl.lastIndexOf('.');
		var extension = forcedExtension != null ? forcedExtension : rootUrl.substring(lastDot).toLowerCase();
		var isDDS = this.getCaps().s3tc != null && (extension == ".dds");
		
		if (isDDS) {
			/*Tools.LoadFile(rootUrl, data => {
				var info = Internals.DDSTools.GetDDSInfo(data);
				
				var loadMipmap = (info.isRGB || info.isLuminance || info.mipmapCount > 1) && !noMipmap;
				
				gl.bindTexture(gl.TEXTURE_CUBE_MAP, texture);
				gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
				
				Internals.DDSTools.UploadDDSLevels(GL, this.getCaps().s3tc, data, info, loadMipmap, 6);
				
				if (!noMipmap && !info.isFourCC && info.mipmapCount == 1) {
					gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
				}
				
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, loadMipmap ? gl.LINEAR_MIPMAP_LINEAR :gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				
				gl.bindTexture(gl.TEXTURE_CUBE_MAP, null);
				
				this._activeTexturesCache = [];
				
				texture._width = info.width;
				texture._height = info.height;
				texture.isReady = true;
			}, null, null, true);*/
		} 
		else {
			
			var faces = [
				gl.TEXTURE_CUBE_MAP_POSITIVE_X, gl.TEXTURE_CUBE_MAP_POSITIVE_Y, gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
				gl.TEXTURE_CUBE_MAP_NEGATIVE_X, gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
			];
			
			var imgs:Array<Image> = [];
			
			var internalFormat = format != null ? this._getInternalFormat(format) : gl.RGBA;
			
			function generate() {
				var width = this.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(imgs[0].width, this._caps.maxCubemapTextureSize) : imgs[0].width;
				var height = width;
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture.data);
				
				for (index in 0...faces.length) {
					gl.texImage2D(faces[index], 0, internalFormat, width, height, 0, internalFormat, gl.UNSIGNED_BYTE, imgs[index].data);
				}
				
				if (!noMipmap) {
					gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
				}
				
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, noMipmap ? gl.LINEAR :gl.LINEAR_MIPMAP_LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
				
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
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	private function _convertRGBtoRGBATextureData(rgbData:ArrayBufferView, width:Int, height:Int, textureType:Int):ArrayBufferView {
		#if js
		// Create new RGBA data container.
		var rgbaData:ArrayBufferView = null;
		if (textureType == Engine.TEXTURETYPE_FLOAT) {
			rgbaData = new Float32Array(width * height * 4);
		}
		else {
			rgbaData = new UInt32Array(width * height * 4);
		}
		
		// Convert each pixel.
		for (x in 0...width) {
			for (y in 0...height) {
				var index = Std.int((y * width + x) * 3);
				var newIndex = Std.int((y * width + x) * 4);
				
				// Map Old Value to new value.
				untyped rgbaData[newIndex + 0] = rgbData[index + 0];
				untyped rgbaData[newIndex + 1] = rgbData[index + 1];
				untyped rgbaData[newIndex + 2] = rgbData[index + 2];
				
				// Add fully opaque alpha channel.
				untyped rgbaData[newIndex + 3] = 1;
			}
		}
		return rgbaData;
		#end
		return rgbData;
	}
	
	public function _releaseFramebufferObjects(texture:WebGLTexture) {
		if (texture._framebuffer != null) {
			gl.deleteFramebuffer(texture._framebuffer);
			texture._framebuffer = null;
		}
		
		if (texture._depthStencilBuffer != null) {
			gl.deleteRenderbuffer(texture._depthStencilBuffer);
			texture._depthStencilBuffer = null;
		}
		
		if (texture._MSAAFramebuffer != null) {
			gl.deleteFramebuffer(texture._MSAAFramebuffer);
			texture._MSAAFramebuffer = null;
		}
		
		if (texture._MSAARenderBuffer != null) {
			gl.deleteRenderbuffer(texture._MSAARenderBuffer);
			texture._MSAARenderBuffer = null;
		}           
	}

	public function _releaseTexture(texture:WebGLTexture) {
		this._releaseFramebufferObjects(texture);
		
		gl.deleteTexture(texture.data);
		
		// Unbind channels
		this.unbindAllTextures();		
		
		var index = this._loadedTexturesCache.indexOf(texture);
		if (index != -1) {
			this._loadedTexturesCache.splice(index, 1);
		}
		
		// Integrated fixed lod samplers.
        if (texture._lodTextureHigh != null) {
            texture._lodTextureHigh.dispose();
        }
        if (texture._lodTextureMid != null) {
            texture._lodTextureMid.dispose();
        }
        if (texture._lodTextureLow != null) {
            texture._lodTextureLow.dispose();
        }
		
		texture = null;
	}
	
	inline function getGLTexture(channel:Int):Int {
		return gl.TEXTURE0 + channel;
	}
	
	inline function setProgram(program:GLProgram) {
		if (this._currentProgram != program) {
			gl.useProgram(program);
			this._currentProgram = program;
		}
	}

	inline public function bindSamplers(effect:Effect) {
		this.setProgram(effect.getProgram());
		var samplers = effect.getSamplers();
		
		for (index in 0...samplers.length) {
			var uniform = effect.getUniform(samplers[index]);
			gl.uniform1i(uniform, index);
		}
		this._currentEffect = null;
	}
	
	private function activateTexture(texture:Int) {
		if (this._activeTexture != texture) {
			gl.activeTexture(texture);
			this._activeTexture = texture;
		}
	}

	public function _bindTextureDirectly(target:Int, texture:GLTexture) {
		if (this._activeTexturesCache[this._activeTexture] != texture) {
			gl.bindTexture(target, texture);
			this._activeTexturesCache[this._activeTexture] = texture;
		}
	}

	inline public function _bindTexture(channel:Int, texture:GLTexture) {
		if (channel < 0) {
			return;
		}
		
		this.activateTexture(gl.TEXTURE0 + channel);
		this._bindTextureDirectly(gl.TEXTURE_2D, texture);
	}

	inline public function setTextureFromPostProcess(channel:Int, postProcess:PostProcess) {
		//if (postProcess._textures.length > 0) {
			this._bindTexture(channel, postProcess._textures.data[postProcess._currentRenderTextureInd].data);
		//}
	}
	
	public function unbindAllTextures() {
		for (channel in 0...this._caps.maxTexturesImageUnits) {
			this.activateTexture(gl.TEXTURE0 + channel);
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		}
	}

	public function setTexture(channel:Int, uniform:GLUniformLocation, texture:BaseTexture) {
		if (channel < 0) {
			return;
		}
		
		gl.uniform1i(uniform, channel);
		this._setTexture(channel, texture);
	}
	
	private function _setTexture(channel:Int, texture:BaseTexture) {
		// Not ready?
		if (texture == null) {
			if (this._activeTexturesCache[channel] != null) {
				this.activateTexture(gl.TEXTURE0 + channel);
				this._bindTextureDirectly(gl.TEXTURE_2D, null);
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
			}
			
			return;
		}
		
		// Video
		var alreadyActivated = false;
		if (Std.is(texture, VideoTexture)) {
			this.activateTexture(gl.TEXTURE0 + channel);
			alreadyActivated = true;
			cast(texture, VideoTexture).update();
		} 
		else if (texture.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) { // Delay loading
			texture.delayLoad();
			return;
		}
		
		var internalTexture = texture.isReady() ? texture.getInternalTexture() : (texture.isCube ? this.emptyCubeTexture : this.emptyTexture);
		
		if (internalTexture == null /* <- BHX */ || this._activeTexturesCache[channel] == internalTexture.data) {
			return;
		}
		
		if (!alreadyActivated) {
			this.activateTexture(gl.TEXTURE0 + channel);
		}
		
		if (internalTexture.isCube) {
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, internalTexture.data);
			
			if (internalTexture._cachedCoordinatesMode != texture.coordinatesMode) {
				internalTexture._cachedCoordinatesMode = texture.coordinatesMode;
				// CUBIC_MODE and SKYBOX_MODE both require CLAMP_TO_EDGE.  All other modes use REPEAT.
				var textureWrapMode = (texture.coordinatesMode != Texture.CUBIC_MODE && texture.coordinatesMode != Texture.SKYBOX_MODE) ? gl.REPEAT : gl.CLAMP_TO_EDGE;
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, textureWrapMode);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, textureWrapMode);
			}
			
			this._setAnisotropicLevel(gl.TEXTURE_CUBE_MAP, texture);
		} 
		else {
			this._bindTextureDirectly(gl.TEXTURE_2D, internalTexture.data);
			
			if (internalTexture._cachedWrapU != texture.wrapU) {
				internalTexture._cachedWrapU = texture.wrapU;
				
				switch (texture.wrapU) {
					case Texture.WRAP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT);
						
				}
			}
			
			if (internalTexture._cachedWrapV != texture.wrapV) {
				internalTexture._cachedWrapV = texture.wrapV;
				switch (texture.wrapV) {
					case Texture.WRAP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
						
				}
			}
			
			this._setAnisotropicLevel(gl.TEXTURE_2D, texture);
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
		
		gl.uniform1iv(uniform, this._textureUnits);
		
		for (index in 0...textures.length) {
			this._setTexture(channel + index, textures[index]);
		}
	}

	public function _setAnisotropicLevel(key:Int, texture:BaseTexture) {
		var internalTexture = texture.getInternalTexture();
		
		if (internalTexture == null) {
			return;
		}
		
		var anisotropicFilterExtension = this._caps.textureAnisotropicFilterExtension;		
		var value = texture.anisotropicFilteringLevel;
		
		if (internalTexture.samplingMode == Texture.NEAREST_SAMPLINGMODE) {
			value = 1;
		}
		
		if (anisotropicFilterExtension != null && texture._cachedAnisotropicFilteringLevel != value) {
			gl.texParameterf(key, anisotropicFilterExtension.TEXTURE_MAX_ANISOTROPY_EXT, Math.min(texture.anisotropicFilteringLevel, this._caps.maxAnisotropy));
			texture._cachedAnisotropicFilteringLevel = value;
		}
	}

	inline public function readPixels(x:Int, y:Int, width:Int, height:Int):UInt8Array {
		var data = new UInt8Array(height * width * 4);
		gl.readPixels(x, y, width, height, gl.RGBA, gl.UNSIGNED_BYTE, data);
		
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
	
	public function unbindAllAttributes() {
		if (this._mustWipeVertexAttributes) {
			this._mustWipeVertexAttributes = false;
			
			for (i in 0...this._caps.maxVertexAttribs) {
				gl.disableVertexAttribArray(i);
				this._vertexAttribArraysEnabled[i] = false;
				this._currentBufferPointers[i].active = false;
			}
			return;
		}
		
		for (i in 0...this._vertexAttribArraysEnabled.length) {
			if (i >= this._caps.maxVertexAttribs || !this._vertexAttribArraysEnabled[i]) {
				continue;
			}
			
			gl.disableVertexAttribArray(i);
			this._vertexAttribArraysEnabled[i] = false;
			this._currentBufferPointers[i].active = false;
		}
	}
	
	public function releaseEffects() {
		for (name in this._compiledEffects.keys()) {
			gl.deleteProgram(this._compiledEffects[name]._program);
		}
		
		this._compiledEffects = new Map();
	}

	// Dispose
	public function dispose() {		
		this.stopRenderLoop();
		
		// Empty texture
		if (this._emptyTexture != null) {
			this._releaseTexture(this._emptyTexture);
			this._emptyTexture = null;
		}
		if (this._emptyCubeTexture != null) {
			this._releaseTexture(this._emptyCubeTexture);
			this._emptyCubeTexture = null;
		}
		
		// Rescale PP
        if (this._rescalePostProcess != null) {
            this._rescalePostProcess.dispose();
        }
		
		// Release scenes
		while (this.scenes.length > 0) {
			this.scenes[0].dispose();
			this.scenes[0] = null;
			this.scenes.shift();
		}
		
		// Release audio engine
		#if (js || purejs)
		// VK TODO:
		//if (Engine.audioEngine) {
			//Engine.audioEngine.dispose();
		//}
		#end
		
		// Release effects
		this.releaseEffects();
		
		// Unbind
		this.unbindAllAttributes();
		
		if (this._dummyFramebuffer != null) {
            gl.deleteFramebuffer(this._dummyFramebuffer);
        }
		
		// Remove from Instances
		var index = Engine.Instances.indexOf(this);
		
		if (index >= 0) {
			Engine.Instances.splice(index, 1);
		}
		
		//this._workingCanvas = null;
        //this._workingContext = null;
        this._currentBufferPointers = null;
        this._renderingCanvas = null;
        this._currentProgram = null;
		
        this.onResizeObservable.clear();
        //this.onCanvasBlurObservable.clear();
		
        Effect.ResetCache();
	}
	
	public function _readTexturePixels(texture:WebGLTexture, width:Int, height:Int, faceIndex:Int = -1):ArrayBufferView {
		if (this._dummyFramebuffer == null) {
			this._dummyFramebuffer = gl.createFramebuffer();
		}
		gl.bindFramebuffer(gl.FRAMEBUFFER, this._dummyFramebuffer);
		
		if (faceIndex > -1) {
			gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture.data, 0);           
		} 
		else {
			gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture.data, 0);
		}
		
		var readType:Int = this._getWebGLTextureType(texture.type);
		var buffer:ArrayBufferView = null;
		
        if (this._getWebGLTextureType(texture.type) == gl.UNSIGNED_BYTE) {
			buffer = new UInt8Array(Std.int(4 * width * height));
			readType = gl.UNSIGNED_BYTE;
		}
		else {
            buffer = new Float32Array(Std.int(4 * width * height));
			readType = gl.FLOAT;
        }
		
		gl.readPixels(0, 0, width, height, gl.RGBA, readType, buffer);		
		gl.bindFramebuffer(gl.FRAMEBUFFER, this._currentFramebuffer);
		
		return buffer;
	}
	
	private function _canRenderToFloatFramebuffer():Bool {
		if (this._webGLVersion > 1) {
			return this._caps.colorBufferFloat;
		}
		return this._canRenderToFramebuffer(Engine.TEXTURETYPE_FLOAT);
	}

	private function _canRenderToHalfFloatFramebuffer():Bool {
		if (this._webGLVersion > 1) {
			return this._caps.colorBufferFloat;
		}
		return this._canRenderToFramebuffer(Engine.TEXTURETYPE_HALF_FLOAT);
	}

	// Thank you : http://stackoverflow.com/questions/28827511/webgl-ios-render-to-floating-point-texture
	private function _canRenderToFramebuffer(type:Int):Bool {
		//clear existing errors
		while (gl.getError() != gl.NO_ERROR) { }
		
		var successful = true;
		
		var texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(type), 1, 1, 0, gl.RGBA, this._getWebGLTextureType(type), null);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

		var fb = gl.createFramebuffer();
		gl.bindFramebuffer(gl.FRAMEBUFFER, fb);
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
		var status = gl.checkFramebufferStatus(gl.FRAMEBUFFER);

		successful = successful && (status == gl.FRAMEBUFFER_COMPLETE);
		successful = successful && (gl.getError() == gl.NO_ERROR);

		//try render by clearing frame buffer's color buffer
		if (successful) {
			gl.clear(gl.COLOR_BUFFER_BIT);
			successful = successful && (gl.getError() == gl.NO_ERROR);
		}

		//try reading from frame to ensure render occurs (just creating the FBO is not sufficient to determine if rendering is supported)
		if (successful) {
			//in practice it's sufficient to just read from the backbuffer rather than handle potentially issues reading from the texture
			gl.bindFramebuffer(gl.FRAMEBUFFER, null);
			var readFormat = gl.RGBA;
			var readType = gl.UNSIGNED_BYTE;
			var buffer = new UInt8Array(4);
			gl.readPixels(0, 0, 1, 1, readFormat, readType, buffer);
			successful = successful && (gl.getError() == gl.NO_ERROR);
		}

		//clean up
		gl.deleteTexture(texture);
		gl.deleteFramebuffer(fb);
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);

		//clear accumulated errors
		while (!successful && (gl.getError() != gl.NO_ERROR)) { }

		return successful;
	}

	public function _getWebGLTextureType(type:Int):Int {
		if (type == Engine.TEXTURETYPE_FLOAT) {
			return gl.FLOAT;
		}
		else if (type == Engine.TEXTURETYPE_HALF_FLOAT) {
			// Add Half Float Constant.
			return Engine.HALF_FLOAT_OES;
		}
		
		return gl.UNSIGNED_BYTE;
	}

	private function _getRGBABufferInternalSizedFormat(type:Int):Int {
		if (this._webGLVersion == 1) {
			return gl.RGBA;
		}
		
		if (type == Engine.TEXTURETYPE_FLOAT) {
			return gl.RGBA32F; // Engine.RGBA32F;
		}
		else if (type == Engine.TEXTURETYPE_HALF_FLOAT) {
			return gl.RGBA16F; // Engine.RGBA16F;
		}
		
		return gl.RGBA;
	}
	
}
