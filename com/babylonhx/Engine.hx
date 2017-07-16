package com.babylonhx;

import com.babylonhx.materials.EffectCreationOptions;
import com.babylonhx.materials.Material;
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
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.states._StencilState;
import com.babylonhx.tools.PerfCounter;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.WebGLVertexArrayObject;
import com.babylonhx.tools.Observable;
import com.babylonhx.utils.Image;
import lime.utils.UInt16Array;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLShader;
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
using lime.graphics.opengl.GL;
#else
import lime.graphics.opengl.GL in Gl;
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
	#if (js || purejs)
	public var Gl:js.html.webgl.RenderingContext;
	#else
	public var Gl = GL;
	#end
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
	@:allow(com.babylonhx.layer.HighlightLayer)
	private var _stencilState:_StencilState = new _StencilState();
	private var _alphaState:_AlphaState = new _AlphaState();
	private var _alphaMode:Int = Engine.ALPHA_DISABLE;

	// Cache
	private var _loadedTexturesCache:Array<WebGLTexture> = [];
	private var _maxTextureChannels:Int = 16;
	private var _activeTexture:Int = 0;
	public var _activeTexturesCache:Vector<GLTexture>;
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
	private var _uintIndicesCurrentlySet:Bool = false;
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
	
	
	public function new(canvas:Dynamic, antialias:Bool = false, ?options:Dynamic, adaptToDeviceRatio:Bool = false) {		
		this._renderingCanvas = canvas;
		this._canvasClientRect.width = Reflect.getProperty(canvas, "width") != null ? Reflect.getProperty(canvas, "width") : 960;// canvas.width;
		this._canvasClientRect.height = Reflect.getProperty(canvas, "height") != null ? Reflect.getProperty(canvas, "height") : 640;// canvas.height;
		
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
		#if (purejs || js)
			#if lime
			if(!Std.is(this._renderingCanvas, js.html.CanvasElement))
				this._renderingCanvas = Browser.document.getElementsByTagName('canvas')[0];
			#end
			
		Gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("webgl2", options);
		if (Gl == null) {
			Gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("experimental-webgl2", options);
		}
		if (Gl != null) {
			this._webGLVersion = 2;
		}
		else {				
			Gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("webgl", options);
			if (Gl == null) {
				Gl = cast(this._renderingCanvas, js.html.CanvasElement).getContext("experimental-webgl", options);
			}
		}
		#end
		
		this._webGLVersion = GL.version;
		
		#if openfl
		this._workingContext = new OpenGLView();
		this._workingContext.render = this._renderLoop;
		canvas.addChild(this._workingContext);
		#end
		
		width = this._canvasClientRect.width;
		height = this._canvasClientRect.height;		
		
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
		this._caps.maxTexturesImageUnits = Gl.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
		this._caps.maxVertexTextureImageUnits = Gl.getParameter(GL.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
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
		for (ext in this._glExtensions) {
			trace(ext);
		}
		
		Engine.HALF_FLOAT_OES = 0x8D61; // Half floating-point type (16-bit).
        Engine.RGBA16F = 0x881A; // RGBA 16-bit floating-point color-renderable internal sized format.
        Engine.RGBA32F = 0x8814; // RGBA 32-bit floating-point color-renderable internal sized format.
		
		#if cpp
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
		#else
		this._caps.standardDerivatives = this._webGLVersion > 1 || (Gl.getExtension('OES_standard_derivatives') != null);
		
		this._caps.astc = Gl.getExtension('WEBGL_compressed_texture_astc');
		this._caps.s3tc = Gl.getExtension('WEBGL_compressed_texture_s3tc');
		this._caps.pvrtc = Gl.getExtension('WEBGL_compressed_texture_pvrtc');
		this._caps.etc1  = Gl.getExtension('WEBGL_compressed_texture_etc1');
		this._caps.etc2  = Gl.getExtension('WEBGL_compressed_texture_etc');// || this._gl.getExtension('WEBKIT_WEBGL_compressed_texture_etc'  ) ||
						   //this._gl.getExtension('WEBGL_compressed_texture_es3_0'); // also a requirement of OpenGL ES 3
		
		this._caps.textureAnisotropicFilterExtension = Gl.getExtension('EXT_texture_filter_anisotropic');
		this._caps.maxAnisotropy = this._caps.textureAnisotropicFilterExtension ? Gl.getParameter(this._caps.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 0;
		this._caps.uintIndices = this._webGLVersion > 1 || Gl.getExtension('OES_element_index_uint') != null;
		this._caps.fragmentDepthSupported = this._webGLVersion > 1 || Gl.getExtension('EXT_frag_depth') != null;
		this._caps.highPrecisionShaderSupported = true;
		this._caps.drawBuffersExtension = this._webGLVersion > 1 || Gl.getExtension('WEBGL_draw_buffers');
		
		// Checks if some of the format renders first to allow the use of webgl inspector.
		this._caps.colorBufferFloat = this._webGLVersion > 1 && Gl.getExtension('EXT_color_buffer_float');
		
		this._caps.textureFloat = this._webGLVersion > 1 || Gl.getExtension('OES_texture_float');
		this._caps.textureFloatLinearFiltering = this._caps.textureFloat && Gl.getExtension('OES_texture_float_linear');
		this._caps.textureFloatRender = this._caps.textureFloat && this._canRenderToFloatFramebuffer();
		
		this._caps.textureHalfFloat = this._webGLVersion > 1 || Gl.getExtension('OES_texture_half_float');
		this._caps.textureHalfFloatLinearFiltering = this._webGLVersion > 1 || (this._caps.textureHalfFloat && Gl.getExtension('OES_texture_half_float_linear'));
		if (this._webGLVersion > 1) {
			Engine.HALF_FLOAT_OES = 0x140B;
		}
		this._caps.textureHalfFloatRender = this._caps.textureHalfFloat && this._canRenderToHalfFloatFramebuffer();
		
		this._caps.textureLOD = this._webGLVersion > 1 || Gl.getExtension('EXT_shader_texture_lod');
		
		// Vertex array object 
		if (this._webGLVersion > 1) {
			this._caps.vertexArrayObject = true;
		} 
		else {
			var vertexArrayObjectExtension = Gl.getExtension('OES_vertex_array_object');
			
			if (vertexArrayObjectExtension != null) {
				this._caps.vertexArrayObject = true;
				untyped Gl.createVertexArray = vertexArrayObjectExtension.createVertexArrayOES;
				untyped Gl.bindVertexArray = vertexArrayObjectExtension.bindVertexArrayOES;
				untyped Gl.deleteVertexArray = vertexArrayObjectExtension.deleteVertexArrayOES;
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
			var instanceExtension = Gl.getExtension('ANGLE_instanced_arrays');
			
			if (instanceExtension != null) {
				this._caps.instancedArrays = true;
				untyped Gl.drawArraysInstanced = instanceExtension.drawArraysInstancedANGLE;
				untyped Gl.drawElementsInstanced = instanceExtension.drawElementsInstancedANGLE;
				untyped Gl.vertexAttribDivisor = instanceExtension.vertexAttribDivisorANGLE;
			} 
			else {
				this._caps.instancedArrays = false;
			}
		}
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
	
	public static function compileShader(#if (js || purejs) Gl:js.html.webgl.RenderingContext, #end source:String, type:String, defines:String, shaderVersion:String):GLShader {
		var shader:GLShader = Gl.createShader(type == "vertex" ? GL.VERTEX_SHADER : GL.FRAGMENT_SHADER);
		
		Gl.shaderSource(shader, shaderVersion + (defines != null ? defines + "\n" : "") + source);
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
			texture.onLoadedCallbacks.splice(0, texture.onLoadedCallbacks.length);
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
	
	public function setDitheringState(value:Bool) {
		if (value) {
			Gl.enable(GL.DITHER);
		} 
		else {
			Gl.disable(GL.DITHER);
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

	inline public function clear(color:Dynamic, backBuffer:Bool, depth:Bool, stencil:Bool = false) {
		this.applyStates();
		
		var mode = 0;
		if (backBuffer && color != null) {
			if (color.getClassName() == 'Color4') {
				Gl.clearColor(color.r, color.g, color.b, color.a);
			} 
			else {
				Gl.clearColor(color.r, color.g, color.b, 1.0);
			}
			mode |= GL.COLOR_BUFFER_BIT;
		}
		
		if (depth) {
			#if cpp
			GL.clearDepthf(1.0);
			#else
			Gl.clearDepth(1.0);
			#end
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
	

	public function bindFramebuffer(texture:WebGLTexture, faceIndex:Int = 0, ?requiredWidth:Int, ?requiredHeight:Int) {
		if (this._currentRenderTarget != null) {
			this.unBindFramebuffer(this._currentRenderTarget);
		}
		this._currentRenderTarget = texture;		
		this.bindUnboundFramebuffer(texture._MSAAFramebuffer != null ? texture._MSAAFramebuffer : texture._framebuffer);
		
		if (texture.isCube) {
			Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture.data, 0);
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

	inline public function unBindFramebuffer(texture:WebGLTexture, disableGenerateMipMaps:Bool = false, ?onBeforeUnbind:Void->Void) {
		this._currentRenderTarget = null;
		
		// If MSAA, we need to bitblt back to main texture
		if (texture._MSAAFramebuffer != null) {
			Gl.bindFramebuffer(GL.READ_FRAMEBUFFER, texture._MSAAFramebuffer);
			Gl.bindFramebuffer(GL.DRAW_FRAMEBUFFER, texture._framebuffer);
			untyped Gl.blitFramebuffer(0, 0, texture._width, texture._height,
				0, 0, texture._width, texture._height,
				GL.COLOR_BUFFER_BIT, GL.NEAREST);
		}
		
		if (texture.generateMipMaps && !disableGenerateMipMaps && !texture.isCube) {
			this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
			Gl.generateMipmap(GL.TEXTURE_2D);
			this._bindTextureDirectly(GL.TEXTURE_2D, null);
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
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
			Gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
		}
	}

	inline public function flushFramebuffer() {
		Gl.flush();
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
	public function createUniformBuffer(elements:Array<Float>):WebGLBuffer {
		var ubo = Gl.createBuffer();
		var ret = new WebGLBuffer(ubo);
		this.bindUniformBuffer(ret);
		
		Gl.bufferData(GL.UNIFORM_BUFFER, #if cpp elements.length, #end new Float32Array(elements), GL.STATIC_DRAW);
		
		this.bindUniformBuffer(null);
		
		ret.references = 1;
		return ret;
	}
	
	public function createUniformBuffer2(elements:Float32Array):WebGLBuffer {
		var ubo = Gl.createBuffer();
		var ret = new WebGLBuffer(ubo);
		this.bindUniformBuffer(ret);
		
		Gl.bufferData(GL.UNIFORM_BUFFER, #if cpp elements.length, #end elements, GL.STATIC_DRAW);
		
		this.bindUniformBuffer(null);
		
		ret.references = 1;
		return ret;
	}

	public function createDynamicUniformBuffer(elements:Array<Float>):WebGLBuffer {
		var ubo = Gl.createBuffer();
		var ret = new WebGLBuffer(ubo);
		this.bindUniformBuffer(ret);
		
		Gl.bufferData(GL.UNIFORM_BUFFER, #if cpp elements.length, #end new Float32Array(elements), GL.DYNAMIC_DRAW);
		
		this.bindUniformBuffer(null);
		
		ret.references = 1;
		return ret;
	}
	
	public function createDynamicUniformBuffer2(elements:Float32Array):WebGLBuffer {
		var ubo = Gl.createBuffer();
		var ret = new WebGLBuffer(ubo);
		this.bindUniformBuffer(ret);
		
		Gl.bufferData(GL.UNIFORM_BUFFER, #if cpp elements.length, #end elements, GL.DYNAMIC_DRAW);
		
		this.bindUniformBuffer(null);
		
		ret.references = 1;
		return ret;
	}

	public function updateUniformBuffer(uniformBuffer:WebGLBuffer, elements:Array<Float>, offset:Int = 0, count:Int = -1) {
		this.bindUniformBuffer(uniformBuffer);
		
		if (count == -1) {
			Gl.bufferSubData(GL.UNIFORM_BUFFER, offset, #if cpp elements.length, #end new Float32Array(elements));
		} 
		else {
			Gl.bufferSubData(GL.UNIFORM_BUFFER, 0, #if cpp count, #end new Float32Array(elements).subarray(offset, offset + count));
		}
		
		this.bindUniformBuffer(null);
	}
	
	public function updateUniformBuffer2(uniformBuffer:WebGLBuffer, elements:Float32Array, offset:Int = 0, count:Int = -1) {
		this.bindUniformBuffer(uniformBuffer);
		
		if (count == -1) {
			Gl.bufferSubData(GL.UNIFORM_BUFFER, offset, #if cpp elements.length, #end elements);
		} 
		else {
			Gl.bufferSubData(GL.UNIFORM_BUFFER, 0, #if cpp count, #end elements.subarray(offset, offset + count));
		}
		
		this.bindUniformBuffer(null);
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
		
		Gl.bufferData(GL.ARRAY_BUFFER, #if cpp vertices.length, #end new Float32Array(vertices), GL.STATIC_DRAW);
		
		this._resetVertexBufferBinding();
		ret.references = 1;		
		return ret;
	}
	
	inline public function createVertexBuffer2(vertices:Float32Array):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);
		this.bindArrayBuffer(ret);
		
		Gl.bufferData(GL.ARRAY_BUFFER, #if cpp vertices.length, #end vertices, GL.STATIC_DRAW);
		
		this._resetVertexBufferBinding();
		ret.references = 1;		
		return ret;
	}

	inline public function createDynamicVertexBuffer(vertices:Array<Float>):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindArrayBuffer(ret);		
		
		Gl.bufferData(GL.ARRAY_BUFFER, #if cpp vertices.length, #end new Float32Array(vertices), GL.DYNAMIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}
	
	inline public function createDynamicVertexBuffer2(vertices:Float32Array):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindArrayBuffer(ret);		
		
		Gl.bufferData(GL.ARRAY_BUFFER, #if cpp vertices.length, #end vertices, GL.DYNAMIC_DRAW);
		this._resetVertexBufferBinding();
		ret.references = 1;
		
		return ret;
	}

	// VK TODO: check why this is called every frame in Instances2 demo
	inline public function updateDynamicVertexBuffer(vertexBuffer:WebGLBuffer, vertices:Array<Float>, offset:Int = 0, count:Int = -1) {
		this.bindArrayBuffer(vertexBuffer);
		
		if (count == -1) {
			Gl.bufferSubData(GL.ARRAY_BUFFER, offset, #if cpp vertices.length, #end new Float32Array(vertices));
		}
		else {
			Gl.bufferSubData(GL.ARRAY_BUFFER, 0, #if cpp vertices.length, #end new Float32Array(vertices.splice(offset, offset + count)));
		}
		
		this._resetVertexBufferBinding();
	}
	
	inline public function updateDynamicVertexBuffer2(vertexBuffer:WebGLBuffer, vertices:Float32Array, offset:Int = 0, count:Int = -1) {
		this.bindArrayBuffer(vertexBuffer);
		
		if (count == -1) {
			Gl.bufferSubData(GL.ARRAY_BUFFER, offset, #if cpp vertices.length, #end vertices);
		}
		else {
			Gl.bufferSubData(GL.ARRAY_BUFFER, 0, #if cpp vertices.length, #end vertices.subarray(offset, offset + count));
		}
		
		this._resetVertexBufferBinding();
	}

	inline private function _resetIndexBufferBinding() {
		this.bindIndexBuffer(null);
		this._cachedIndexBuffer = null;
	}

	inline public function createIndexBuffer(indices:Dynamic/*Array<Int>*/):WebGLBuffer {
		var vbo = Gl.createBuffer();
		var ret = new WebGLBuffer(vbo);		
		this.bindIndexBuffer(ret);
		
		//var arrayBuffer:ArrayBufferView = null;
		var need32Bits = false;
		
		if (Reflect.getProperty(indices, "toString") != null && StringTools.startsWith(indices.toString(), "UInt16Array")) {
			//arrayBuffer = indices;
			Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, #if cpp indices.length, #end indices, GL.STATIC_DRAW);
		} 
		else {
			//check 32 bit support
			if (this._caps.uintIndices) {
				if (Reflect.getProperty(indices, "toString") != null && StringTools.startsWith(indices.toString(), "UInt32Array")) {
					//arrayBuffer = indices;
					Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, #if cpp indices.length, #end indices, GL.STATIC_DRAW);
					need32Bits = true;
				} 
				else {
					//number[] or Int32Array, check if 32 bit is necessary
					for (index in 0...indices.length) {
						if (indices[index] > 65535) {
							need32Bits = true;
							break;
						}
					}
					
					//arrayBuffer = need32Bits ? new UInt32Array(indices) : new UInt16Array(indices);
					Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, #if cpp indices.length, #end need32Bits ? new UInt32Array(indices) : new UInt16Array(indices), GL.STATIC_DRAW);
				}
			} 
			else {
				//no 32 bit support, force conversion to 16 bit (values greater 16 bit are lost)
				//arrayBuffer = new UInt16Array(indices);
				Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, #if cpp indices.length, #end new UInt16Array(indices), GL.STATIC_DRAW);
			}
		}
		
		//Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, #if cpp arrayBuffer.length, #end arrayBuffer, GL.STATIC_DRAW);
		this._resetIndexBufferBinding();
		ret.references = 1;
		ret.is32Bits = need32Bits;		
		return ret;
	}
	
	inline public function bindArrayBuffer(buffer:WebGLBuffer) {
		if (!this._vaoRecordInProgress) {
			this._unBindVertexArrayObject();
		}
		this.bindBuffer(buffer, GL.ARRAY_BUFFER);
	}
	
	inline public function bindUniformBuffer(?buffer:WebGLBuffer) {
		Gl.bindBuffer(GL.UNIFORM_BUFFER, buffer == null ? null : buffer.buffer);
	}

	inline public function bindUniformBufferBase(buffer:WebGLBuffer, location:Int) {
		untyped Gl.bindBufferBase(GL.UNIFORM_BUFFER, location, buffer.buffer);
	}

	inline public function bindUniformBlock(shaderProgram:GLProgram, blockName:String, index:Int) {
		var uniformLocation = untyped Gl.getUniformBlockIndex(shaderProgram, blockName);
		
		untyped Gl.uniformBlockBinding(shaderProgram, uniformLocation, index);
	}
	
	inline private function bindIndexBuffer(buffer:WebGLBuffer) {
		if (!this._vaoRecordInProgress) {
			this._unBindVertexArrayObject();
		}
		this.bindBuffer(buffer, GL.ELEMENT_ARRAY_BUFFER);
	}
	
	inline private function bindBuffer(buffer:WebGLBuffer, target:Int) {
		if (this._vaoRecordInProgress || this._currentBoundBuffer[target] != buffer) {
			Gl.bindBuffer(target, buffer == null ? null : buffer.buffer);
			this._currentBoundBuffer[target] = (buffer == null ? null : buffer);
		}
	}

	inline public function updateArrayBuffer(data:Float32Array) {
		Gl.bufferSubData(GL.ARRAY_BUFFER, 0, #if cpp data.length, #end data);
	}
	
	private function vertexAttribPointer(buffer:WebGLBuffer, indx:Int, size:Int, type:Int, normalized:Bool, stride:Int, offset:Int) {
		var pointer:BufferPointer = this._currentBufferPointers[indx];
		
		var changed:Bool = false;
		if (pointer == null) {
			changed = true;
			this._currentBufferPointers[indx] = new BufferPointer(indx, size, type, normalized, stride, offset, buffer);
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
		
		if (changed || this._vaoRecordInProgress) {
			this.bindArrayBuffer(buffer);
			Gl.vertexAttribPointer(indx, size, type, normalized, stride, offset);
		}
	}
	
	private function _bindIndexBufferWithCache(indexBuffer:WebGLBuffer) {
		if (indexBuffer == null) {
			return;
		}
		if (this._cachedIndexBuffer != indexBuffer) {
			this._cachedIndexBuffer = indexBuffer;
			this.bindIndexBuffer(indexBuffer);
			this._uintIndicesCurrentlySet = indexBuffer.is32Bits;
		}
	}

	private function _bindVertexBuffersAttributes(vertexBuffers:Map<String, VertexBuffer>, effect:Effect) {
		var attributes = effect.getAttributesNames();
		
		if (!this._vaoRecordInProgress) {
			this._unBindVertexArrayObject();
		}
		
		this.unbindAllAttributes();
		
		for (index in 0...attributes.length) {
			var order = effect.getAttributeLocation(index);
			
			if (order >= 0) {
				var vertexBuffer = vertexBuffers[attributes[index]];
				
				if (vertexBuffer == null) {
					continue;
				}
				
				Gl.enableVertexAttribArray(order);
				if (!this._vaoRecordInProgress) {
					this._vertexAttribArraysEnabled[order] = true;
				}
				
				var buffer = vertexBuffer.getBuffer();
				this.vertexAttribPointer(buffer, order, vertexBuffer.getSize(), GL.FLOAT, false, Std.int(vertexBuffer.getStrideSize() * 4), Std.int(vertexBuffer.getOffset() * 4));
				
				if (vertexBuffer.getIsInstanced()) {
					untyped Gl.vertexAttribDivisor(order, vertexBuffer.getInstanceDivisor());
					if (!this._vaoRecordInProgress) {
						this._currentInstanceLocations.push(order);
						this._currentInstanceBuffers.push(buffer);
					}
				}
			}
		}
	}

	public function recordVertexArrayObject(vertexBuffers:Map<String, VertexBuffer>, indexBuffer:WebGLBuffer, effect:Effect):GLVertexArrayObject {
		var vao = untyped Gl.createVertexArray();
		
		this._vaoRecordInProgress = true;
		
		untyped Gl.bindVertexArray(vao);
		
		this._mustWipeVertexAttributes = true;
		this._bindVertexBuffersAttributes(vertexBuffers, effect);
		
		this.bindIndexBuffer(indexBuffer);
		
		this._vaoRecordInProgress = false;
		untyped Gl.bindVertexArray(null);
		
		return vao;
	}

	public function bindVertexArrayObject(vertexArrayObject:GLVertexArrayObject, indexBuffer:WebGLBuffer) {
		if (this._cachedVertexArrayObject != vertexArrayObject) {
			this._cachedVertexArrayObject = vertexArrayObject;
			
			untyped Gl.bindVertexArray(vertexArrayObject);
			this._cachedVertexBuffers = null;
			this._cachedIndexBuffer = null;
			
			this._uintIndicesCurrentlySet = indexBuffer != null && indexBuffer.is32Bits;
			this._mustWipeVertexAttributes = true;
		}
	}

	public function bindBuffersDirectly(vertexBuffer:WebGLBuffer, indexBuffer:WebGLBuffer, vertexDeclaration:Array<Int>, vertexStrideSize:Int, effect:Effect) {
		if (this._cachedVertexBuffers != vertexBuffer || this._cachedEffectForVertexBuffers != effect) {
			this._cachedVertexBuffers = vertexBuffer;
			this._cachedEffectForVertexBuffers = effect;
			
			var attributesCount = effect.getAttributesCount();
			
			this._unBindVertexArrayObject();
			this.unbindAllAttributes();
			
			var offset:Int = 0;
			for (index in 0...attributesCount) {
				if (index < vertexDeclaration.length) {
					var order = effect.getAttributeLocation(index);
					
					if (order >= 0) {
						Gl.enableVertexAttribArray(order);
						this._vertexAttribArraysEnabled[order] = true;						
						this.vertexAttribPointer(vertexBuffer, order, vertexDeclaration[index], GL.FLOAT, false, vertexStrideSize, offset);
					}
					
					offset += Std.int(vertexDeclaration[index] * 4);
				}
			}
		}
		
		this._bindIndexBufferWithCache(indexBuffer);
	}
	
	private function _unBindVertexArrayObject() {
		if (this._cachedVertexArrayObject == null) {
			return;
		}
		
		this._cachedVertexArrayObject = null;
		untyped Gl.bindVertexArray(null);
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
			untyped Gl.vertexAttribDivisor(offsetLocation, 0);
		}
		
		this._currentInstanceBuffers.splice(0, this._currentInstanceBuffers.length);
		this._currentInstanceLocations.splice(0, this._currentInstanceLocations.length);
	}
	
	inline public function releaseVertexArrayObject(vao:GLVertexArrayObject) {
		untyped Gl.deleteVertexArray(vao);
	}
	
	public function _releaseBuffer(buffer:WebGLBuffer):Bool {
		buffer.references--;
		
		if (buffer.references == 0) {
			Gl.deleteBuffer(buffer.buffer);
			return true;
		}
		
		return false;
	}

	public function createInstancesBuffer(capacity:Int):WebGLBuffer {
		var buffer = new WebGLBuffer(Gl.createBuffer());
		
		buffer.capacity = capacity;
		
		this.bindArrayBuffer(buffer);
		Gl.bufferData(GL.ARRAY_BUFFER, #if cpp capacity, #end new Float32Array(capacity), GL.DYNAMIC_DRAW);
		
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
			Gl.bufferSubData(GL.ARRAY_BUFFER, 0, #if cpp data.length, #end new Float32Array(data));
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
				GL.vertexAttribDivisor(ai.index, 1);
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
				untyped Gl.vertexAttribDivisor(offsetLocation, 1);
				this._currentInstanceLocations.push(offsetLocation);
				this._currentInstanceBuffers.push(instancesBuffer);
			}
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
		
		this._drawCalls.addCount(1, false);
		
		// Render
		var indexFormat = this._uintIndicesCurrentlySet ? GL.UNSIGNED_INT : GL.UNSIGNED_SHORT;
		var mult:Int = this._uintIndicesCurrentlySet ? 4 : 2;
		if (instancesCount > 0) {
			untyped Gl.drawElementsInstanced(useTriangles ? GL.TRIANGLES : GL.LINES, indexCount, indexFormat, indexStart * mult, instancesCount);
			return;
		}
		
		Gl.drawElements(useTriangles ? GL.TRIANGLES : GL.LINES, indexCount, indexFormat, Std.int(indexStart * mult));
	}

	public function drawPointClouds(verticesStart:Int, verticesCount:Int, instancesCount:Int = 0) {
		// Apply states
		this.applyStates();
		this._drawCalls.addCount(1, false);
		
		if (instancesCount > 0) {
			untyped Gl.drawArraysInstanced(GL.POINTS, verticesStart, verticesCount, instancesCount);			
			return;
		}
		
		Gl.drawArrays(GL.POINTS, verticesStart, verticesCount);
	}
	
	public function drawUnIndexed(useTriangles:Bool, verticesStart:Int, verticesCount:Int, instancesCount:Int = 0) {
		// Apply states
		this.applyStates();
		this._drawCalls.addCount(1, false);
		
		if (instancesCount > 0) {
			untyped Gl.drawArraysInstanced(useTriangles ? GL.TRIANGLES : GL.LINES, verticesStart, verticesCount, instancesCount);			
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
		var vertexShader = compileShader(#if (js || purejs) Gl, #end vertexCode, "vertex", defines, shaderVersion);
		var fragmentShader = compileShader(#if (js || purejs) Gl, #end fragmentCode, "fragment", defines, shaderVersion);
		
		var shaderProgram = Gl.createProgram();
		Gl.attachShader(shaderProgram, vertexShader);
		Gl.attachShader(shaderProgram, fragmentShader);
		
		Gl.linkProgram(shaderProgram);
		
		var linked = Gl.getProgramParameter(shaderProgram, GL.LINK_STATUS);
		
		if (linked == null && linked == 0) {
			Gl.validateProgram(shaderProgram);
			var error = Gl.getProgramInfoLog(shaderProgram);
			if (error != "") {
				throw(error);
			}
		}
		
		Gl.deleteShader(vertexShader);
		Gl.deleteShader(fragmentShader);
		
		return shaderProgram;
	}

	inline public function getUniforms(shaderProgram:GLProgram, uniformsNames:Array<String>):Array<GLUniformLocation> {
		var results:Array<GLUniformLocation> = [];
		
		for (index in 0...uniformsNames.length) {
			results.push(Gl.getUniformLocation(shaderProgram, uniformsNames[index]));
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
		// Use program
		this.setProgram(effect.getProgram());
		
		this._currentEffect = effect;
		
		if (effect.onBind != null) {
			effect.onBind(effect);
		}
		effect.onBindObservable.notifyObservers(effect);
	}
	
	public function setIntArray(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform == null) {
			return;
		}
		
		Gl.uniform1iv(uniform, #if cpp array.length, #end array);
	}

	public function setIntArray2(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform == null || array.length % 2 != 0) {
			return;
		}
		
		Gl.uniform2iv(uniform, #if cpp array.length, #end array);
	}

	public function setIntArray3(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform == null || array.length % 3 != 0) {
			return;
		}
		
		Gl.uniform3iv(uniform, #if cpp array.length, #end array);
	}

	public function setIntArray4(uniform:GLUniformLocation, array:Int32Array) {
		if (uniform == null || array.length % 4 != 0) {
			return;
		}
		
		Gl.uniform4iv(uniform, #if cpp array.length, #end array);
	}

	public function setFloatArray(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform == null) {
			return;
		}
		
		Gl.uniform1fv(uniform, #if cpp array.length, #end array);
	}

	public function setFloatArray2(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform == null || array.length % 2 != 0) {
			return;
		}
		
		Gl.uniform2fv(uniform, #if cpp array.length, #end array);
	}

	public function setFloatArray3(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform == null || array.length % 3 != 0) {
			return;
		}
		
		Gl.uniform3fv(uniform, #if cpp array.length, #end array);
	}

	public function setFloatArray4(uniform:GLUniformLocation, array:Float32Array) {
		if (uniform == null || array.length % 4 != 0) {
			return;
		}
		
		Gl.uniform4fv(uniform, #if cpp array.length, #end array);
	}
	
	inline public function setArray(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			#if (js || purejs)
			Gl.uniform1fv(uniform, new Float32Array(array)); 
			#else
			Gl.uniform1fv(uniform, array.length, new Float32Array(array));
			#end
		}		
	}
	
	inline public function setArray2(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null && array.length % 2 == 0) {
			#if (js || purejs)
			Gl.uniform2fv(uniform, new Float32Array(array));
			#else
			Gl.uniform2fv(uniform, 2, new Float32Array(array));
			#end
		}
	}

	inline public function setArray3(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null && array.length % 3 == 0) {
			#if (js || purejs)
			Gl.uniform3fv(uniform, new Float32Array(array));
			#else
			Gl.uniform3fv(uniform, 3, new Float32Array(array));
			#end
		}
	}

	inline public function setArray4(uniform:GLUniformLocation, array:Array<Float>) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null && array.length % 4 == 0) {
			#if (js || purejs)
			Gl.uniform4fv(uniform, new Float32Array(array));
			#else
			Gl.uniform4fv(uniform, 4, new Float32Array(array));
			#end
		}
	}

	inline public function setMatrices(uniform:GLUniformLocation, matrices: #if (js || purejs) Float32Array #else Array<Float> #end ) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniformMatrix4fv(uniform, #if cpp matrices.length, #end false, #if (js || purejs) matrices #else new Float32Array(matrices) #end);
		}
	}

	inline public function setMatrix(uniform:GLUniformLocation, matrix:Matrix) {	
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniformMatrix4fv(uniform, #if cpp matrix.m.length, #end false, #if (js || purejs) matrix.m #else new Float32Array(matrix.m) #end );
		}
	}
	
	inline public function setMatrix3x3(uniform:GLUniformLocation, matrix:Float32Array) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniformMatrix3fv(uniform, #if cpp matrix.length, #end false, matrix);
		}
	}

	inline public function setMatrix2x2(uniform:GLUniformLocation, matrix:Float32Array) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniformMatrix2fv(uniform, #if cpp matrix.length, #end false, matrix);
		}
	}

	inline public function setFloat(uniform:GLUniformLocation, value:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniform1f(uniform, value);
		}
	}

	inline public function setFloat2(uniform:GLUniformLocation, x:Float, y:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniform2f(uniform, x, y);
		}
	}

	inline public function setFloat3(uniform:GLUniformLocation, x:Float, y:Float, z:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniform3f(uniform, x, y, z);
		}
	}

	inline public function setBool(uniform:GLUniformLocation, bool:Bool) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniform1i(uniform, bool ? 1 : 0);
		}
	}

	public function setFloat4(uniform:GLUniformLocation, x:Float, y:Float, z:Float, w:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniform4f(uniform, x, y, z, w);
		}
	}

	inline public function setColor3(uniform:GLUniformLocation, color3:Color3) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniform3f(uniform, color3.r, color3.g, color3.b);
		}
	}

	inline public function setColor4(uniform:GLUniformLocation, color3:Color3, alpha:Float) {
		/*#if (cpp && lime)
		if (uniform == 0) return;
		#else
		if (uniform == null) return; 
		#end*/
		if (uniform != null) {
			Gl.uniform4f(uniform, color3.r, color3.g, color3.b, alpha);
		}
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
		Gl.colorMask(enable, enable, enable, enable);
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
                this._alphaState.setAlphaBlendFunctionParameters(GL.ONE, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ONE);
                this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_PREMULTIPLIED_PORTERDUFF:
				this._alphaState.setAlphaBlendFunctionParameters(GL.ONE, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
				this._alphaState.alphaBlend = true;
				
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
				
			case Engine.ALPHA_INTERPOLATE:
				this._alphaState.setAlphaBlendFunctionParameters(GL.CONSTANT_COLOR, GL.ONE_MINUS_CONSTANT_COLOR, GL.CONSTANT_ALPHA, GL.ONE_MINUS_CONSTANT_ALPHA);
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
			this._stencilState.reset();
			this._depthCullingState.reset();
			this.setDepthFunctionToLessOrEqual();
			this._alphaState.reset();
		}
		
		this._cachedVertexBuffers = null;
		this._cachedIndexBuffer = null;
		this._cachedEffectForVertexBuffers = null;
		this._unBindVertexArrayObject();
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
		
		var isDDS = this.getCaps().s3tc != null && (extension == ".dds");
		var isTGA = (extension == ".tga");
		
		scene._addPendingData(texture);
		texture.url = url;
		texture.generateMipMaps = !noMipmap;
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
		if (internalFormat == GL.RGB) {
			internalFormat = GL.RGBA;
			needConversion = true;
		}
		
		this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
		//Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY == null ? 1 : (invertY ? 1 : 0));
		
		if (texture._width % 4 != 0) {
			Gl.pixelStorei(GL.UNPACK_ALIGNMENT, 1);
		}
		
		var facesIndex = [
			GL.TEXTURE_CUBE_MAP_POSITIVE_X, GL.TEXTURE_CUBE_MAP_POSITIVE_Y, GL.TEXTURE_CUBE_MAP_POSITIVE_Z,
			GL.TEXTURE_CUBE_MAP_NEGATIVE_X, GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, GL.TEXTURE_CUBE_MAP_NEGATIVE_Z
		];
		
		// Data are known to be in +X +Y +Z -X -Y -Z
		for (index in 0...facesIndex.length) {
			var faceData = data[index];
			
			if (compression != null) {
				Gl.compressedTexImage2D(facesIndex[index], level, Reflect.getProperty(this.getCaps().s3tc, compression), texture._width, texture._height, 0, #if cpp faceData.length, #end faceData);
			} 
			else {
				if (needConversion) {
					faceData = this._convertRGBtoRGBATextureData(faceData, texture._width, texture._height, type);
				}
				Gl.texImage2D(facesIndex[index], level, internalSizedFomat, texture._width, texture._height, 0, internalFormat, textureType, faceData);
			}
		}
		
		var isPot = !this.needPOTTextures || (com.babylonhx.math.Tools.IsExponentOfTwo(texture._width) && com.babylonhx.math.Tools.IsExponentOfTwo(texture._height));
		if (isPot && texture.generateMipMaps && level == 0) {
			Gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
		}
		this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
		
		this.resetTextureCache();
		texture.isReady = true;
	}
	
	public function createRawCubeTexture(data:Array<ArrayBufferView>, size:Int, format:Int, type:Int, generateMipMaps:Bool, invertY:Bool, samplingMode:Int, compression:String = null):WebGLTexture {
		var texture = new WebGLTexture("", Gl.createTexture());
		texture.isCube = true;
		texture.references = 1;
		texture.generateMipMaps = generateMipMaps;
		texture.format = format;
		texture.type = type;
		
		var textureType = this._getWebGLTextureType(type);
		var internalFormat = this._getInternalFormat(format);
		var internalSizedFomat = this._getRGBABufferInternalSizedFormat(type);
		
		var needConversion = false;
		if (internalFormat == GL.RGB) {
			internalFormat = GL.RGBA;
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
		
		this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
		
		// Filters
		if (data != null && generateMipMaps) {
			Gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
		}
		
		if (textureType == GL.FLOAT && !this._caps.textureFloatLinearFiltering) {
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		}
		else if (textureType == Engine.HALF_FLOAT_OES && !this._caps.textureHalfFloatLinearFiltering) {
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		}
		else {
			var filters = getSamplingParameters(samplingMode, generateMipMaps);
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, filters.mag);
			Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, filters.min);
		}
		
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
		
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
				GL.TEXTURE_CUBE_MAP_POSITIVE_X, GL.TEXTURE_CUBE_MAP_POSITIVE_Y, GL.TEXTURE_CUBE_MAP_POSITIVE_Z,
				GL.TEXTURE_CUBE_MAP_NEGATIVE_X, GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, GL.TEXTURE_CUBE_MAP_NEGATIVE_Z
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
				if (internalFormat == GL.RGB) {
					internalFormat = GL.RGBA;
					needConversion = true;
				}
				
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
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
						Gl.texImage2D(facesIndex[mipIndex], level, internalSizedFomat, mipSize, mipSize, 0, internalFormat, textureType, mipFaceData);
					}
				}
				
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
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
			Gl.compressedTexImage2D(GL.TEXTURE_2D, 0, Reflect.getProperty(this.getCaps().s3tc, compression), texture._width, texture._height, 0, #if cpp data.length, #end data);
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
		
		texture.samplingMode = samplingMode;
	}
	
	inline public function updateDynamicTexture(texture:WebGLTexture, canvas:Image, invertY:Bool, premulAlpha:Bool = false, format:Int = -1) {
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		//Gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);
		if (premulAlpha) {
			Gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
		}
		var internalFormat = format != -1 ? this._getInternalFormat(format) : GL.RGBA;
		Gl.texImage2D(GL.TEXTURE_2D, 0, internalFormat, canvas.width, canvas.height, 0, internalFormat, GL.UNSIGNED_BYTE, cast canvas.data);
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
			generateMipMaps = options.generateMipMaps == null ? options : options.generateMipMaps;
			generateDepthBuffer = options.generateDepthBuffer == null ? true : options.generateDepthBuffer;
			generateStencilBuffer = generateDepthBuffer != null && options.generateStencilBuffer;
			
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
		
		var texture = new WebGLTexture("", GL.createTexture());
		this._bindTextureDirectly(GL.TEXTURE_2D, texture.data);
		
		var width = size.width != null ? size.width : size;
		var height = size.height != null ? size.height : size;
		
		var filters = getSamplingParameters(samplingMode, generateMipMaps);
		
		if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloat) {
			type = Engine.TEXTURETYPE_UNSIGNED_INT;
			Tools.Warn("Float textures are not supported. Render target forced to TEXTURETYPE_UNSIGNED_BYTE type");
		}
		
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		GL.texImage2D(GL.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(type), width, height, 0, GL.RGBA, this._getWebGLTextureType(type), null);
		
		// Create the framebuffer
		var framebuffer = GL.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.data, 0);
		
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(generateStencilBuffer, generateDepthBuffer, width, height);
		
		if (generateMipMaps) {
			GL.generateMipmap(GL.TEXTURE_2D);
		}
		
		// Unbind
		this._bindTextureDirectly(GL.TEXTURE_2D, null);
		GL.bindRenderbuffer(GL.RENDERBUFFER, null);
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
		var framebuffer = Gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		
		var colorRenderbuffer = Gl.createRenderbuffer();
		Gl.bindRenderbuffer(GL.RENDERBUFFER, colorRenderbuffer);
		untyped Gl.renderbufferStorageMultisample(GL.RENDERBUFFER, 4, GL.RGBA8, width, height);
		Gl.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.RENDERBUFFER, colorRenderbuffer);
		Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT1, GL.RENDERBUFFER, colorRenderbuffer);
		Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, colorRenderbuffer);
		
		var width = size.width != null ? size.width : size;
		var height = size.height != null ? size.height : size;
		
		var textures:Array<WebGLTexture> = [];
		var attachments:Array<Int> = [];
		
		var depthStencilBuffer = this._setupFramebufferDepthAttachments(generateStencilBuffer, generateDepthBuffer, width, height);
		
		for (i in 0...textureCount) {
			var samplingMode = samplingModes[i] != null ? samplingModes[i] : defaultSamplingMode;
			var type = types[i] != null ? types[i] : defaultType;
			
			if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloatLinearFiltering) {
				// if floating point linear (gl.FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
			else if (type == Engine.TEXTURETYPE_HALF_FLOAT && !this._caps.textureHalfFloatLinearFiltering) {
				// if floating point linear (HALF_FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
			
			var filters = getSamplingParameters(samplingMode, generateMipMaps);
			if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloat) {
				type = Engine.TEXTURETYPE_UNSIGNED_INT;
				Tools.Warn("Float textures are not supported. Render target forced to TEXTURETYPE_UNSIGNED_BYTE type");
			}
			
			var texture = new WebGLTexture("", Gl.createTexture());
			var attachment = GL.COLOR_ATTACHMENT0 + i;// gl["COLOR_ATTACHMENT" + i];
			textures.push(texture);
			attachments.push(attachment);
			
			Gl.activeTexture(GL.TEXTURE0 + i);
			Gl.bindTexture(GL.TEXTURE_2D, texture.data);
			
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			
			Gl.texImage2D(GL.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(type), width, height, 0, GL.RGBA, this._getWebGLTextureType(type), #if cpp 0 #else null #end );
			
			Gl.framebufferTexture2D(GL.DRAW_FRAMEBUFFER, attachment, GL.TEXTURE_2D, texture.data, 0);
			
			if (generateMipMaps) {
				Gl.generateMipmap(GL.TEXTURE_2D);
			}
			
			// Unbind
			this._bindTextureDirectly(GL.TEXTURE_2D, null);
			
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
			var depthTexture = new WebGLTexture('', Gl.createTexture());
			
			Gl.activeTexture(GL.TEXTURE0);
			Gl.bindTexture(GL.TEXTURE_2D, depthTexture.data);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			Gl.texImage2D(
				GL.TEXTURE_2D,
				0,
				GL.DEPTH_COMPONENT16,
				width,
				height,
				0,
				GL.DEPTH_COMPONENT,
				GL.UNSIGNED_SHORT,
				#if cpp 0 #else null #end
			);
			
			Gl.framebufferTexture2D(
				GL.FRAMEBUFFER,
				GL.DEPTH_ATTACHMENT,
				GL.TEXTURE_2D,
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
			depthTexture.samplingMode = GL.NEAREST;
			depthTexture._generateDepthBuffer = generateDepthBuffer;
			depthTexture._generateStencilBuffer = generateStencilBuffer;
			
			textures.push(depthTexture);
			this._loadedTexturesCache.push(depthTexture);
		}
		
		untyped Gl.drawBuffers(attachments);
		Gl.bindRenderbuffer(GL.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		this.resetTextureCache();
		
		return textures;
	}
	
	private function _setupFramebufferDepthAttachments(generateStencilBuffer:Bool, generateDepthBuffer:Bool, width:Int, height:Int, samples:Int = 1):GLRenderbuffer {
		var depthStencilBuffer:GLRenderbuffer = null;

		// Create the depth/stencil buffer
		if (generateStencilBuffer) {
			depthStencilBuffer = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, depthStencilBuffer);
			
			if (samples > 1) {
				untyped Gl.renderbufferStorageMultisample(GL.RENDERBUFFER, samples, GL.DEPTH24_STENCIL8, width, height);
			} 
			else {
				Gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_STENCIL, width, height);
			}
			
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, depthStencilBuffer);
		}
		else if (generateDepthBuffer) {
			depthStencilBuffer = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, depthStencilBuffer);
			
			if (samples > 1) {
				untyped Gl.renderbufferStorageMultisample(GL.RENDERBUFFER, samples, GL.DEPTH_COMPONENT16, width, height);
			} 
			else {
				Gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);
			}
			
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depthStencilBuffer);
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
		
		samples = cast Math.min(samples, Gl.getParameter(GL.MAX_SAMPLES));
		
		// Dispose previous render buffers
		if (texture._depthStencilBuffer != null) {
			Gl.deleteRenderbuffer(texture._depthStencilBuffer);
		}
		
		if (texture._MSAAFramebuffer != null) {
			Gl.deleteFramebuffer(texture._MSAAFramebuffer);
		}
		
		if (texture._MSAARenderBuffer != null) {
			Gl.deleteRenderbuffer(texture._MSAARenderBuffer);
		}
		
		if (samples > 1) {
			texture._MSAAFramebuffer = Gl.createFramebuffer();
			this.bindUnboundFramebuffer(texture._MSAAFramebuffer);
			
			var colorRenderbuffer = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, colorRenderbuffer);
			untyped Gl.renderbufferStorageMultisample(GL.RENDERBUFFER, samples, GL.RGBA8, texture._width, texture._height);
			
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.RENDERBUFFER, colorRenderbuffer);
			
			texture._MSAARenderBuffer = colorRenderbuffer;
		} 
		else {
			this.bindUnboundFramebuffer(texture._framebuffer);
		}
		
		texture.samples = samples;
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(texture._generateStencilBuffer, texture._generateDepthBuffer, texture._width, texture._height, samples);
		
		Gl.bindRenderbuffer(GL.RENDERBUFFER, null);
		this.bindUnboundFramebuffer(null);
		
		return samples;
	}
	
	public function _uploadDataToTexture(target:Int, lod:Int, internalFormat:Int, width:Int, height:Int, format:Int, type:Int, data:ArrayBufferView) {
        Gl.texImage2D(target, lod, internalFormat, width, height, 0, format, type, data);
    }

    public function _uploadCompressedDataToTexture(target:Int, lod:Int, internalFormat:Int, width:Int, height:Int, data:ArrayBufferView) {
        Gl.compressedTexImage2D(target, lod, internalFormat, width, height, 0, data);
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
		
		var filters = getSamplingParameters(samplingMode, generateMipMaps);
		
		this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
		
		for (face in 0...6) {
			Gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + face, 0, GL.RGBA, size.width, size.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, #if cpp 0 #else null #end );
		}
		
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, filters.mag);
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, filters.min);
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		Gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		// Create the framebuffer
		var framebuffer = Gl.createFramebuffer();
		this.bindUnboundFramebuffer(framebuffer);
		
		texture._depthStencilBuffer = this._setupFramebufferDepthAttachments(generateStencilBuffer, generateDepthBuffer, size.width, size.height);
		
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
		texture._width = size.width;
		texture._height = size.height;
		texture.isReady = true;
		
		this.resetTextureCache();
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createPrefilteredCubeTexture(rootUrl:String, scene:Scene, scale:Float, offset:Float, onLoad:Void->Void, onError:Void->Void = null, ?format:Int):WebGLTexture {
		var callback = function(loadData:Dynamic) {
			if (this._caps.textureLOD || loadData == null) {
				// Do not add extra process if texture lod is supported.
				if (onLoad != null) {
					onLoad();
				}
				return;
			}
			
			var mipSlices = 3;
			
			var gl = Gl;
			var width = loadData.width;
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
				var maxLODIndex = com.babylonhx.math.Tools.Log2(width) * scale + offset; // roughness = 1
				
				var lodIndex = minLODIndex + (maxLODIndex - minLODIndex) * roughness;
				var mipmapIndex = Math.min(Math.max(Math.round(lodIndex), 0), maxLODIndex);
				
				var glTextureFromLod = new WebGLTexture('', gl.createTexture());
				glTextureFromLod.isCube = true;
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, glTextureFromLod.data);
				
				gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
				gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
				
				// VK TODO:
				/*if (loadData.isDDS) {
					var info: Internals.DDSInfo = loadData.info;
					var data: any = loadData.data;
					gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, info.isCompressed ? 1 : 0);
					
					Internals.DDSTools.UploadDDSLevels(this, data, info, true, 6, mipmapIndex);
				}*/
				
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
				
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
		
		return this.createCubeTexture(rootUrl, scene, null, false, callback, onError, format);
	}

	public function createCubeTexture(rootUrl:String, scene:Scene, files:Array<String> = null, noMipmap:Bool = false, onLoad:Dynamic = null, onError:Void->Void = null, ?format:Int):WebGLTexture {
		var texture = new WebGLTexture(rootUrl, Gl.createTexture());
		texture.isCube = true;
		texture.url = rootUrl;
		texture.references = 1;
		texture.onLoadedCallbacks = [];
		texture.generateMipMaps = !noMipmap;
		
		var extension = rootUrl.substr(rootUrl.length - 4, 4).toLowerCase();
		var isDDS = this.getCaps().s3tc != null && (extension == ".dds");
		
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
			
			var internalFormat = format != null ? this._getInternalFormat(format) : GL.RGBA;
			
			function generate() {
				var width = this.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(imgs[0].width, this._caps.maxCubemapTextureSize) : imgs[0].width;
				var height = width;
				
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, texture.data);
				
				for (index in 0...faces.length) {
					Gl.texImage2D(faces[index], 0, internalFormat, width, height, 0, internalFormat, GL.UNSIGNED_BYTE, imgs[index].data);
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
		
		this._loadedTexturesCache.push(texture);
		
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
	
	public function _releaseFramebufferObjects(texture:WebGLTexture) {
		if (texture._framebuffer != null) {
			Gl.deleteFramebuffer(texture._framebuffer);
			texture._framebuffer = null;
		}
		
		if (texture._depthStencilBuffer != null) {
			Gl.deleteRenderbuffer(texture._depthStencilBuffer);
			texture._depthStencilBuffer = null;
		}
		
		if (texture._MSAAFramebuffer != null) {
			Gl.deleteFramebuffer(texture._MSAAFramebuffer);
			texture._MSAAFramebuffer = null;
		}
		
		if (texture._MSAARenderBuffer != null) {
			Gl.deleteRenderbuffer(texture._MSAARenderBuffer);
			texture._MSAARenderBuffer = null;
		}           
	}

	public function _releaseTexture(texture:WebGLTexture) {
		this._releaseFramebufferObjects(texture);
		
		Gl.deleteTexture(texture.data);
		
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
	
	/*inline*/ private function activateTexture(texture:Int) {
		if (this._activeTexture != texture) {
			Gl.activeTexture(texture);
			this._activeTexture = texture;
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
		
		this.activateTexture(GL.TEXTURE0 + channel);
		this._bindTextureDirectly(GL.TEXTURE_2D, texture);
	}

	inline public function setTextureFromPostProcess(channel:Int, postProcess:PostProcess) {
		//if (postProcess._textures.length > 0) {
			this._bindTexture(channel, postProcess._textures.data[postProcess._currentRenderTextureInd].data);
		//}
	}
	
	public function unbindAllTextures() {
		for (channel in 0...this._caps.maxTexturesImageUnits) {
			this.activateTexture(GL.TEXTURE0 + channel);
			this._bindTextureDirectly(GL.TEXTURE_2D, null);
			this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
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
		if (texture == null) {
			if (this._activeTexturesCache[channel] != null) {
				this.activateTexture(GL.TEXTURE0 + channel);
				this._bindTextureDirectly(GL.TEXTURE_2D, null);
				this._bindTextureDirectly(GL.TEXTURE_CUBE_MAP, null);
			}
			
			return;
		}
		
		// Video
		var alreadyActivated = false;
		if (Std.is(texture, VideoTexture)) {
			this.activateTexture(GL.TEXTURE0 + channel);
			alreadyActivated = true;
			cast(texture, VideoTexture).update();
		} 
		else if (texture.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) { // Delay loading
			texture.delayLoad();
			return;
		}
		
		var internalTexture = texture.isReady() ? texture.getInternalTexture() : (texture.isCube ? this.emptyCubeTexture : this.emptyTexture);
		
		if (this._activeTexturesCache[channel] == internalTexture.data) {
			return;
		}
		
		if(!alreadyActivated) {
			this.activateTexture(GL.TEXTURE0 + channel);
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
		#if (js || purejs)
		Gl.uniform1iv(uniform, this._textureUnits);
		#else
		GL.uniform1iv(uniform, this._textureUnits.length, this._textureUnits);
		#end
		
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
	
	public function unbindAllAttributes() {
		if (this._mustWipeVertexAttributes) {
			this._mustWipeVertexAttributes = false;
			
			for (i in 0...this._caps.maxVertexAttribs) {
				Gl.disableVertexAttribArray(i);
				this._vertexAttribArraysEnabled[i] = false;
				this._currentBufferPointers[i] = null;
			}
			return;
		}
		
		for (i in 0...this._vertexAttribArraysEnabled.length) {
			if (i >= this._caps.maxVertexAttribs || !this._vertexAttribArraysEnabled[i]) {
				continue;
			}
			
			Gl.disableVertexAttribArray(i);
			this._vertexAttribArraysEnabled[i] = false;
			this._currentBufferPointers[i] = null;
		}
	}
	
	public function releaseEffects() {
		for (name in this._compiledEffects.keys()) {
			Gl.deleteProgram(this._compiledEffects[name]._program);
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
            GL.deleteFramebuffer(this._dummyFramebuffer);
        }
		
		// Remove from Instances
		var index = Engine.Instances.indexOf(this);
		
		if (index >= 0) {
			Engine.Instances.splice(index, 1);
		}
	}
	
	public function _readTexturePixels(texture:WebGLTexture, width:Int, height:Int, faceIndex:Int = -1, lodIndex:Int = 0):ArrayBufferView {
		if (this._dummyFramebuffer != null) {
			this._dummyFramebuffer = Gl.createFramebuffer();
		}
		Gl.bindFramebuffer(GL.FRAMEBUFFER, this._dummyFramebuffer);
		
		if (faceIndex > -1) {
			Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture.data, lodIndex);           
		} 
		else {
			Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.data, lodIndex);
		}
		
		var readFormat = GL.RGBA;
		var readType = (texture.type != null) ? this._getWebGLTextureType(texture.type) : GL.UNSIGNED_BYTE;
		var buffer:ArrayBufferView = null;
		
		var hfOEStype_temp:Int = Engine.HALF_FLOAT_OES;
        switch (readType) {
            case GL.UNSIGNED_BYTE:
                buffer = new UInt8Array(Std.int(4 * width * height));
             
            case GL.FLOAT:
                buffer = new Float32Array(Std.int(4 * width * height));
                
			case hfOEStype_temp:
                buffer = new UInt16Array(Std.int(4 * width * height));                          
        }
		Gl.readPixels(0, 0, width, height, readFormat, readType, buffer);
		
		Gl.bindFramebuffer(GL.FRAMEBUFFER, null);
		
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
		while (Gl.getError() != GL.NO_ERROR) { }
		
		var successful = true;
		
		var texture = Gl.createTexture();
		Gl.bindTexture(GL.TEXTURE_2D, texture);
		Gl.texImage2D(GL.TEXTURE_2D, 0, this._getRGBABufferInternalSizedFormat(type), 1, 1, 0, GL.RGBA, this._getWebGLTextureType(type), #if cpp 0 #else null #end );
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);

		var fb = Gl.createFramebuffer();
		Gl.bindFramebuffer(GL.FRAMEBUFFER, fb);
		Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
		var status = Gl.checkFramebufferStatus(GL.FRAMEBUFFER);

		successful = successful && (status == GL.FRAMEBUFFER_COMPLETE);
		successful = successful && (Gl.getError() == GL.NO_ERROR);

		//try render by clearing frame buffer's color buffer
		if (successful) {
			Gl.clear(GL.COLOR_BUFFER_BIT);
			successful = successful && (Gl.getError() == GL.NO_ERROR);
		}

		//try reading from frame to ensure render occurs (just creating the FBO is not sufficient to determine if rendering is supported)
		if (successful) {
			//in practice it's sufficient to just read from the backbuffer rather than handle potentially issues reading from the texture
			Gl.bindFramebuffer(GL.FRAMEBUFFER, null);
			var readFormat = GL.RGBA;
			var readType = GL.UNSIGNED_BYTE;
			var buffer = new UInt8Array(4);
			Gl.readPixels(0, 0, 1, 1, readFormat, readType, buffer);
			successful = successful && (Gl.getError() == GL.NO_ERROR);
		}

		//clean up
		Gl.deleteTexture(texture);
		Gl.deleteFramebuffer(fb);
		Gl.bindFramebuffer(GL.FRAMEBUFFER, null);

		//clear accumulated errors
		while (!successful && (Gl.getError() != GL.NO_ERROR)) { }

		return successful;
	}

	public function _getWebGLTextureType(type:Int):Int {
		if (type == Engine.TEXTURETYPE_FLOAT) {
			return GL.FLOAT;
		}
		else if (type == Engine.TEXTURETYPE_HALF_FLOAT) {
			// Add Half Float Constant.
			return Engine.HALF_FLOAT_OES;
		}
		
		return GL.UNSIGNED_BYTE;
	}

	private function _getRGBABufferInternalSizedFormat(type:Int):Int {
		if (this._webGLVersion == 1) {
			return GL.RGBA;
		}
		
		if (type == Engine.TEXTURETYPE_FLOAT) {
			return GL.RGBA32F; // Engine.RGBA32F;
		}
		else if (type == Engine.TEXTURETYPE_HALF_FLOAT) {
			return GL.RGBA16F; // Engine.RGBA16F;
		}
		
		return GL.RGBA;
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
