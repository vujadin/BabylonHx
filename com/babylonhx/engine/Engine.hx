package com.babylonhx.engine;

import com.babylonhx.events.PointerEvent;
import com.babylonhx.materials.EffectCreationOptions;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.UniformBuffer;
import com.babylonhx.materials.textures.InternalTexture;
import com.babylonhx.materials.textures.RenderTargetCreationOptions;
import com.babylonhx.math.Scalar;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.states._AlphaState;
import com.babylonhx.states._DepthCullingState;
import com.babylonhx.cameras.Camera;
import lime.graphics.opengl.GLTransformFeedback;
//import com.babylonhx.materials.textures.WebGLTexture;
import com.babylonhx.materials.textures.VideoTexture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.IncludesShadersStore;
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
import com.babylonhx.tools.dds.DDSTools;
import com.babylonhx.utils.Image;
import lime.graphics.opengl.GLQuery;

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
	public var postProcesses:Array<PostProcess> = [];
	
	// Observables

	/**
	 * Observable event triggered each time the rendering canvas is resized
	 */
	public var onResizeObservable:Observable<Engine> = new Observable<Engine>();

	/**
	 * Observable event triggered each time the canvas lost focus
	 */
	public var onCanvasBlurObservable:Observable<Engine> = new Observable<Engine>();
	
	/**
	 * Observable event triggered before each texture is initialized
	 */
	public var onBeforeTextureInitObservable:Observable<Texture> = new Observable<Texture>();
	
	
	//WebVR 

	//The new WebVR uses promises.
	//this promise resolves with the current devices available.
	public var vrDisplaysPromise:Dynamic;

	private var _vrDisplay:Dynamic;
	private var _vrDisplayEnabled:Bool;
	private var _oldSize:Size;
	private var _oldHardwareScaleFactor:Float;
	private var _vrExclusivePointerMode:Bool = false;

	public var isInVRExclusivePointerMode(get, never):Bool;
	inline private function get_isInVRExclusivePointerMode():Bool {
		return this._vrExclusivePointerMode;
	}
	
	// Uniform buffers list
	public var disableUniformBuffers:Bool = false;
	public var _uniformBuffers:Array<UniformBuffer> = [];
	public var supportsUniformBuffers(get, never):Bool;
	inline private function get_supportsUniformBuffers():Bool {
        return this.webGLVersion > 1 && !this.disableUniformBuffers;
    }
	
	/**
	 * Observable raised when the engine begins a new frame
	 */
	public var onBeginFrameObservable:Observable<Engine> = new Observable<Engine>();

	/**
	 * Observable raised when the engine ends the current frame
	 */
	public var onEndFrameObservable:Observable<Engine> = new Observable<Engine>();

	/**
	 * Observable raised when the engine is about to compile a shader
	 */
	public var onBeforeShaderCompilationObservable:Observable<Engine> = new Observable<Engine>();

	/**
	 * Observable raised when the engine has jsut compiled a shader
	 */
	public var onAfterShaderCompilationObservable:Observable<Engine> = new Observable<Engine>();
	
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
	private var _colorWrite:Bool = true;
	
	private var _drawCalls:PerfCounter = new PerfCounter();
	public var _textureCollisions:PerfCounter = new PerfCounter();
	
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
	
	// Lost context
	public var onContextLostObservable:Observable<Engine> = new Observable<Engine>();
    public var onContextRestoredObservable:Observable<Engine> = new Observable<Engine>();
	private var _onContextLost:Dynamic->Void;
	private var _onContextRestored:Dynamic->Void;
	private var _contextWasLost:Bool = false;
	private var _doNotHandleContextLost:Bool = false;
	
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
	private var _internalTexturesCache:Array<InternalTexture> = [];
	private var _activeChannel:Int = -1;
	public var _boundTexturesCache:Map<Int, InternalTexture> = new Map();
	private var _boundTexturesStack:Array<InternalTexture> = [];
	private var _currentEffect:Effect;
	private var _currentProgram:GLProgram;
	private var _compiledEffects:Map<String, Effect> = new Map<String, Effect>();
	private var _vertexAttribArraysEnabled:Array<Bool> = [];
	private var _cachedViewport:Viewport;
	private var _cachedVertexArrayObject:GLVertexArrayObject = null;
	private var _cachedVertexBuffers:Dynamic; // WebGLBuffer | Map<String, VertexBuffer>;
	private var _cachedIndexBuffer:WebGLBuffer;
	private var _cachedEffectForVertexBuffers:Effect;
	private var _currentRenderTarget:InternalTexture;
	private var _uintIndicesCurrentlySet:Bool = true;
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

	private var _emptyTexture:InternalTexture;
	private var _emptyTexture3D:InternalTexture;
	private var _emptyCubeTexture:InternalTexture;
	
	private var _frameHandler:Int;
	
	private var _nextFreeTextureSlots:Array<Int> = [];

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
	
	public var currentViewport(get, never):Viewport;
	inline private function get_currentViewport():Viewport {
        return this._cachedViewport;
    }

	// Empty texture
	public var emptyTexture(get, never):InternalTexture;
	private function get_emptyTexture():InternalTexture {
		if (this._emptyTexture == null) {
			this._emptyTexture = this.createRawTexture(new UInt8Array(4), 1, 1, Engine.TEXTUREFORMAT_RGBA, false, false, Texture.NEAREST_SAMPLINGMODE);
		}
		
		return this._emptyTexture;
	}
	
	public var emptyTexture3D(get, never):InternalTexture;
	private function get_emptyTexture3D():InternalTexture {
		if (this._emptyTexture3D == null) {
			this._emptyTexture3D = this.createRawTexture3D(new UInt8Array(4), 1, 1, 1, Engine.TEXTUREFORMAT_RGBA, false, false, Texture.NEAREST_SAMPLINGMODE);
		}
		
		return this._emptyTexture3D; 
	}
	
	public var emptyCubeTexture(get, never):InternalTexture;
	private function get_emptyCubeTexture():InternalTexture {
		if (this._emptyCubeTexture == null) {
			var faceData = new UInt8Array(4);
			var cubeData = [faceData, faceData, faceData, faceData, faceData, faceData];
			this._emptyCubeTexture = this.createRawCubeTexture(cast cubeData, 1, Engine.TEXTUREFORMAT_RGBA, Engine.TEXTURETYPE_UNSIGNED_INT, false, false, Texture.NEAREST_SAMPLINGMODE);
		}
		
		return this._emptyCubeTexture;
	}
	
	function GetExtensionName(lookFor:String):String {
		for (ext in _glExtensions) {
			if (ext.indexOf(lookFor) != -1) {
				//trace(ext, lookFor);
				return ext;
			}
		}
		return '';
	}
	
	// quick and dirty solution to handle mouse/keyboard 
	public var mouseDown:Array<PointerEvent->Void> = [];
	public var mouseUp:Array<PointerEvent->Void> = [];
	public var mouseMove:Array<PointerEvent->Void> = [];
	public var mouseWheel:Array<Dynamic> = [];
	public var touchDown:Array<PointerEvent->Void> = [];
	public var touchUp:Array<PointerEvent->Void> = [];
	public var touchMove:Array<PointerEvent->Void> = [];
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
		
		this._webGLVersion = #if !js 1.0 #else _gl.version #end ;
		
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
		this._caps.maxCombinedTexturesImageUnits = gl.getParameter(gl.MAX_COMBINED_TEXTURE_IMAGE_UNITS);
		this._caps.maxTextureSize = gl.getParameter(gl.MAX_TEXTURE_SIZE);
		this._caps.maxCubemapTextureSize = gl.getParameter(gl.MAX_CUBE_MAP_TEXTURE_SIZE);
		this._caps.maxRenderTextureSize = gl.getParameter(gl.MAX_RENDERBUFFER_SIZE);
		this._caps.maxVertexAttribs = gl.getParameter(gl.MAX_VERTEX_ATTRIBS);
		this._caps.maxVaryingVectors = gl.getParameter(gl.MAX_VARYING_VECTORS);
        this._caps.maxFragmentUniformVectors = gl.getParameter(gl.MAX_FRAGMENT_UNIFORM_VECTORS);
        this._caps.maxVertexUniformVectors = gl.getParameter(gl.MAX_VERTEX_UNIFORM_VECTORS);
		
		// Infos
		_glVersion = this.webGLVersion + "";
		_glVendor = gl.getParameter(gl.VENDOR);
		_glRenderer = gl.getParameter(gl.RENDERER);
		_glExtensions = gl.getSupportedExtensions();
		
		/*for (ext in glExtensions) {
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
		this._caps.etc2  = gl.getExtension('WEBGL_compressed_texture_etc');// || gl.getExtension('WEBKIT_WEBGL_compressed_texture_etc'  ) ||
						   //gl.getExtension('WEBGL_compressed_texture_es3_0'); // also a requirement of OpenGL ES 3
		
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
		
		// Depth Texture
        if (this._webGLVersion > 1) {
            this._caps.depthTextureExtension = true;
        } 
		else {
            var depthTextureExtension = gl.getExtension('WEBGL_depth_texture');
			
            if (depthTextureExtension != null) {
                this._caps.depthTextureExtension = true;
            }
        }
		
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
		this._caps.maxRenderTextureSize = gl.getParameter(gl.MAX_RENDERBUFFER_SIZE);// 16384;
		this._caps.maxCubemapTextureSize = gl.getParameter(gl.MAX_CUBE_MAP_TEXTURE_SIZE);// 16384;
		this._caps.maxTextureSize = gl.getParameter(gl.MAX_TEXTURE_SIZE);// 16384;
		this._caps.uintIndices = true;
		
		if (this._caps.standardDerivatives == false) {
			this._caps.standardDerivatives = true;
		}
		if ( #if js this._caps.textureFloat == null || #end this._caps.textureFloat == false) {
			this._caps.textureFloat = gl.getExtension(GetExtensionName("texture_float"));
			
			#if cpp
			if (this._caps.textureFloat == false) {
				this._caps.textureFloat = GetExtensionName("texture_float") != '';
			}
			#end
		}
		if ( #if js this._caps.textureFloatLinearFiltering == null || #end this._caps.textureFloatLinearFiltering == false) {
			this._caps.textureFloatLinearFiltering = gl.getExtension(GetExtensionName("texture_float_linear"));
			#if cpp
			if (this._caps.textureFloatLinearFiltering == false) {
				this._caps.textureFloatLinearFiltering = GetExtensionName("texture_float_linear") != '';
			}
			#end
		}
		if ( #if js this._caps.textureFloatRender == null || #end this._caps.textureFloatRender == false) {
			this._caps.textureFloatRender = this._caps.textureFloat && this._canRenderToFloatFramebuffer();
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
				#if cpp
				this._caps.textureLODExt = "GL_" + GetExtensionName("shader_texture_lod");
				this._caps.textureCubeLodFnName = "textureCubeLod";
				
				for (key in ShadersStore.Shaders.keys()) {
					var shader = ShadersStore.Shaders[key];
					shader = StringTools.replace(shader, "textureCubeLodEXT", "textureCubeLod");
					ShadersStore.Shaders[key] = shader;
					
					shader = ShadersStore.Shaders[key];
					shader = StringTools.replace(shader, "GL_EXT_shader_texture_lod", "GL_ARB_shader_texture_lod");
					ShadersStore.Shaders[key] = shader;
				}
				
				for (key in IncludesShadersStore.Shaders.keys()) {
					var shader = IncludesShadersStore.Shaders[key];
					shader = StringTools.replace(shader, "textureCubeLodEXT", "textureCubeLod");
					IncludesShadersStore.Shaders[key] = shader;
					
					shader = IncludesShadersStore.Shaders[key];
					shader = StringTools.replace(shader, "GL_EXT_shader_texture_lod", "GL_ARB_shader_texture_lod");
					IncludesShadersStore.Shaders[key] = shader;
				}
				#end
			}
		}
		
		if (this._caps.depthTextureExtension == false) {
			this._caps.depthTextureExtension = gl.getExtension(GetExtensionName("depth_texture"));
			#if cpp
			this._caps.depthTextureExtension = GetExtensionName("depth_texture") != '';
			#end
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
		
		// Texture maps
        for (slot in 0...this._caps.maxCombinedTexturesImageUnits) {
            this._nextFreeTextureSlots.push(slot);
        }
		
		// Fullscreen
		this.isFullscreen = false;
		
		// Pointer lock
		this.isPointerLock = false;	
		
		this._boundTexturesCache = new Map();// new Vector<GLTexture>(this._maxTextureChannels);
		
		// Prepare buffer pointers
        for (i in 0...this._caps.maxVertexAttribs) {
            this._currentBufferPointers[i] = new BufferPointer();
        }
		
		for (entry in Reflect.fields(this._caps)) {
			trace(entry + ' , ' + Reflect.field(this._caps, entry));
		}
		
		var msg:String = "BabylonHx - Cross-Platform 3D Engine | " + Date.now().getFullYear() + " | www.babylonhx.com";
		msg +=  " | GL version: " + gl.getParameter(gl.VERSION) + " | GL vendor: " + _glVendor + " | GL renderer: " + _glVendor; 
		trace(msg);
	}
	
	private function _rebuildInternalTextures() {
		var currentState = this._internalTexturesCache.copy(); // Do a copy because the rebuild will add proxies
        for (internalTexture in currentState) {
            internalTexture._rebuild();
        }
    }

	private function _rebuildEffects() {
		for (key in this._compiledEffects.keys()) {
			var effect = this._compiledEffects[key];
			
			@:privateAccess effect._prepareEffect();
		}
		
		Effect.ResetCache();
	}

	private function _rebuildBuffers() {
		// Index / Vertex
		for (scene in this.scenes) {
			scene.resetCachedMaterial();
			scene._rebuildGeometries();
			scene._rebuildTextures();
		}
		
		// Uniforms
		for (uniformBuffer in this._uniformBuffers) {
			uniformBuffer._rebuild();
		}
	}
	
	public static function compileShader(gl:Dynamic, source:String, type:String, defines:String = null, shaderVersion:String):GLShader {
		return compileRawShader(gl, shaderVersion + (defines != null ? defines + "\n" : "") + source, type);
	}
	
	public static function compileRawShader(gl:Dynamic, source:String, type:String):GLShader {
        var shader:GLShader = gl.createShader(type == "vertex" ? gl.VERTEX_SHADER : gl.FRAGMENT_SHADER);
		
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
		
        if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0) {
            var log = gl.getShaderInfoLog(shader);
            if (log != null) {
                throw log;
            }
        }
		
        if (shader == null) {
            throw "Something went wrong while compiling the shader.";
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
		return _glExtensions;
	}
	
	/**
	 * Returns true if the stencil buffer has been enabled through the creation option of the context.
	 */
	public var isStencilEnable(get, never):Bool;
	private function get_isStencilEnable():Bool {
		return this._isStencilEnable;
	}
	
	public function resetTextureCache() {
		for (key in this._boundTexturesCache.keys()) {
			var boundTexture = this._boundTexturesCache[key];
			if (boundTexture != null) {
				this._removeDesignatedSlot(boundTexture);
            }
            this._boundTexturesCache[key] = null;
		}
		this._nextFreeTextureSlots = [];
        for (slot in 0...this._caps.maxCombinedTexturesImageUnits) {
            this._nextFreeTextureSlots.push(slot);
        }
        this._activeChannel = -1;
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
		if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget.width;
		}
		
		return this.width;
	}

	public function getRenderHeight(useScreen:Bool = false):Int {
		if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget.height;
		}
		
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

	public function getLoadedTexturesCache():Array<InternalTexture> {
		return this._internalTexturesCache;
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
	
	public function setRasterizerState(value:Bool) {
		if (value) {
			gl.disable(gl.RASTERIZER_DISCARD);
		} 
		else {
			gl.enable(gl.RASTERIZER_DISCARD);
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

	public function clear(color:Color4, backBuffer:Bool, depth:Bool, stencil:Bool = false) {
		this.applyStates();
		
		var mode:Int = 0;
		if (backBuffer && color != null) {
			gl.clearColor(color.r, color.g, color.b, color.a);
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
		// We're not resizing the size of the canvas while in VR mode & presenting
		if (!(this._vrDisplay != null && this._vrDisplay.isPresenting)) {			
			this.setSize(Std.int(width / this._hardwareScalingLevel), Std.int(height / this._hardwareScalingLevel));
		}		
	}
	
	/**
	 * force a specific size of the canvas
	 * @param {number} width - the new canvas' width
	 * @param {number} height - the new canvas' height
	 */
	public function setSize(width:Int, height:Int) {
		/*if (this._renderingCanvas.width == width && this._renderingCanvas.height == height) {
			return;
		}
		
		this._renderingCanvas.width = width;
		this._renderingCanvas.height = height;*/
		
		for (index in 0...this.scenes.length) {
			var scene = this.scenes[index];
			
			for (camIndex in 0...scene.cameras.length) {
				var cam = scene.cameras[camIndex];
				
				cam._currentRenderId = 0;
			}
		}
		
		if (this.onResizeObservable.hasObservers()) {
			this.onResizeObservable.notifyObservers(this);
		}
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
	

	public function bindFramebuffer(texture:InternalTexture, faceIndex:Int = 0, ?requiredWidth:Int, ?requiredHeight:Int, forceFullscreenViewport:Bool = false) {
		if (this._currentRenderTarget != null) {
			this.unBindFramebuffer(this._currentRenderTarget);
		}
		this._currentRenderTarget = texture;		
		this.bindUnboundFramebuffer(texture._MSAAFramebuffer != null ? texture._MSAAFramebuffer : texture._framebuffer);
		
		if (texture.isCube) {
			gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture._webGLTexture, 0);
		}
		
		if (this._cachedViewport != null && !forceFullscreenViewport) {
			// VK TODO: inspect why renderWidth and renderHeight are null when shadows are rendered
			//this.setViewport(this._cachedViewport, requiredWidth, requiredHeight);
			this.setViewport(this._cachedViewport, requiredWidth != null ? requiredWidth : texture.width, requiredHeight != null ? requiredHeight : texture.height); 
		}
		else {
			gl.viewport(0, 0, requiredWidth != null ? requiredWidth : texture.width, requiredHeight != null ? requiredHeight : texture.height);
		}		
		
		this.wipeCaches();
	}
	
	inline private function bindUnboundFramebuffer(framebuffer:GLFramebuffer) {
		if (this._currentFramebuffer != framebuffer) {
			gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
			this._currentFramebuffer = framebuffer;
		}
	}

	inline public function unBindFramebuffer(texture:InternalTexture, disableGenerateMipMaps:Bool = false, ?onBeforeUnbind:Void->Void) {
		this._currentRenderTarget = null;
		
		// If MSAA, we need to bitblt back to main texture
		if (texture._MSAAFramebuffer != null) {
			gl.bindFramebuffer(gl.READ_FRAMEBUFFER, texture._MSAAFramebuffer);
			gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, texture._framebuffer);
			gl.blitFramebuffer(0, 0, texture.width, texture.height,
				0, 0, texture.width, texture.height,
				gl.COLOR_BUFFER_BIT, gl.NEAREST);
		}
		
		if (texture.generateMipMaps && !disableGenerateMipMaps && !texture.isCube) {
			this._bindTextureDirectly(gl.TEXTURE_2D, texture, true);
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
	
	public function unBindMultiColorAttachmentFramebuffer(textures:Array<InternalTexture>, disableGenerateMipMaps:Bool = false, ?onBeforeUnbind:Void->Void) {
		this._currentRenderTarget = null;
		
		// If MSAA, we need to bitblt back to main texture
		if (textures[0]._MSAAFramebuffer != null) {
			gl.bindFramebuffer(gl.READ_FRAMEBUFFER, textures[0]._MSAAFramebuffer);
			gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, textures[0]._framebuffer);
			
			var attachments = textures[0]._attachments;
			if (attachments == null) {
				attachments = [];// new Array(textures.length);
				textures[0]._attachments = attachments;
			}
			
			for (i in 0...textures.length) {
				var texture = textures[i];
				
				for (j in 0...attachments.length) {
					attachments[j] = gl.NONE;
				}
				
				attachments[i] = gl.COLOR_ATTACHMENT0 + i;// [this.webGLVersion > 1 ? gl.COLOR_ATTACHMENT + i : gl.COLOR_ATTACHMENT + i + "_WEBGL"];
				gl.readBuffer(attachments[i]);
				gl.drawBuffers(attachments);
				gl.blitFramebuffer(0, 0, texture.width, texture.height,
					0, 0, texture.width, texture.height,
					gl.COLOR_BUFFER_BIT, gl.NEAREST);
			}
			for (i in 0...attachments.length) {
				attachments[i] = gl.COLOR_ATTACHMENT0 + i;// [this.webGLVersion > 1 ? "COLOR_ATTACHMENT" + i : "COLOR_ATTACHMENT" + i + "_WEBGL"];
			}
			gl.drawBuffers(attachments);
		}
		
		for (i in 0...textures.length) {
			var texture = textures[i];
			if (texture.generateMipMaps && !disableGenerateMipMaps && !texture.isCube) {
				this._bindTextureDirectly(gl.TEXTURE_2D, texture);
				gl.generateMipmap(gl.TEXTURE_2D);
				this._bindTextureDirectly(gl.TEXTURE_2D, null);
			}
		}
		
		if (onBeforeUnbind != null) {
			if (textures[0]._MSAAFramebuffer != null) {
				// Bind the correct framebuffer
				this.bindUnboundFramebuffer(textures[0]._framebuffer);
			}
			onBeforeUnbind();
		}
		
		this.bindUnboundFramebuffer(null);
	}

	public function generateMipMapsForCubemap(texture:InternalTexture) {
		if (texture.generateMipMaps) {
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
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
		
		if (vbo == null) {
			throw "Unable to create dynamic vertex buffer";
		}
		
		var ret = new WebGLBuffer(vbo);
		this.bindArrayBuffer(ret);
		
		gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);		
		this._resetVertexBufferBinding();
		ret.references = 1;		
		return ret;
	}
	
	inline public function createDynamicVertexBuffer(vertices:Float32Array):WebGLBuffer {
		var vbo = gl.createBuffer();
		
		if (vbo == null) {
			throw "Unable to create dynamic vertex buffer";
		}
		
		var ret = new WebGLBuffer(vbo);		
		this.bindArrayBuffer(ret);		
		
		gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.DYNAMIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}
	
	public function updateDynamicIndexBuffer(indexBuffer:WebGLBuffer, indices:UInt32Array, offset:Int = 0) {
		// Force cache update
		this._currentBoundBuffer[gl.ELEMENT_ARRAY_BUFFER] = null;
        this.bindIndexBuffer(indexBuffer);
		
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.DYNAMIC_DRAW);
        
        this._resetIndexBufferBinding();
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

	inline public function createIndexBuffer(indices:UInt32Array, updatable:Bool = false):WebGLBuffer {
		var vbo = gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindIndexBuffer(ret);
		
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, updatable ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
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
			this._currentBoundBuffer[target] = buffer;
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
				if (buffer != null) {
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

	public function bindVertexArrayObject(vertexArrayObject:GLVertexArrayObject, ?indexBuffer:WebGLBuffer) {
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
		this.drawElementsType(useTriangles ? Material.TriangleFillMode : Material.WireFrameFillMode, indexStart, indexCount, instancesCount);
	}

	public function drawPointClouds(verticesStart:Int, verticesCount:Int, instancesCount:Int = 0) {
		this.drawArraysType(Material.PointFillMode, verticesStart, verticesCount, instancesCount);
	}
	
	public function drawUnIndexed(useTriangles:Bool, verticesStart:Int, verticesCount:Int, instancesCount:Int = 0) {
		this.drawArraysType(useTriangles ? Material.TriangleFillMode : Material.WireFrameFillMode, verticesStart, verticesCount, instancesCount);
	}
	
	public function drawElementsType(fillMode:Int, indexStart:Int, indexCount:Int, instancesCount:Int = 0) {
		// Apply states
		this.applyStates();
		
		this._drawCalls.addCount(1, false);
		// Render
		var drawMode = this.DrawMode(fillMode);
		var indexFormat = this._uintIndicesCurrentlySet ? gl.UNSIGNED_INT : gl.UNSIGNED_SHORT;
		var mult = this._uintIndicesCurrentlySet ? 4 : 2;
		if (instancesCount > 0) {
			gl.drawElementsInstanced(drawMode, indexCount, indexFormat, indexStart * mult, instancesCount);
		} 
		else {
			gl.drawElements(drawMode, indexCount, indexFormat, indexStart * mult);
		}
	}

	public function drawArraysType(fillMode:Int, verticesStart:Int, verticesCount:Int, instancesCount:Int) {
		// Apply states
		this.applyStates();
		this._drawCalls.addCount(1, false);
		
		var drawMode = this.DrawMode(fillMode);
		if (instancesCount > 0) {
			gl.drawArraysInstanced(drawMode, verticesStart, verticesCount, instancesCount);
		} 
		else {
			gl.drawArrays(drawMode, verticesStart, verticesCount);
		}
	}

	private function DrawMode(fillMode:Int):Int {
		switch (fillMode) {
			// Triangle views
			case Material.TriangleFillMode:
				return gl.TRIANGLES;
				
			case Material.PointFillMode:
				return gl.POINTS;
				
			case Material.WireFrameFillMode:
				return gl.LINES;
				
			// Draw modes
			case Material.PointListDrawMode:
				return gl.POINTS;
				
			case Material.LineListDrawMode:
				return gl.LINES;
				
			case Material.LineLoopDrawMode:
				return gl.LINE_LOOP;
				
			case Material.LineStripDrawMode:
				return gl.LINE_STRIP;
				
			case Material.TriangleStripDrawMode:
				return gl.TRIANGLE_STRIP;
				
			case Material.TriangleFanDrawMode:
				return gl.TRIANGLE_FAN;
				
			default:
				return gl.TRIANGLES;
		}
	}

	// Shaders
	public function _releaseEffect(effect:Effect) {
		if (this._compiledEffects.exists(effect._key)) {
			this._compiledEffects.remove(effect._key);
			
			this._deleteProgram(effect.getProgram());
		}
	}
	
	inline public function _deleteProgram(program:GLProgram) {
		if (program != null) {
			gl.deleteProgram(program);
		}
	}

	/**
	 * @param baseName The base name of the effect (The name of file without .fragment.fx or .vertex.fx)
	 * @param samplers An array of string used to represent textures
	 */
	public function createEffect(baseName:Dynamic, attributesNamesOrOptions:Dynamic, uniformsNamesOrEngine:Dynamic, ?samplers:Array<String>, ?defines:String, ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void, ?indexParameters:Dynamic):Effect {
		var vertex = baseName.vertexElement != null ? baseName.vertexElement : (baseName.vertex != null ? baseName.vertex : baseName);
		var fragment = baseName.fragmentElement != null ? baseName.fragmentElement : (baseName.fragment != null ? baseName.fragment : baseName);
		
		var name = vertex + "+" + fragment + "@" + (defines != null ? defines : attributesNamesOrOptions.defines);
		if (this._compiledEffects.exists(name)) {
			var compiledEffect:Effect = this._compiledEffects[name];
			if (onCompiled != null && compiledEffect.isReady()) {
				onCompiled(compiledEffect);
			}
			return compiledEffect;
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
	
	public function createRawShaderProgram(vertexCode:String, fragmentCode:String, transformFeedbackVaryings:Array<String> = null):GLProgram {
		var vertexShader = compileRawShader(gl, vertexCode, "vertex");
		var fragmentShader = compileRawShader(gl, fragmentCode, "fragment");
		
		return this._createShaderProgram(vertexShader, fragmentShader, transformFeedbackVaryings);
	}

	public function createShaderProgram(vertexCode:String, fragmentCode:String, defines:String, transformFeedbackVaryings:Array<String> = null):GLProgram {
		this.onBeforeShaderCompilationObservable.notifyObservers(this);
		
		var shaderVersion = (this._webGLVersion > 1) ? "#version 300 es\n" : "";
		var vertexShader = compileShader(gl, vertexCode, "vertex", defines, shaderVersion);
		var fragmentShader = compileShader(gl, fragmentCode, "fragment", defines, shaderVersion);
		
		var program = this._createShaderProgram(vertexShader, fragmentShader, transformFeedbackVaryings);
		
		this.onAfterShaderCompilationObservable.notifyObservers(this);
		
		return program;
	}
	
	private function _createShaderProgram(vertexShader:GLShader, fragmentShader:GLShader, transformFeedbackVaryings:Array<String> = null):GLProgram {
		var shaderProgram = gl.createProgram();
		
		if (shaderProgram == null) {
			throw ("Unable to create program");
		}
		
		gl.attachShader(shaderProgram, vertexShader);
		gl.attachShader(shaderProgram, fragmentShader);
		
		if (this.webGLVersion > 1 && transformFeedbackVaryings != null) {
			var transformFeedback = this.createTransformFeedback();
			
			this.bindTransformFeedback(transformFeedback);
			this.setTranformFeedbackVaryings(shaderProgram, transformFeedbackVaryings);
			//shaderProgram.transformFeedback = transformFeedback;
		}
		
		gl.linkProgram(shaderProgram);
		
		if (this.webGLVersion > 1 && transformFeedbackVaryings != null) {
			this.bindTransformFeedback(null);
		}
		
		var linked = gl.getProgramParameter(shaderProgram, gl.LINK_STATUS);
		
		if ( #if (js && html5) linked == null || #end linked == 0) {
			gl.validateProgram(shaderProgram);
			var error:String = gl.getProgramInfoLog(shaderProgram);
			if (error != null || error != "") {
				throw error;
			}
		}
		
		gl.deleteShader(vertexShader);
		gl.deleteShader(fragmentShader);
		
		return shaderProgram;
	}

	inline public function getUniforms(shaderProgram:GLProgram, uniformsNames:Array<String>):Array<GLUniformLocation> {
		var results:Array<GLUniformLocation> = [];
		
		for (uniformName in uniformsNames) {
			results.push(gl.getUniformLocation(shaderProgram, uniformName));
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
		if (effect == null) {
            return;
        }
		
		// Use program
		this.bindSamplers(effect);
		
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
	
	inline public function setInt(uniform:GLUniformLocation, value:Int) {
		if (uniform != #if (js && html5) null #else 0 #end) {
			gl.uniform1i(uniform, value);
		}
	}

	public function setFloat(uniform:GLUniformLocation, value:Float) {
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
		if (this._depthCullingState.cull != culling || force) {
			this._depthCullingState.cull = culling;
		}
		
		// Cull face
		var cullFace = this.cullBackFaces ? gl.BACK : gl.FRONT;
		if (this._depthCullingState.cullFace != cullFace || force) {
			this._depthCullingState.cullFace = cullFace;
		}
		
		// Z offset
		this.setZOffset(zOffset);
		
		// Front face
		var frontFace:Int = reverseSide ? gl.CW : gl.CCW;
		if (this._depthCullingState.frontFace != frontFace || force) {
			this._depthCullingState.frontFace = frontFace;
		}
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
		this._colorWrite = enable;
	}
	
	inline public function getColorWrite():Bool {
        return this._colorWrite;
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
		if (this.preventCacheWipeBetweenFrames && !bruteForce) {
			return;
		}
		
		this._currentEffect = null;
		
		// 6/8/2017: deltakosh: Should not be required anymore. 
		// This message is then mostly for the future myself which will scream out loud when seeing that actually it was required :)
		if (bruteForce) {
			this.resetTextureCache();
			this._currentProgram = null;
			
			this._stencilState.reset();
			this._depthCullingState.reset();
			this.setDepthFunctionToLessOrEqual();
			this._alphaState.reset();
		}
		
		this._resetVertexBufferBinding();
		this._cachedIndexBuffer = null;
		this._cachedEffectForVertexBuffers = null;
		this._unbindVertexArrayObject();
		this.bindIndexBuffer(null);
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
		this._textureFormatInUse = null;
		return null;
	}
	
	public function _createTexture():GLTexture {
		var texture = gl.createTexture();
		
		if (texture == null) {
			throw ("Unable to create texture!");
		}
		
		return texture;
	}
	
	public function createTextureFromImage(uid:String, img:Image, noMipmap:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):InternalTexture {	
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_URL);
		
		scene._addPendingData(texture);
		texture.url = "from_image:" + uid;
		texture.generateMipMaps = noMipmap;
		texture.samplingMode = samplingMode;
		this._internalTexturesCache.push(texture);
		
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
	public function createTexture(urlArg:String, noMipmap:Bool, invertY:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, onLoad:Void->Void = null, onError:Void->Void = null, buffer:Dynamic = null, ?fallBack:InternalTexture, format:Int = -1):InternalTexture {
		var url = StringTools.trim(urlArg); // assign a new string, so that the original is still available in case of fallback
		var fromData = url.substr(0, 5) == "data:";
		var fromBlob = url.substr(0, 5) == "blob:";
		var isBase64 = fromData && url.indexOf("base64") != -1;
		
		var texture = fallBack != null ? fallBack : new InternalTexture(this, InternalTexture.DATASOURCE_URL);
		
		// establish the file extension, if possible
		var lastDot = url.lastIndexOf('.');
		var extension = (lastDot > 0) ? url.substring(lastDot).toLowerCase() : "";
		var isDDS = this.getCaps().s3tc && (extension == ".dds");
		var isTGA = (extension == ".tga");
		
		// determine if a ktx file should be substituted
		/*var isKTX = false;
		if (this._textureFormatInUse && !isBase64 && !fallBack) {
			url = url.substring(0, lastDot) + this._textureFormatInUse;
			isKTX = true;
		}*/
		
		if (scene != null) {
			scene._addPendingData(texture);
		}
		texture.url = url;
		texture.generateMipMaps = !noMipmap;
		texture.samplingMode = samplingMode;
		texture.invertY = invertY;
		
		if (!this._doNotHandleContextLost) {
			// Keep a link to the buffer only if we plan to handle context lost
			texture._buffer = buffer;
		}
		
		if (onLoad != null) {
			texture.onLoadedObservable.add(cast onLoad);
		}
		if (fallBack == null) {
			this._internalTexturesCache.push(texture);
		}
		
		var onerror = function(e:Dynamic) {
			if (scene != null) {
				scene._removePendingData(texture);
			}
			
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
					var source = new InternalTexture(this, InternalTexture.DATASOURCE_TEMP);
					this._bindTextureDirectly(gl.TEXTURE_2D, source, true);
					gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, img.width, img.height, 0, internalFormat, gl.UNSIGNED_BYTE, img.data);
					
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE); 
					
					this._rescaleTexture(source, texture, scene, internalFormat, function() {
						// BHX start *****************
						//this._releaseTexture(source);		// can't do this in BHX
						gl.deleteTexture(source._webGLTexture);
						this.unbindAllTextures();
						source = null;
						// BHX end *******************
						
						this._bindTextureDirectly(gl.TEXTURE_2D, texture, true);
						
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
			
			if (!fromData || isBase64)
				if (Std.is(buffer, Image)) {
					onload(buffer);
				} 
				else {
					Tools.LoadImage(url, onload, onerror, scene != null ? scene.database : null);
				}
			else if (Std.is(buffer, Array) || Std.is(buffer, String)) {
				Tools.LoadImage(buffer, onload, onerror);
			}
			else {
				onload(buffer);
			}
		}
		
		return texture;
	}
	
	private function _rescaleTexture(source:InternalTexture, destination:InternalTexture, scene:Scene, internalFormat:Int, onComplete:Void->Void) {
		var rtt = this.createRenderTargetTexture({
				width: destination.width,
				height: destination.height,
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
			
			var hostingScene = scene;
			
			if (hostingScene == null) {
				hostingScene = this.scenes[this.scenes.length - 1];
			}
			
			scene.postProcessManager.directRender([this._rescalePostProcess], rtt, true);
			
			this._bindTextureDirectly(gl.TEXTURE_2D, destination, true);
			gl.copyTexImage2D(gl.TEXTURE_2D, 0, internalFormat, 0, 0, destination.width, destination.height, 0);
			
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
	
	public function updateTextureSize(texture:InternalTexture, width:Int, height:Int) {
		texture.width = width;
		texture.height = height;
		texture._size = width * height;
		texture.baseWidth = width;
		texture.baseHeight = height;
	}
	
	private function setCubeMapTextureParams(loadMipmap:Bool) {
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, loadMipmap ? gl.LINEAR_MIPMAP_LINEAR : gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		
		//this.resetTextureCache();
	}
	
	public function updateRawCubeTexture(texture:InternalTexture, data:Array<ArrayBufferView>, format:Int, type:Int, invertY:Bool, compression:String = null, level:Int = 0) {
		texture._bufferViewArray = data;
        texture.format = format;
        texture.type = type;
        texture.invertY = invertY;
        texture._compression = compression;
		
		var textureType = this._getWebGLTextureType(type);
		var internalFormat = this._getInternalFormat(format);
		var internalSizedFomat = this._getRGBABufferInternalSizedFormat(type);
		
		var needConversion = false;
		if (internalFormat == gl.RGB) {
			internalFormat = gl.RGBA;
			needConversion = true;
		}
		
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
		//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY == null ? 1 : (invertY ? 1 : 0));
		
		if (texture.width % 4 != 0) {
			gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
		}
		
		// Data are known to be in +X +Y +Z -X -Y -Z
		for (index in 0...6) {
			var faceData = data[index];
			
			if (compression != null) {
				gl.compressedTexImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_X + index, level, Reflect.getProperty(this.getCaps().s3tc, compression), texture.width, texture.height, 0, faceData);
			} 
			else {
				if (needConversion) {
					faceData = this._convertRGBtoRGBATextureData(faceData, texture.width, texture.height, type);
				}
				gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_X + index, level, internalSizedFomat, texture.width, texture.height, 0, internalFormat, textureType, faceData);
			}
		}
		
		var isPot = !this.needPOTTextures || (com.babylonhx.math.Tools.IsExponentOfTwo(texture.width) && com.babylonhx.math.Tools.IsExponentOfTwo(texture.height));
		if (isPot && texture.generateMipMaps && level == 0) {
			gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
		}
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		
		//this.resetTextureCache();
		texture.isReady = true;
	}
	
	public function createRawCubeTexture(data:Array<ArrayBufferView>, size:Int, format:Int, type:Int, generateMipMaps:Bool, invertY:Bool, samplingMode:Int, compression:String = null):InternalTexture {
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_CUBERAW);
		
		texture.isCube = true;
		texture.generateMipMaps = generateMipMaps;
		texture.format = format;
		texture.type = type;
		if (!this._doNotHandleContextLost) {
            texture._bufferViewArray = data;
        }
		
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
		
		texture.width = width;
		texture.height = height;
		
		// Double check on POT to generate Mips.
		var isPot = !this.needPOTTextures || (com.babylonhx.math.Tools.IsExponentOfTwo(texture.width) && com.babylonhx.math.Tools.IsExponentOfTwo(texture.height));
		if (!isPot) {
			generateMipMaps = false;
		}
		
		// Upload data if needed. The texture won't be ready until then.
		if (data != null) {
			this.updateRawCubeTexture(texture, data, format, type, invertY, compression);
		}
		
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
		
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
		
		this._internalTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createRawCubeTextureFromUrl(url:String, scene:Scene, size:Int, format:Int, type:Int, noMipmap:Bool = false, callback:ArrayBuffer->Array<ArrayBufferView>, mipmmapGenerator:Array<ArrayBufferView>->Array<Array<ArrayBufferView>>, onLoad:Void->Void = null, onError:Void->Void = null, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, invertY:Bool = false):InternalTexture {
		var texture = this.createRawCubeTexture(null, size, format, type, !noMipmap, invertY, samplingMode);
		scene._addPendingData(texture);
		texture.url = url;
		this._internalTexturesCache.push(texture);
		
		var onerror:Void->Void = function() {
			scene._removePendingData(texture);
			if (onError != null) {
				onError();
			}
		};
		
		var internalCallback = function(data:Dynamic) {
			var width = texture.width;
			var height = texture.height;
			var faceDataArrays = callback(data);
			
			var facesIndex = [
				gl.TEXTURE_CUBE_MAP_POSITIVE_X, gl.TEXTURE_CUBE_MAP_POSITIVE_Y, gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
				gl.TEXTURE_CUBE_MAP_NEGATIVE_X, gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
			];
			
			if (mipmmapGenerator != null) {
				var textureType = this._getWebGLTextureType(type);
				var internalFormat = this._getInternalFormat(format);
				var internalSizedFomat = this._getRGBABufferInternalSizedFormat(type);
				
				var needConversion = false;
				if (internalFormat == gl.RGB) {
					internalFormat = gl.RGBA;
					needConversion = true;
				}
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
				//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 0);
				
				var mipData = mipmmapGenerator(faceDataArrays);
				for (level in 0...mipData.length) {
					var mipSize = width >> level;
					
					for (faceIndex in 0...6) {
						var mipFaceData = mipData[level][faceIndex];
						if (needConversion) {
							mipFaceData = this._convertRGBtoRGBATextureData(mipFaceData, mipSize, mipSize, type);
						}
						gl.texImage2D(faceIndex, level, internalSizedFomat, mipSize, mipSize, 0, internalFormat, textureType, mipFaceData);
					}
				}
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
			}
			else {
				texture.generateMipMaps = !noMipmap;
				this.updateRawCubeTexture(texture, faceDataArrays, format, type, invertY);
			}
			
			texture.isReady = true;
			//this.resetTextureCache();
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
	
	public function updateRawTexture3D(texture:InternalTexture, data:ArrayBufferView, format:Int, invertY:Bool, compression:String = "") {
		var internalFormat = this._getInternalFormat(format);
		this._bindTextureDirectly(gl.TEXTURE_3D, texture, true);
		
		if (!this._doNotHandleContextLost) {
			texture._bufferView = data;
			texture.format = format;
			texture.invertY = invertY;
			texture._compression = compression;
		}
		
		if (texture.width % 4 != 0) {
			gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
		}
		
		if (compression != "" && data != null) {
			gl.compressedTexImage3D(gl.TEXTURE_3D, 0, this.getCaps().s3tc.compression, texture.width, texture.height, texture.depth, 0, data);
		} 
		else {
			gl.texImage3D(gl.TEXTURE_3D, 0, internalFormat, texture.width, texture.height, texture.depth, 0, internalFormat, gl.UNSIGNED_BYTE, data);
		}
		
		if (texture.generateMipMaps) {
			gl.generateMipmap(gl.TEXTURE_3D);
		}
		this._bindTextureDirectly(gl.TEXTURE_3D, null);
		//this.resetTextureCache();
		texture.isReady = true;
	}

	public function createRawTexture3D(data:ArrayBufferView, width:Int, height:Int, depth:Int, format:Int, generateMipMaps:Bool, invertY:Bool, samplingMode:Int, compression:String = ""):InternalTexture {
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_RAW3D);
		texture.baseWidth = width;
		texture.baseHeight = height;
		texture.baseDepth = depth;
		texture.width = width;
		texture.height = height;
		texture.depth = depth;
		texture.format = format;
		texture.generateMipMaps = generateMipMaps;
		texture.samplingMode = samplingMode;
		texture.is3D = true;
		
		if (!this._doNotHandleContextLost) {
			texture._bufferView = data;
		}
		
		this.updateRawTexture3D(texture, data, format, invertY, compression);
		this._bindTextureDirectly(gl.TEXTURE_3D, texture, true);
		
		// Filters
		var filters = getSamplingParameters(gl, samplingMode, generateMipMaps);
		
		gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_MAG_FILTER, filters.mag);
		gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_MIN_FILTER, filters.min);
		
		if (generateMipMaps) {
			gl.generateMipmap(gl.TEXTURE_3D);
		}
		
		this._bindTextureDirectly(gl.TEXTURE_3D, null);
		
		this._internalTexturesCache.push(texture);
		
		return texture;
	}
	
	private function _prepareWebGLTextureContinuation(texture:InternalTexture, scene:Scene, noMipmap:Bool, isCompressed:Bool, samplingMode:Int) {
		var filters = getSamplingParameters(gl, samplingMode, !noMipmap);
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
		
		if (!noMipmap && !isCompressed) {
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		
		this._bindTextureDirectly(gl.TEXTURE_2D, null);
		
		//this.resetTextureCache();
		if (scene != null) {
			scene._removePendingData(texture);
		}
		
		texture.onLoadedObservable.notifyObservers(texture);
        texture.onLoadedObservable.clear();
	}

	private function _prepareWebGLTexture(texture:InternalTexture, scene:Scene, width:Int, height:Int, invertY:Bool, noMipmap:Bool, isCompressed:Bool, processFunction:Int->Int->Dynamic/*Void->Void*/->Bool, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
		var potWidth = this.needPOTTextures ? MathTools.GetExponentOfTwo(width, this.getCaps().maxTextureSize) : width;
		var potHeight = this.needPOTTextures ? MathTools.GetExponentOfTwo(height, this.getCaps().maxTextureSize) : height;
		
		if (texture._webGLTexture == null) {
			//this.resetTextureCache();
			if (scene != null) {
				scene._removePendingData(texture);
			}
			
			return;
		}
		
		this._bindTextureDirectly(gl.TEXTURE_2D, texture);
		//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY == undefined ? 1 : (invertY ? 1 : 0));
		
		texture.baseWidth = width;
		texture.baseHeight = height;
		texture.width = potWidth;
		texture.height = potHeight;
		texture.isReady = true;
		
		if (processFunction(potWidth, potHeight, function() {
			this._prepareWebGLTextureContinuation(texture, scene, noMipmap, isCompressed, samplingMode);
		})) {
			// Returning as texture needs extra async steps
			return;
		}
		
		this._prepareWebGLTextureContinuation(texture, scene, noMipmap, isCompressed, samplingMode);
	}
	
	inline public function updateRawTexture(texture:InternalTexture, data:ArrayBufferView, format:Int, invertY:Bool = false, compression:String = "", type:Int = Engine.TEXTURETYPE_UNSIGNED_INT) {
		if (texture == null) {
			return;
		}
		
		var internalFormat = this._getInternalFormat(format);
		var internalSizedFomat = this._getRGBABufferInternalSizedFormat(type);
        var textureType = this._getWebGLTextureType(type);
		this._bindTextureDirectly(gl.TEXTURE_2D, texture, true);
		//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);
		
		if (!this._doNotHandleContextLost) {
            texture._bufferView = data;
            texture.format = format;
			texture.type = type;
            texture.invertY = invertY;
            texture._compression = compression;
        }
		
		if (texture.width % 4 != 0) {
			gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
		}
		
		if (compression != "" && data != null) {
			gl.compressedTexImage2D(gl.TEXTURE_2D, 0, Reflect.getProperty(this.getCaps().s3tc, compression), texture.width, texture.height, 0, data);
		}
		else {
			gl.texImage2D(gl.TEXTURE_2D, 0, internalSizedFomat, texture.width, texture.height, 0, internalFormat, textureType, data);
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
	
	public function createRawTexture(data:ArrayBufferView, width:Int, height:Int, format:Int, generateMipMaps:Bool, invertY:Bool, samplingMode:Int, compression:String = "", type:Int = Engine.TEXTURETYPE_UNSIGNED_INT):InternalTexture {		
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_RAW);
		texture.baseWidth = width;
		texture.baseHeight = height;
		texture.width = width;
		texture.height = height;
		texture.format = format;
		texture.generateMipMaps = generateMipMaps;
		texture.samplingMode = samplingMode;
		texture.invertY = invertY;
		texture._compression = compression;
		texture.type = type;
		
		if (!this._doNotHandleContextLost) {
			texture._bufferView = data;
		}
		
		this.updateRawTexture(texture, data, format, invertY, compression, type);
		this._bindTextureDirectly(gl.TEXTURE_2D, texture, true);
		
		this._internalTexturesCache.push(texture);
		
		return texture;
	}

	public function createDynamicTexture(width:Int, height:Int, generateMipMaps:Bool, samplingMode:Int):InternalTexture {
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_DYNAMIC);		
		texture.baseWidth = width;
		texture.baseHeight = height;
		
		if (generateMipMaps) {
			width = this.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(width, this._caps.maxTextureSize) : width;
			height = this.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(height, this._caps.maxTextureSize) : height;
		}
		
		//this.resetTextureCache();		
		texture.width = width;
		texture.height = height;
		texture.isReady = false;
		texture.generateMipMaps = generateMipMaps;
		texture.samplingMode = samplingMode;
		
		this.updateTextureSamplingMode(samplingMode, texture);
		
		this._internalTexturesCache.push(texture);
		
		return texture;
	}
	
	inline public function updateTextureSamplingMode(samplingMode:Int, texture:InternalTexture) {
		var filters = getSamplingParameters(gl, samplingMode, texture.generateMipMaps);
		
		if (texture.isCube) {
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
			
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, filters.min);
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		} 
		else if (texture.is3D) {
			this._bindTextureDirectly(gl.TEXTURE_3D, texture, true);
			
			gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_MIN_FILTER, filters.min);
			this._bindTextureDirectly(gl.TEXTURE_3D, null);
		} 
		else {
			this._bindTextureDirectly(gl.TEXTURE_2D, texture, true);
			
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
		}
		
		texture.samplingMode = samplingMode;
	}
	
	inline public function updateDynamicTexture(texture:InternalTexture, canvas:Image, invertY:Bool, premulAlpha:Bool = false, format:Int = -1) {
		if (texture == null) {
			return;
		}
		
		this._bindTextureDirectly(gl.TEXTURE_2D, texture, true);
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
		this._activeChannel = -1;
		//this.resetTextureCache();
		texture.isReady = true;
	}

	public function updateVideoTexture(texture:InternalTexture, video:Dynamic, invertY:Bool) {
		#if (html5 || js || web || purejs)
		
		/*if (texture == null || texture._isDisabled) {
			return;
		}
		
		this._bindTextureDirectly(gl.TEXTURE_2D, texture.data, true);
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
			//resetTextureCache();
			texture.isReady = true;
		}
		catch(e:Dynamic) {
			// Something unexpected
			// Let's disable the texture
			texture._isDisabled = true;
		}*/
		
		#end
	}

	public function createRenderTargetTexture(size:Dynamic, options:Dynamic):InternalTexture {
		var fullOptions:RenderTargetCreationOptions = new RenderTargetCreationOptions();
		
		if (options != null && !Std.is(options, Bool)) {
			fullOptions.generateMipMaps = options.generateMipMaps;
			fullOptions.generateDepthBuffer = options.generateDepthBuffer == null ? true : options.generateDepthBuffer;
			fullOptions.generateStencilBuffer = fullOptions.generateDepthBuffer && options.generateStencilBuffer;
			fullOptions.type = options.type == null ? Engine.TEXTURETYPE_UNSIGNED_INT : options.type;
			fullOptions.samplingMode = options.samplingMode == null ? Texture.TRILINEAR_SAMPLINGMODE : options.samplingMode;
		} 
		else {
			fullOptions.generateMipMaps = cast options;
			fullOptions.generateDepthBuffer = true;
			fullOptions.generateStencilBuffer = false;
			fullOptions.type = Engine.TEXTURETYPE_UNSIGNED_INT;
			fullOptions.samplingMode = Texture.TRILINEAR_SAMPLINGMODE;
		}

		if (fullOptions.type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloatLinearFiltering) {
			// if floating point linear (gl.FLOAT) then force to NEAREST_SAMPLINGMODE
			fullOptions.samplingMode = Texture.NEAREST_SAMPLINGMODE;
		}
		else if (fullOptions.type == Engine.TEXTURETYPE_HALF_FLOAT && !this._caps.textureHalfFloatLinearFiltering) {
			// if floating point linear (HALF_FLOAT) then force to NEAREST_SAMPLINGMODE
			fullOptions.samplingMode = Texture.NEAREST_SAMPLINGMODE;
		}
		
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_RENDERTARGET);
		this._bindTextureDirectly(gl.TEXTURE_2D, texture, true);
		
		var width = size.width != null ? size.width : size;
		var height = size.height != null ? size.height : size;
		
		var filters = getSamplingParameters(gl, fullOptions.samplingMode, fullOptions.generateMipMaps);
		
		if (fullOptions.type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloat) {
			fullOptions.type = Engine.TEXTURETYPE_UNSIGNED_INT;
			Tools.Warn("Float textures are not supported. Render target forced to TEXTURETYPE_UNSIGNED_BYTE type");
		}
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(fullOptions.type), width, height, 0, gl.RGBA, this._getWebGLTextureType(fullOptions.type), null);
		
		// Create the framebuffer
		var framebuffer = gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture._webGLTexture, 0);
		
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(fullOptions.generateStencilBuffer, fullOptions.generateDepthBuffer, width, height);
		
		if (fullOptions.generateMipMaps) {
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		
		// Unbind
		this._bindTextureDirectly(gl.TEXTURE_2D, null);
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		texture._framebuffer = framebuffer;
		texture.baseWidth = width;
		texture.baseHeight = height;
		texture.width = width;
		texture.height = height;
		texture.isReady = true;
		texture.samples = 1;
		texture.generateMipMaps = fullOptions.generateMipMaps;
		texture.samplingMode = fullOptions.samplingMode;
		texture.type = fullOptions.type;
		texture._generateDepthBuffer = fullOptions.generateDepthBuffer;
		texture._generateStencilBuffer = fullOptions.generateStencilBuffer;
		
		//this.resetTextureCache();
		
		this._internalTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createMultipleRenderTarget(size:Dynamic, options:Dynamic):Array<InternalTexture> {
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
		
		var textures:Array<InternalTexture> = [];
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
			
			var texture = new InternalTexture(this, InternalTexture.DATASOURCE_MULTIRENDERTARGET);
			var attachment = gl.COLOR_ATTACHMENT0 + i;// gl["COLOR_ATTACHMENT" + i];
			textures.push(texture);
			attachments.push(attachment);
			
			gl.activeTexture(gl.TEXTURE0 + i);
			gl.bindTexture(gl.TEXTURE_2D, texture._webGLTexture);
			
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filters.mag);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filters.min);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			
			gl.texImage2D(gl.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(type), width, height, 0, gl.RGBA, this._getWebGLTextureType(type), null);
			
			gl.framebufferTexture2D(gl.DRAW_FRAMEBUFFER, attachment, gl.TEXTURE_2D, texture._webGLTexture, 0);
			
			if (generateMipMaps) {
				gl.generateMipmap(gl.TEXTURE_2D);
			}
			
			// Unbind
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
			
			texture._framebuffer = framebuffer;
			texture._depthStencilBuffer = depthStencilBuffer;
			texture.baseWidth = width;
			texture.baseHeight = height;
			texture.width = width;
			texture.height = height;
			texture.isReady = true;
			texture.samples = 1;
			texture.generateMipMaps = generateMipMaps;
			texture.samplingMode = samplingMode;
			texture.type = type;
			texture._generateDepthBuffer = generateDepthBuffer;
			texture._generateStencilBuffer = generateStencilBuffer;
			
			this._internalTexturesCache.push(texture);
		}
		
		if (generateDepthTexture && this._caps.depthTextureExtension) {
			// Depth texture
			var depthTexture = new InternalTexture(this, InternalTexture.DATASOURCE_MULTIRENDERTARGET);
			
			gl.activeTexture(gl.TEXTURE0);
			gl.bindTexture(gl.TEXTURE_2D, depthTexture._webGLTexture);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			gl.texImage2D(
				gl.TEXTURE_2D,
				0,
				this.webGLVersion < 2 ? gl.DEPTH_COMPONENT : gl.DEPTH_COMPONENT16,
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
				depthTexture._webGLTexture,
				0
			);
			
			depthTexture._framebuffer = framebuffer;
			depthTexture.baseWidth = width;
			depthTexture.baseHeight = height;
			depthTexture.width = width;
			depthTexture.height = height;
			depthTexture.isReady = true;
			depthTexture.samples = 1;
			depthTexture.generateMipMaps = generateMipMaps;
			depthTexture.samplingMode = gl.NEAREST;
			depthTexture._generateDepthBuffer = generateDepthBuffer;
			depthTexture._generateStencilBuffer = generateStencilBuffer;
			
			textures.push(depthTexture);
			this._internalTexturesCache.push(depthTexture);
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

	public function updateRenderTargetTextureSampleCount(texture:InternalTexture, samples:Int):Int {
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
		
		if (samples > 1) {
			var framebuffer = gl.createFramebuffer();
			
            if (framebuffer == null) {
                throw "Unable to create multi sampled framebuffer";
            }
			
			texture._MSAAFramebuffer = gl.createFramebuffer();
			this.bindUnboundFramebuffer(texture._MSAAFramebuffer);
			
			var colorRenderbuffer = gl.createRenderbuffer();
			gl.bindRenderbuffer(gl.RENDERBUFFER, colorRenderbuffer);
			gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples, this._getRGBAMultiSampleBufferFormat(texture.type), texture.width, texture.height);
			
			gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, colorRenderbuffer);
			
			texture._MSAARenderBuffer = colorRenderbuffer;
		} 
		else {
			this.bindUnboundFramebuffer(texture._framebuffer);
		}
		
		texture.samples = samples;
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(texture._generateStencilBuffer, texture._generateDepthBuffer, texture.width, texture.height, samples);
		
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		return samples;
	}
	
	public function updateMultipleRenderTargetTextureSampleCount(textures:Array<InternalTexture>, samples:Int):Int {
		if (this.webGLVersion < 2 || textures == null || textures.length == 0) {
			return 1;
		}
		
		if (textures[0].samples == samples) {
			return samples;
		}
		
		samples = cast Math.min(samples, cast gl.getParameter(gl.MAX_SAMPLES));
		
		// Dispose previous render buffers
		if (textures[0]._depthStencilBuffer != null) {
			gl.deleteRenderbuffer(textures[0]._depthStencilBuffer);
			textures[0]._depthStencilBuffer = null;
		}
		
		if (textures[0]._MSAAFramebuffer != null) {
			gl.deleteFramebuffer(textures[0]._MSAAFramebuffer);
			textures[0]._MSAAFramebuffer = null;
		}
		
		for (i in 0...textures.length) {
			if (textures[i]._MSAARenderBuffer != null) {
				gl.deleteRenderbuffer(textures[i]._MSAARenderBuffer);
				textures[i]._MSAARenderBuffer = null;
			}
		}
		
		if (samples > 1) {
			var framebuffer = gl.createFramebuffer();
			
			if (framebuffer == null) {
				throw "Unable to create multi sampled framebuffer";
			}
			
			this.bindUnboundFramebuffer(framebuffer);
			
			var depthStencilBuffer = this._setupFramebufferDepthAttachments(textures[0]._generateStencilBuffer, textures[0]._generateDepthBuffer, textures[0].width, textures[0].height, samples);
			
			var attachments:Array<Int> = [];

			for (i in 0...textures.length) {
				var texture = textures[i];
				var attachment = gl.COLOR_ATTACHMENT0 + i; // [this.webGLVersion > 1 ? "COLOR_ATTACHMENT" + i : "COLOR_ATTACHMENT" + i + "_WEBGL"];
				
				var colorRenderbuffer = gl.createRenderbuffer();
				
				if (colorRenderbuffer == null) {
					throw "Unable to create multi sampled framebuffer";
				}
				
				gl.bindRenderbuffer(gl.RENDERBUFFER, colorRenderbuffer);
				gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples, this._getRGBAMultiSampleBufferFormat(texture.type), texture.width, texture.height);
				
				gl.framebufferRenderbuffer(gl.FRAMEBUFFER, attachment, gl.RENDERBUFFER, colorRenderbuffer);
				
				texture._MSAAFramebuffer = framebuffer;
				texture._MSAARenderBuffer = colorRenderbuffer;
				texture.samples = samples;
				texture._depthStencilBuffer = depthStencilBuffer;
				gl.bindRenderbuffer(gl.RENDERBUFFER, null);
				attachments.push(attachment);
			}
			gl.drawBuffers(attachments);
		} 
		else {
			this.bindUnboundFramebuffer(textures[0]._framebuffer);
		}
		
		this.bindUnboundFramebuffer(null);
		
		return samples;
	}
	
	public function _uploadDataToTexture(target:Int, lod:Int, internalFormat:Int, width:Int, height:Int, format:Int, type:Int, data:ArrayBufferView) {
        gl.texImage2D(target, lod, internalFormat, width, height, 0, format, type, data);
    }

    public function _uploadCompressedDataToTexture(target:Int, lod:Int, internalFormat:Int, width:Int, height:Int, data:ArrayBufferView) {
        gl.compressedTexImage2D(target, lod, internalFormat, width, height, 0, data);
    }
	
	public function createRenderTargetCubeTexture(size:Dynamic, ?options:RenderTargetCreationOptions):InternalTexture {
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_RENDERTARGET);
		
		var generateMipMaps:Bool = true;
		var generateDepthBuffer:Bool = true;
		var generateStencilBuffer:Bool = false;
		
		var samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE;
		if (options != null) {
			generateMipMaps = /*options.generateMipMaps == null ? true : */options.generateMipMaps;					// BHX: default is false
			generateDepthBuffer = /*options.generateDepthBuffer == null ? true : */options.generateDepthBuffer;		// BHX: default is false
			generateStencilBuffer = (options.generateStencilBuffer && generateDepthBuffer) ? true : false;
			
			//if (options.samplingMode != null) {	// BHX: default is Texture.TRILINEAR_SAMPLINGMODE
				samplingMode = options.samplingMode;
			//}
		}
		
		texture.isCube = true;
		texture.generateMipMaps = generateMipMaps;
		texture.samples = 1;
		texture.samplingMode = samplingMode;
		
		var filters = getSamplingParameters(gl, samplingMode, generateMipMaps);
		
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
		
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
			//this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
			gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
		}
		
		// Unbind
		this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
		gl.bindRenderbuffer(gl.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		texture._framebuffer = framebuffer;
		texture.width = size.width;
		texture.height = size.height;
		texture.isReady = true;
		
		//this.resetTextureCache();
		
		this._internalTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createPrefilteredCubeTexture(rootUrl:String, scene:Scene, scale:Float, offset:Float, onLoad:InternalTexture->Void, onError:Void->Void = null, ?format:Int, forcedExtension:String = null):InternalTexture {
		var callback = function(loadData:Dynamic) {
			if (loadData == null) {
				if (onLoad != null) {
					onLoad(null);
				}
				return;
			}
			
			var texture:InternalTexture = cast loadData.texture;
			texture._dataSource = InternalTexture.DATASOURCE_CUBEPREFILTERED;
			texture._lodGenerationScale = scale;
			texture._lodGenerationOffset = offset;
			
			if (this._caps.textureLOD) {
				// Do not add extra process if texture lod is supported.
				if (onLoad != null) {
					onLoad(texture);
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
				
				var minLODIndex = offset; // roughness = 0
				var maxLODIndex = Scalar.Log2(width) * scale + offset; // roughness = 1
				
				var lodIndex = minLODIndex + (maxLODIndex - minLODIndex) * roughness;
				var mipmapIndex = Math.round(Math.min(Math.max(lodIndex, 0), maxLODIndex));
				
				var glTextureFromLod = new InternalTexture(this, InternalTexture.DATASOURCE_TEMP);
				glTextureFromLod.isCube = true;
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, glTextureFromLod, true);
				
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				
				if (loadData.isDDS) {
					var info:DDSInfo = loadData.info;
					var data:Dynamic = loadData.data;
					//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, info.isCompressed ? 1 : 0);
					
					DDSTools.UploadDDSLevels(this, data, info, true, 6, mipmapIndex);
				}
				else {
					Tools.Warn("DDS is the only prefiltered cube map supported so far.");
				}
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
				
				// Wrap in a base texture for easy binding.
				var lodTexture = new BaseTexture(scene);
				lodTexture.isCube = true;
				lodTexture._texture = glTextureFromLod;
				
				glTextureFromLod.isReady = true;
				textures.push(lodTexture);
			}
			
			texture._lodTextureHigh = textures[2];
			texture._lodTextureMid = textures[1];
			texture._lodTextureLow = textures[0];
			
			if (onLoad != null) {
				onLoad(texture);
			}
		};
		
		return this.createCubeTexture(rootUrl, scene, null, false, callback, onError, format, forcedExtension);
	}

	public function createCubeTexture(rootUrl:String, scene:Scene, files:Array<String> = null, noMipmap:Bool = false, onLoad:Dynamic = null, onError:Void->Void = null, ?format:Int, forcedExtension:String = null):InternalTexture {
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_CUBE);
		texture.isCube = true;
		texture.url = rootUrl;
		texture.generateMipMaps = !noMipmap;
		
		if (!this._doNotHandleContextLost) {
			texture._extension = forcedExtension;
			texture._files = files;
		}
		
		var isKTX:Bool = false;
		var isDDS:Bool = false;
		var lastDot:Int = rootUrl.lastIndexOf('.');
		var extension:String = forcedExtension != null ? forcedExtension : (lastDot > -1 ? rootUrl.substring(lastDot).toLowerCase() : "");
		if (this._textureFormatInUse != null) {
			extension = this._textureFormatInUse;
			rootUrl = (lastDot > -1 ? rootUrl.substring(0, lastDot) : rootUrl) + this._textureFormatInUse;
			isKTX = true;
		} 
		else {
			isDDS = (extension == ".dds");
		}
		
		/*var onerror = (request?: XMLHttpRequest, exception?: any) => {
			if (onError && request) {
				onError(request.status + " " + request.statusText, exception);
			}
		}*/
		
		if (isDDS) {
			Tools.LoadFile(rootUrl, function(data:Dynamic) {
				var info = DDSTools.GetDDSInfo(data);
				
				var loadMipmap = (info.isRGB || info.isLuminance || info.mipmapCount > 1) && !noMipmap;
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
				//gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
				
				DDSTools.UploadDDSLevels(this, data, info, loadMipmap, 6);
				
				if (!noMipmap && !info.isFourCC && info.mipmapCount == 1) {
					gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
				}
				
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, loadMipmap ? gl.LINEAR_MIPMAP_LINEAR :gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
				
				this._boundTexturesCache = new Map();
				
				texture.width = info.width;
				texture.height = info.height;
				texture.isReady = true;
				texture.type = info.textureType;
				
				if (onLoad != null) {
					onLoad({ isDDS: true, width: info.width, info: info, data: data, texture: texture });
				}
			}, "dds");
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
				
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, texture, true);
				gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 0);
				
				for (index in 0...faces.length) {
					gl.texImage2D(faces[index], 0, internalFormat, width, height, 0, internalFormat, gl.UNSIGNED_BYTE, imgs[index].data);
				}
				
				if (!noMipmap) {
					gl.generateMipmap(gl.TEXTURE_CUBE_MAP);
				}
				
				this.setCubeMapTextureParams(!noMipmap);
				
				texture.width = width;
				texture.height = height;
				texture.isReady = true;
				if (format != null) {
					texture.format = format;
				}
				
				texture.onLoadedObservable.notifyObservers(texture);
                texture.onLoadedObservable.clear();
				
				if (onLoad != null) {
					onLoad();
				}
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
		
		this._internalTexturesCache.push(texture);
		
		return texture;
	}
	
	private function _convertRGBtoRGBATextureData(rgbData:ArrayBufferView, width:Int, height:Int, textureType:Int):ArrayBufferView {
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
	}
	
	public function _releaseFramebufferObjects(texture:InternalTexture) {
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

	public function _releaseTexture(texture:InternalTexture) {
		this._releaseFramebufferObjects(texture);
		
		gl.deleteTexture(texture._webGLTexture);
		
		// Unbind channels
		this.unbindAllTextures();		
		
		var index = this._internalTexturesCache.indexOf(texture);
		if (index != -1) {
			this._internalTexturesCache.splice(index, 1);
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
	
	private var _boundUniforms:Map<Int, GLUniformLocation> = new Map();

	inline public function bindSamplers(effect:Effect) {
		this.setProgram(effect.getProgram());
		
		var samplers = effect.getSamplers();		
		for (index in 0...samplers.length) {
			var uniform = effect.getUniform(samplers[index]);
			
			if ((uniform != #if (js && html5) null #else 0 #end)) {
                this._boundUniforms[index] = uniform;
            }
		}
		this._currentEffect = null;
	}
	
	private function _activateTextureChannel(channel:Int) {
		if (this._activeChannel != channel && channel > -1) {
			gl.activeTexture(gl.TEXTURE0 + channel);
			this._activeChannel = channel;
		}
	}
	
	private function _moveBoundTextureOnTop(internalTexture:InternalTexture) {
        var index = this._boundTexturesStack.indexOf(internalTexture);
		
        if (index > -1 && index != this._boundTexturesStack.length - 1) {
            this._boundTexturesStack.splice(index, 1);
            this._boundTexturesStack.push(internalTexture);
        }
    }

    private function _removeDesignatedSlot(internalTexture:InternalTexture):Int {
        var currentSlot = internalTexture._designatedSlot;
        internalTexture._designatedSlot = -1;
        var index = this._boundTexturesStack.indexOf(internalTexture);
		
        if (index > -1) {
            this._boundTexturesStack.splice(index, 1);
			if (currentSlot > -1) {
                this._boundTexturesCache[currentSlot] = null;
                this._nextFreeTextureSlots.push(currentSlot);
            }
        }
		
		return currentSlot;
    }

	public function _bindTextureDirectly(target:Int, ?texture:InternalTexture, doNotBindUniformToTextureChannel:Bool = false) {
		var currentTextureBound = this._boundTexturesCache[this._activeChannel];
        var isTextureForRendering = texture != null && texture._initialSlot > -1;
		
        if (currentTextureBound != texture) {
            if (currentTextureBound != null) {
                this._removeDesignatedSlot(currentTextureBound);
            }
			
            gl.bindTexture(target, texture != null ? texture._webGLTexture : null);
			
            if (this._activeChannel >= 0) {
                this._boundTexturesCache[this._activeChannel] = texture;
				
                if (isTextureForRendering) {
					var slotIndex = this._nextFreeTextureSlots.indexOf(this._activeChannel);
					if (slotIndex > -1) {
						this._nextFreeTextureSlots.splice(slotIndex, 1);
					}
                    this._boundTexturesStack.push(texture);
                }
            }
        }
		
        if (isTextureForRendering && this._activeChannel > -1) {
            texture._designatedSlot = this._activeChannel;
            if (!doNotBindUniformToTextureChannel) {
                this._bindSamplerUniformToChannel(texture._initialSlot, this._activeChannel);
            }
        }
	}

	inline public function _bindTexture(channel:Int, texture:InternalTexture) {
		if (channel < 0) {
			return;
		}
		
		if (texture != null) {
            channel = this._getCorrectTextureChannel(channel, texture);
        }
		
        this._activateTextureChannel(channel);
		this._bindTextureDirectly(gl.TEXTURE_2D, texture);
	}

	inline public function setTextureFromPostProcess(channel:Int, postProcess:PostProcess) {
		this._bindTexture(channel, postProcess != null ? postProcess._textures.data[postProcess._currentRenderTextureInd] : null);
	}
	
	public function unbindAllTextures() {
		for (channel in 0...this._caps.maxCombinedTexturesImageUnits) {
			this._activateTextureChannel(channel);
			this._bindTextureDirectly(gl.TEXTURE_2D, null);
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
			if (this.webGLVersion > 1) {
                this._bindTextureDirectly(gl.TEXTURE_3D, null);
            }
		}
	}
	
	public function setTexture(channel:Int, ?uniform:GLUniformLocation, ?texture:BaseTexture) {
		if (channel < 0) {
			return;
		}
		
		if (uniform != null) {
            this._boundUniforms[channel] = uniform;
        }
		
        this._setTexture(channel, texture);
	}

	private function _getCorrectTextureChannel(channel:Int, ?internalTexture:InternalTexture):Int {
        if (internalTexture == null) {
            return -1;
        }
		
		internalTexture._initialSlot = channel;
		
        if (channel != internalTexture._designatedSlot) {
            if (internalTexture._designatedSlot > -1) { // Texture is already assigned to a slot
                return internalTexture._designatedSlot;
            } 
			else {
                // No slot for this texture, let's pick a new one (if we find a free slot)
                if (this._nextFreeTextureSlots.length > 0) {
                    return this._nextFreeTextureSlots[0];
                }
				
                // We need to recycle the oldest bound texture, sorry.
                this._textureCollisions.addCount(1, false);
                return this._removeDesignatedSlot(this._boundTexturesStack[0]);
            }
        }
		
        return channel;
    }

    private function _bindSamplerUniformToChannel(sourceSlot:Int, destination:Int) {
        var uniform = this._boundUniforms[sourceSlot];
        gl.uniform1i(uniform, destination);
    }
	
	private function _setTexture(channel:Int, ?texture:BaseTexture, isPartOfTextureArray:Bool = false):Bool {
		// Not ready?
		if (texture == null) {
			if (this._boundTexturesCache[channel] != null) {
				this._activateTextureChannel(channel);
				this._bindTextureDirectly(gl.TEXTURE_2D, null);
				this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, null);
				if (this.webGLVersion > 1) {
                    this._bindTextureDirectly(gl.TEXTURE_3D, null);
                }
			}
			
			return false;
		}
		
		// Video
		var alreadyActivated = false;
		if (Std.is(texture, VideoTexture)) {
			this._activateTextureChannel(channel);
			alreadyActivated = true;
			cast(texture, VideoTexture).update();
		} 
		else if (texture.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) { // Delay loading
			texture.delayLoad();
			return false;
		}
		
		var internalTexture:InternalTexture = null;
		if (texture.isReady()) {
			internalTexture = texture.getInternalTexture();
		}
		else if (texture.isCube) {
			internalTexture = this.emptyCubeTexture;
		}
		else if (texture.is3D) {
			internalTexture = this.emptyTexture3D;
		}
		else {
			internalTexture = this.emptyTexture;
		}
		
		if (!isPartOfTextureArray) {
            channel = this._getCorrectTextureChannel(channel, internalTexture);
        }
		
		if (this._boundTexturesCache[channel] == internalTexture) {
            this._moveBoundTextureOnTop(internalTexture);
            if (!isPartOfTextureArray) {
                this._bindSamplerUniformToChannel(internalTexture._initialSlot, channel);
            }
			return false;
		}
		
		if (!alreadyActivated) {
            this._activateTextureChannel(channel);
        }
		
		if (internalTexture != null && internalTexture.is3D) {
			this._bindTextureDirectly(gl.TEXTURE_3D, internalTexture, isPartOfTextureArray);
			
			if (internalTexture != null && internalTexture._cachedWrapU != texture.wrapU) {
				internalTexture._cachedWrapU = texture.wrapU;
				
				switch (texture.wrapU) {
					case Texture.WRAP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_S, gl.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT);
						
				}
			}
			
			if (internalTexture != null && internalTexture._cachedWrapV != texture.wrapV) {
				internalTexture._cachedWrapV = texture.wrapV;
				switch (texture.wrapV) {
					case Texture.WRAP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_T, gl.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
						
				}
			}
			
			if (internalTexture != null && internalTexture._cachedWrapR != texture.wrapR) {
				internalTexture._cachedWrapR = texture.wrapR;
				switch (texture.wrapV) {
					case Texture.WRAP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_R, gl.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						gl.texParameteri(gl.TEXTURE_3D, gl.TEXTURE_WRAP_R, gl.MIRRORED_REPEAT);
						
				}
			}
			
			this._setAnisotropicLevel(gl.TEXTURE_3D, texture);
		}
		else if (internalTexture != null && internalTexture.isCube) {
			this._bindTextureDirectly(gl.TEXTURE_CUBE_MAP, internalTexture, isPartOfTextureArray);
			
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
			this._bindTextureDirectly(gl.TEXTURE_2D, internalTexture, isPartOfTextureArray);
			
			if (internalTexture != null && internalTexture._cachedWrapU != texture.wrapU) {
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
			
			if (internalTexture != null && internalTexture._cachedWrapV != texture.wrapV) {
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
		
		return true;
	}
	
	public function setTextureArray(channel:Int, uniform:GLUniformLocation, textures:Array<BaseTexture>) {
		if (channel < 0 || (uniform != #if (js && html5) null #else 0 #end)) {
			return;
		}
		
		if (this._textureUnits == null || this._textureUnits.length != textures.length) {
			this._textureUnits = new Int32Array(textures.length);
		}
		for (i in 0...textures.length) {
			this._textureUnits[i] = this._getCorrectTextureChannel(channel + i, textures[i].getInternalTexture());
		}
		
		gl.uniform1iv(uniform, this._textureUnits);
		
		for (index in 0...textures.length) {
			this._setTexture(this._textureUnits[index], textures[index], true);
		}
	}

	public function _setAnisotropicLevel(key:Int, texture:BaseTexture) {
		var internalTexture = texture.getInternalTexture();
		
		if (internalTexture == null) {
			return;
		}
		
		var anisotropicFilterExtension = this._caps.textureAnisotropicFilterExtension;		
		var value = texture.anisotropicFilteringLevel;
		
		if (internalTexture.samplingMode != Texture.LINEAR_LINEAR_MIPNEAREST
			&& internalTexture.samplingMode != Texture.LINEAR_LINEAR_MIPLINEAR
			&& internalTexture.samplingMode != Texture.LINEAR_LINEAR) {
			value = 1;  // Forcing the anisotropic to 1 because else webgl will force filters to linear
		}
		
		if (anisotropicFilterExtension != null && internalTexture._cachedAnisotropicFilteringLevel != value) {
			gl.texParameterf(key, anisotropicFilterExtension.TEXTURE_MAX_ANISOTROPY_EXT, Math.min(texture.anisotropicFilteringLevel, this._caps.maxAnisotropy));
			internalTexture._cachedAnisotropicFilteringLevel = value;
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
		
		// Release postProcesses
        while (this.postProcesses.length > 0) {
            this.postProcesses[0].dispose();
			this.postProcesses.shift();
        }
		
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
	
	public function _readTexturePixels(texture:InternalTexture, width:Int, height:Int, faceIndex:Int = -1):ArrayBufferView {
		if (this._dummyFramebuffer == null) {
			var dummy = gl.createFramebuffer();
			
			if (dummy == null) {
				throw "Unable to create dummy framebuffer";
			}
			
			this._dummyFramebuffer = dummy;
		}
		gl.bindFramebuffer(gl.FRAMEBUFFER, this._dummyFramebuffer);
		
		if (faceIndex > -1) {
			gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture._webGLTexture, 0);           
		} 
		else {
			gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture._webGLTexture, 0);
		}
		
		var readType:Int = this._getWebGLTextureType(texture.type);
		var buffer:ArrayBufferView = null;
		
        if (readType == gl.UNSIGNED_BYTE) {
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
	
	public function _getRGBAMultiSampleBufferFormat(type:Int):Int {
        if (type == Engine.TEXTURETYPE_FLOAT) {
			return gl.RGBA32F;
        }
        else if (type == Engine.TEXTURETYPE_HALF_FLOAT) {
            return gl.RGBA16F;
        }
		
        return gl.RGBA8;
    }
	
	public inline function createQuery():GLQuery {
		return this.gl.createQuery();
	}
	
	public inline function deleteQuery(query:GLQuery) {
		this.gl.deleteQuery(query);
	}

	public inline function isQueryResultAvailable(query:GLQuery):Bool {
		return cast this.gl.getQueryParameter(query, this.gl.QUERY_RESULT_AVAILABLE);
	}

	public inline function getQueryResult(query:GLQuery):Int {
		return cast this.gl.getQueryParameter(query, this.gl.QUERY_RESULT);
	}

	public inline function beginQuery(algorithmType:Int, query:GLQuery) {
		var glAlgorithm = this.getGlAlgorithmType(algorithmType);
		this.gl.beginQuery(glAlgorithm, query);
	}

	public inline function endQuery(algorithmType:Int) {
		var glAlgorithm = this.getGlAlgorithmType(algorithmType);
		this.gl.endQuery(glAlgorithm);
	}

	private inline function getGlAlgorithmType(algorithmType:Int):Int {
		return algorithmType == AbstractMesh.OCCLUSION_ALGORITHM_TYPE_CONSERVATIVE ? this.gl.ANY_SAMPLES_PASSED_CONSERVATIVE : this.gl.ANY_SAMPLES_PASSED;
	}
	
	// Transform feedback
	public function createTransformFeedback():GLTransformFeedback {
		return gl.createTransformFeedback();
	}

	public function deleteTransformFeedback(value:GLTransformFeedback) {
		gl.deleteTransformFeedback(value);
	}

	public function bindTransformFeedback(value:GLTransformFeedback) {
		gl.bindTransformFeedback(gl.TRANSFORM_FEEDBACK, value);
	}
	
	public function beginTransformFeedback(usePoints:Bool = true) {
        gl.beginTransformFeedback(usePoints ? gl.POINTS : gl.TRIANGLES);
    }
  
    public function endTransformFeedback() {
        gl.endTransformFeedback();
    }
 
    public function setTranformFeedbackVaryings(program:GLProgram, value:Array<String>) {
        gl.transformFeedbackVaryings(program, value, gl.INTERLEAVED_ATTRIBS);
    }
  
    public function bindTransformFeedbackBuffer(value:GLBuffer) {
        gl.bindBufferBase(gl.TRANSFORM_FEEDBACK_BUFFER, 0, value);
    }
	
}
