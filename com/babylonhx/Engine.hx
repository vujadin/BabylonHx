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
import com.babylonhx.tools.Tools;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.typedarray.UInt8Array;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Int32Array;
import com.babylonhx.utils.typedarray.Int16Array;
import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.Image;


import haxe.ds.Vector;


#if (js || purejs)
import com.babylonhx.audio.AudioEngine;
import js.Browser;

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
	
	public static inline var TEXTUREFORMAT_ALPHA = 0;
	public static inline var TEXTUREFORMAT_LUMINANCE = 1;
	public static inline var TEXTUREFORMAT_LUMINANCE_ALPHA = 2;
	public static inline var TEXTUREFORMAT_RGB = 4;
	public static inline var TEXTUREFORMAT_RGBA = 5;

	public static inline var TEXTURETYPE_UNSIGNED_INT = 0;
	public static inline var TEXTURETYPE_FLOAT = 1;

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
	private var _renderingCanvas:Dynamic;

	private var _windowIsBackground:Bool = false;

	private var _onBlur:Void->Void;
	private var _onFocus:Void->Void;
	private var _onFullscreenChange:Void->Void;
	private var _onPointerLockChange:Void->Void;

	private var _hardwareScalingLevel:Float;	
	private var _caps:EngineCapabilities;
	private var _pointerLockRequested:Bool;
	private var _alphaTest:Bool;

	private var _runningLoop:Bool = false;
	private var _renderFunction:Dynamic;// Rectangle-> Void;// Void->Void;
		
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
	private var _alphaState:_AlphaState = new _AlphaState();
	private var _alphaMode:Int = Engine.ALPHA_DISABLE;

	// Cache
	private var _loadedTexturesCache:Array<WebGLTexture> = [];
	private var _maxTextureChannels:Int = 16;
	public var _activeTexturesCache:Vector<BaseTexture>;
	private var _currentEffect:Effect;
	private var _compiledEffects:Map<String, Effect> = new Map<String, Effect>();
	private var _vertexAttribArrays:Array<Bool>;
	private var _cachedViewport:Viewport;
	private var _cachedVertexBuffers:Dynamic;
	private var _cachedIndexBuffer:WebGLBuffer;
	private var _cachedEffectForVertexBuffers:Effect;
	private var _currentRenderTarget:WebGLTexture;
	private var _uintIndicesCurrentlySet:Bool = false;

	public var _canvasClientRect:Dynamic = { x: 0, y: 0, width: 960, height: 640 };

	private var _workingCanvas:Image;
	#if (openfl || nme)
	public var _workingContext:OpenGLView; 
	#end
	
	// quick and dirty solution to handle mouse/keyboard 
	public static var mouseDown:Array<Dynamic> = [];
	public static var mouseUp:Array<Dynamic> = [];
	public static var mouseMove:Array<Dynamic> = [];
	public static var mouseWheel:Array<Dynamic> = [];
	public static var touchDown:Array<Dynamic> = [];
	public static var touchUp:Array<Dynamic> = [];
	public static var touchMove:Array<Dynamic> = [];
	public static var keyUp:Array<Dynamic> = [];
	public static var keyDown:Array<Dynamic> = [];
	
	public var width:Int;
	public var height:Int;
	
	#if (js || purejs)
	public var audioEngine:AudioEngine = new AudioEngine();
	#end
	
	
	public function new(canvas:Dynamic, antialias:Bool = false, ?options:Dynamic, adaptToDeviceRatio:Bool = false) {		
		this._renderingCanvas = canvas;
		this._canvasClientRect.width = 960;// canvas.width;
		this._canvasClientRect.height = 640;// canvas.height;
		
		options = options != null ? options : {};
		options.antialias = antialias;
		
		if (options.preserveDrawingBuffer == null) {
            options.preserveDrawingBuffer = false;
        }
		
		#if purejs
		GL.context = cast(canvas, js.html.CanvasElement).getContext("webgl", options.antialiasing);
		#end
		
		#if (openfl || nme)
		this._workingContext = new OpenGLView();
		this._workingContext.render = this._renderLoop;
		canvas.addChild(this._workingContext);
		#end
		
		this.width = 960;
		this.height = 640;		
		
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
		this._caps = new EngineCapabilities();
		this._caps.maxTexturesImageUnits = GL.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
		this._caps.maxTextureSize = GL.getParameter(GL.MAX_TEXTURE_SIZE);
		this._caps.maxCubemapTextureSize = GL.getParameter(GL.MAX_CUBE_MAP_TEXTURE_SIZE);
		this._caps.maxRenderTextureSize = GL.getParameter(GL.MAX_RENDERBUFFER_SIZE);
		
		// Infos
		this._glVersion = GL.getParameter(GL.VERSION);
		this._glVendor = GL.getParameter(GL.VENDOR);
		this._glRenderer = GL.getParameter(GL.RENDERER);
		this._glExtensions = GL.getSupportedExtensions();
		//for (ext in this._glExtensions) {
			//trace(ext);
		//}
		//trace(this._glExtensions);
		
		#if (!snow || (js && snow))
		// Extensions
		try {
			this._caps.standardDerivatives = GL.getExtension('OES_standard_derivatives') != null;
			this._caps.s3tc = GL.getExtension('WEBGL_compressed_texture_s3tc');
			this._caps.textureFloat = (GL.getExtension('OES_texture_float') != null);
			this._caps.textureAnisotropicFilterExtension = GL.getExtension('EXT_texture_filter_anisotropic') || GL.getExtension('WEBKIT_EXT_texture_filter_anisotropic') || GL.getExtension("MOZ_EXT_texture_filter_anisotropic");
			this._caps.maxAnisotropy = this._caps.textureAnisotropicFilterExtension != null ? GL.getParameter(this._caps.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 0;
			
			#if (!mobile && cpp)
			this._caps.instancedArrays = GL.getExtension("GL_ARB_instanced_arrays");
			/*this._caps.instancedArrays = { 
				vertexAttribDivisorANGLE: GL.getExtension('glVertexAttribDivisorARB'),
				drawElementsInstancedANGLE: GL.getExtension('glDrawElementsInstancedARB'),
				drawArraysInstancedANGLE: GL.getExtension('glDrawElementsInstancedARB')
			};*/
			#else
			this._caps.instancedArrays = GL.getExtension("ANGLE_instanced_arrays");
			#end
			
			this._caps.uintIndices = GL.getExtension("OES_element_index_uint") != null;	
			this._caps.fragmentDepthSupported = GL.getExtension("EXT_frag_depth") != null;
			this._caps.highPrecisionShaderSupported = true;
			if (GL.getShaderPrecisionFormat != null) {
				var highp = GL.getShaderPrecisionFormat(GL.FRAGMENT_SHADER, GL.HIGH_FLOAT);
				this._caps.highPrecisionShaderSupported = highp != null && highp.precision != 0;
			}
			this._caps.drawBufferExtension = GL.getExtension("WEBGL_draw_buffers");
			this._caps.textureFloatLinearFiltering = GL.getExtension("OES_texture_float_linear") != null;
			this._caps.textureLOD = GL.getExtension('EXT_shader_texture_lod') != null;
			if (this._caps.textureLOD) {
				this._caps.textureLODExt = "GL_EXT_shader_texture_lod";
				this._caps.textureCubeLodFnName = "textureCubeLodEXT";
			}
		} 
		catch (err:Dynamic) {
			trace(err);
		}
		#if (!js && !purejs)
			if (this._caps.s3tc == null) {
				this._caps.s3tc = this._glExtensions.indexOf("GL_EXT_texture_compression_s3tc") != -1;
			}
			if (this._caps.textureAnisotropicFilterExtension == null || this._caps.textureAnisotropicFilterExtension == false) {
				
				this._caps.textureAnisotropicFilterExtension = this._glExtensions.indexOf("GL_EXT_texture_filter_anisotropic") != -1;
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
				this._caps.fragmentDepthSupported = GL.getExtension("GL_EXT_frag_depth") != null;
			}
			if (this._caps.drawBufferExtension == null) {
				this._caps.drawBufferExtension = GL.getExtension("GL_ARB_draw_buffers");
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
		this._caps.drawBufferExtension = null;
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
		
		this._activeTexturesCache = new Vector<BaseTexture>(this._maxTextureChannels);
		
		var msg:String = "BabylonHx - Cross-Platform 3D Engine | " + Date.now().getFullYear() + " | www.babylonhx.com";
		msg +=  " | GL version: " + this._glVersion + " | GL vendor: " + this._glVendor + " | GL renderer: " + this._glVendor; 
		trace(msg);
	}
	
	public function getExtensions():Array<String> {
		return this._glExtensions;
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
		/*if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget._width;
		}*/
		
		return width;
	}

	public function getRenderHeight(useScreen:Bool = false):Int {
		/*if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget._height;
		}*/
		
		return height;
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
        // Start new frame
        this.beginFrame();
        if (this._renderFunction != null) {
            this._renderFunction();
        }
		
        // Present
        this.endFrame();
		
		#if purejs
		Browser.window.requestAnimationFrame(untyped _renderLoop);
		#end
    }

	inline public function runRenderLoop(renderFunction:Dynamic) {
		this._runningLoop = true;
		this._renderFunction = renderFunction;
		
		#if purejs
		this._renderLoop();
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

	inline public function clear(color:Dynamic, backBuffer:Bool, depthStencil:Bool) {
		this.applyStates();
		
		if (backBuffer) {
			if(Std.is(color, Color4)) {
				GL.clearColor(color.r, color.g, color.b, color.a);
			} 
			else {
				GL.clearColor(color.r, color.g, color.b, 1.0);
			}
		}
		
		if (depthStencil && this._depthCullingState.depthMask) {
			GL.clearDepth(1.0);
		}
		var mode = 0;
		
		if (backBuffer) {
			mode |= GL.COLOR_BUFFER_BIT;
		}
		
		if (depthStencil && this._depthCullingState.depthMask) {
			mode |= GL.DEPTH_BUFFER_BIT;
		}
		
		GL.clear(mode);
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
		GL.viewport(Std.int(x * width), Std.int(y * height), Std.int(width * viewport.width), Std.int(height * viewport.height));
	}

	inline public function setDirectViewport(x:Int, y:Int, width:Int, height:Int) {
		this._cachedViewport = null;
		
		GL.viewport(x, y, width, height);
	}

	inline public function beginFrame() {
		this._measureFps();
	}

	inline public function endFrame() {
		//this.flushFramebuffer();
		#if openfl
		// Depth buffer
		//this.setDepthBuffer(true);
		//this.setDepthFunctionToLessOrEqual();
		//this.setDepthWrite(true);		
		//this._activeTexturesCache = new Vector<BaseTexture>(this._maxTextureChannels);
		#end
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
		#if (purejs || js)
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

	public function bindFramebuffer(texture:WebGLTexture, faceIndex:Int = 0) {
		this._currentRenderTarget = texture;
		
		GL.bindFramebuffer(GL.FRAMEBUFFER, texture._framebuffer);
		
		if (texture.isCube) {
            GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex, texture.data, 0);
        } 
		else {
            GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.data, 0);
        }
		
		GL.viewport(0, 0, texture._width, texture._height);
		
		this.wipeCaches();
	}

	inline public function unBindFramebuffer(texture:WebGLTexture, disableGenerateMipMaps:Bool = false) {
		this._currentRenderTarget = null;
		
		if (texture.generateMipMaps && !disableGenerateMipMaps) {
			GL.bindTexture(GL.TEXTURE_2D, texture.data);
			GL.generateMipmap(GL.TEXTURE_2D);
			GL.bindTexture(GL.TEXTURE_2D, null);
		}
		
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}
	
	public function generateMipMapsForCubemap(texture:WebGLTexture) {
        if (texture.generateMipMaps) {
            GL.bindTexture(GL.TEXTURE_CUBE_MAP, texture.data);
            GL.generateMipmap(GL.TEXTURE_CUBE_MAP);
            GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
        }
    }

	inline public function flushFramebuffer() {
		GL.flush();
	}

	inline public function restoreDefaultFramebuffer() {
		this._currentRenderTarget = null;
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		
		this.setViewport(this._cachedViewport);
		
		this.wipeCaches();
	}

	// VBOs
	inline private function _resetVertexBufferBinding() {
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		this._cachedVertexBuffers = null;
	}

	inline public function createVertexBuffer(vertices:Array<Float>):WebGLBuffer {
		var vbo = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(vertices), GL.STATIC_DRAW);
		this._resetVertexBufferBinding();
		var ret = new WebGLBuffer(vbo);
		ret.references = 1;
		
		return ret;
	}

	inline public function createDynamicVertexBuffer(capacity:Int):WebGLBuffer {
		var vbo = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, vbo);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(capacity), GL.DYNAMIC_DRAW);
		this._resetVertexBufferBinding();
		var ret = new WebGLBuffer(vbo);
		ret.references = 1;
		
		return ret;
	}

	inline public function updateDynamicVertexBuffer(vertexBuffer:WebGLBuffer, vertices:Dynamic, offset:Int = 0) {
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer.buffer);
		
		if (!Std.is(vertices, Array)) {
			GL.bufferSubData(GL.ARRAY_BUFFER, offset, vertices);
		} 
		else {
			#if purejs
			GL.bufferSubData(GL.ARRAY_BUFFER, offset, new Float32Array(vertices));
			#else
			GL.bufferSubData(GL.ARRAY_BUFFER, offset, new Float32Array(cast(vertices, Array<Dynamic>)));
			#end
		}
		
		this._resetVertexBufferBinding();
	}

	inline private function _resetIndexBufferBinding() {
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		this._cachedIndexBuffer = null;
	}

	inline public function createIndexBuffer(indices:Array<Int>):WebGLBuffer {
		var vbo = GL.createBuffer();		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, vbo);
		
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
		
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, arrayBuffer, GL.STATIC_DRAW);
		this._resetIndexBufferBinding();
		var ret = new WebGLBuffer(vbo);
		ret.references = 1;
		ret.is32Bits = need32Bits;
		
		return ret;
	}

	inline public function bindBuffers(vertexBuffer:WebGLBuffer, indexBuffer:WebGLBuffer, vertexDeclaration:Array<Int>, vertexStrideSize:Int, effect:Effect) {
		if (this._cachedVertexBuffers != vertexBuffer || this._cachedEffectForVertexBuffers != effect) {
			this._cachedVertexBuffers = vertexBuffer;
			this._cachedEffectForVertexBuffers = effect;
			
			GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer.buffer);
			
			var offset:Int = 0;
			for (index in 0...vertexDeclaration.length) {
				var order = effect.getAttributeLocation(index);
				
				if (order >= 0) {
					GL.vertexAttribPointer(order, vertexDeclaration[index], GL.FLOAT, false, vertexStrideSize, offset);
				}
				offset += vertexDeclaration[index] * 4;
			}
		}
		
		if (this._cachedIndexBuffer != indexBuffer) {
			this._cachedIndexBuffer = indexBuffer;
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer.buffer);
			this._uintIndicesCurrentlySet = indexBuffer.is32Bits;
		}
	}
	
	inline public function bindMultiBuffers(vertexBuffers:Map<String, VertexBuffer>, indexBuffer:WebGLBuffer, effect:Effect) {
        if (this._cachedVertexBuffers != vertexBuffers || this._cachedEffectForVertexBuffers != effect) {
            this._cachedVertexBuffers = vertexBuffers;
            this._cachedEffectForVertexBuffers = effect;
			
            var attributes:Array<String> = effect.getAttributesNames();
			
            for (index in 0...attributes.length) {
                var order:Int = effect.getAttributeLocation(index);
				
                if (order >= 0) {
                    var vertexBuffer:VertexBuffer = vertexBuffers.get(attributes[index]);
					if (vertexBuffer == null) {
						continue;
					}
					
                    var stride:Int = vertexBuffer.getStrideSize();
                    GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer.getBuffer().buffer);					
                    GL.vertexAttribPointer(order, stride, GL.FLOAT, false, stride * 4, 0);
                }
            }
        }
		
        if (indexBuffer != null && this._cachedIndexBuffer != indexBuffer) {
            this._cachedIndexBuffer = indexBuffer;
            GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer.buffer);
			this._uintIndicesCurrentlySet = indexBuffer.is32Bits;
        }
    }

	inline public function _releaseBuffer(buffer:WebGLBuffer):Bool {
		buffer.references--;
		
		if (buffer.references == 0) {
			GL.deleteBuffer(buffer.buffer);
			return true;
		}
		
		return false;
	}

	inline public function createInstancesBuffer(capacity:Int):WebGLBuffer {
		var buffer = new WebGLBuffer(GL.createBuffer());
		
		buffer.capacity = capacity;
		
		GL.bindBuffer(GL.ARRAY_BUFFER, buffer.buffer);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(capacity), GL.DYNAMIC_DRAW);
		return buffer;
	}

	public function deleteInstancesBuffer(buffer:WebGLBuffer) {
		GL.deleteBuffer(buffer.buffer);
		buffer = null;
	}


	public function updateAndBindInstancesBuffer(instancesBuffer:WebGLBuffer, data: #if (js || html5 || purejs) Float32Array #else Array<Float> #end , offsetLocations:Array<Int>) {
		GL.bindBuffer(GL.ARRAY_BUFFER, instancesBuffer.buffer);
		
		#if (js || html5 || purejs) 
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, cast data);
		#else
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(data));
		#end
				
		for (index in 0...4) {
			var offsetLocation = offsetLocations[index];
			GL.enableVertexAttribArray(offsetLocation);
			GL.vertexAttribPointer(offsetLocation, 4, GL.FLOAT, false, 64, index * 16);
			
			this._caps.instancedArrays.vertexAttribDivisorANGLE(offsetLocation, 1);
		}
	}

	public function unBindInstancesBuffer(instancesBuffer:WebGLBuffer, offsetLocations:Array<Int>) {
		GL.bindBuffer(GL.ARRAY_BUFFER, instancesBuffer.buffer);
		for (index in 0...4) {
			var offsetLocation = offsetLocations[index];
			GL.disableVertexAttribArray(offsetLocation);
			
			this._caps.instancedArrays.vertexAttribDivisorANGLE(offsetLocation, 0);
		}
	}

	inline public function applyStates() {
		this._depthCullingState.apply();
		this._alphaState.apply();
	}

	public function draw(useTriangles:Bool, indexStart:Int, indexCount:Int, instancesCount:Int = -1) {
		// Apply states
		this.applyStates();
		
		this._drawCalls++;
		
		// Render
		var indexFormat = this._uintIndicesCurrentlySet ? GL.UNSIGNED_INT : GL.UNSIGNED_SHORT;
		var mult:Int = this._uintIndicesCurrentlySet ? 4 : 2;
		if (instancesCount != -1) {
			this._caps.instancedArrays.drawElementsInstancedANGLE(useTriangles ? GL.TRIANGLES : GL.LINES, indexCount, indexFormat, indexStart * mult, instancesCount);
			
			return;
		}
		
		GL.drawElements(useTriangles ? GL.TRIANGLES : GL.LINES, indexCount, indexFormat, indexStart * mult);		
	}

	public function drawPointClouds(verticesStart:Int, verticesCount:Int, instancesCount:Int = -1) {
		// Apply states
		this.applyStates();
		
		this._drawCalls++;
		
		if (instancesCount != -1) {
			this._caps.instancedArrays.drawArraysInstancedANGLE(GL.POINTS, verticesStart, verticesCount, instancesCount);
			
			return;
		}
		
		GL.drawArrays(GL.POINTS, verticesStart, verticesCount);
	}
	
	public function drawUnIndexed(useTriangles:Bool, verticesStart:Int, verticesCount:Int, instancesCount:Int = -1) {
        // Apply states
        this.applyStates();
		
        this._drawCalls++;
		
        if (instancesCount != -1) {
            this._caps.instancedArrays.drawArraysInstancedANGLE(useTriangles ? GL.TRIANGLES : GL.LINES, verticesStart, verticesCount, instancesCount);
			
            return;
        }
		
        GL.drawArrays(useTriangles ? GL.TRIANGLES : GL.LINES, verticesStart, verticesCount);
    }

	// Shaders
	public function _releaseEffect(effect:Effect) {
		if (this._compiledEffects.exists(effect._key)) {
			this._compiledEffects.remove(effect._key);
			if (effect.getProgram() != null) {
				GL.deleteProgram(effect.getProgram());
			}
		}
	}

	public function createEffect(baseName:Dynamic, attributesNames:Array<String>, uniformsNames:Array<String>, samplers:Array<String>, defines:String, ?fallbacks:EffectFallbacks, ?onCompiled:Effect->Void, ?onError:Effect->String->Void):Effect {
		var vertex = baseName.vertexElement != null ? baseName.vertexElement : (baseName.vertex != null ? baseName.vertex : baseName);
		var fragment = baseName.fragmentElement != null ? baseName.fragmentElement : (baseName.fragment != null ? baseName.fragment : baseName);
						
		var name = vertex + "+" + fragment + "@" + defines;
		if (this._compiledEffects.exists(name)) {
            return this._compiledEffects.get(name);
        }
		
		var effect = new Effect(baseName, attributesNames, uniformsNames, samplers, this, defines, fallbacks, onCompiled, onError);
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
		var vertexShader = compileShader(vertexCode, "vertex", defines);
		var fragmentShader = compileShader(fragmentCode, "fragment", defines);
		
		var shaderProgram = GL.createProgram();
		GL.attachShader(shaderProgram, vertexShader);
		GL.attachShader(shaderProgram, fragmentShader);
		
		GL.linkProgram(shaderProgram);
		var linked = GL.getProgramParameter(shaderProgram, GL.LINK_STATUS);
		
		if (linked == 0) {
			var error = GL.getProgramInfoLog(shaderProgram);
			if (error != "") {
				throw(error);
			}
		}
		
		GL.deleteShader(vertexShader);
		GL.deleteShader(fragmentShader);
		
		return shaderProgram;
	}

	inline public function getUniforms(shaderProgram:GLProgram, uniformsNames:Array<String>):Map<String, GLUniformLocation> {
		var results:Map<String, GLUniformLocation> = new Map();
		
		for (name in uniformsNames) {
			var uniform = GL.getUniformLocation(shaderProgram, name);
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
				results.push(GL.getAttribLocation(shaderProgram, attributesNames[index]));
            } 
			catch (e:Dynamic) {
				trace("getAttributes() -> ERROR: " + e);
                results.push(-1);
            }
        }
		
        return results;
    }

	inline public function enableEffect(effect:Effect) {
		if (effect == null || effect.getAttributesCount() == 0 || this._currentEffect == effect) {
			if (effect != null && effect.onBind != null) {
				effect.onBind(effect);
			}
			
			return;
		}
		
		this._vertexAttribArrays = this._vertexAttribArrays != null ? this._vertexAttribArrays : [];
		
		// Use program
		GL.useProgram(effect.getProgram());
		
		for (i in 0...this._vertexAttribArrays.length) {
			if (i > GL.VERTEX_ATTRIB_ARRAY_ENABLED || !this._vertexAttribArrays[i]) {
				continue;
			}
			this._vertexAttribArrays[i] = false;
			GL.disableVertexAttribArray(i);
		}
		
		var attributesCount = effect.getAttributesCount();
		for (index in 0...attributesCount) {
			// Attributes
			var order = effect.getAttributeLocation(index);
			if (order >= 0) {
				this._vertexAttribArrays[order] = true;
				GL.enableVertexAttribArray(order);
			}
		}
		
		this._currentEffect = effect;
		
		if (effect.onBind != null) {
			effect.onBind(effect);
		}	
	}

	inline public function setArray(uniform:GLUniformLocation, array:Array<Float>) {
		GL.uniform1fv(uniform, new Float32Array(array));
	}
	
	inline public function setArray2(uniform:GLUniformLocation, array:Array<Float>) {
        if (array.length % 2 == 0) {
			GL.uniform2fv(uniform, new Float32Array(array));
		}
    }

    inline public function setArray3(uniform:GLUniformLocation, array:Array<Float>) {
        if (array.length % 3 == 0) {			
			GL.uniform3fv(uniform, new Float32Array(array));
		}
    }

    inline public function setArray4(uniform:GLUniformLocation, array:Array<Float>) {
        if (array.length % 4 == 0) {			
			GL.uniform4fv(uniform, new Float32Array(array));
		}
    }

	inline public function setMatrices(uniform:GLUniformLocation, matrices: #if (js || purejs) Float32Array #else Array<Float> #end ) {
		GL.uniformMatrix4fv(uniform, false, #if (js || purejs) matrices #else new Float32Array(matrices) #end);
	}

	inline public function setMatrix(uniform:GLUniformLocation, matrix:Matrix) {	
		GL.uniformMatrix4fv(uniform, false, #if (js || purejs) matrix.m #else new Float32Array(matrix.m) #end );
	}
	
	inline public function setMatrix3x3(uniform:GLUniformLocation, matrix:Float32Array) {
		GL.uniformMatrix3fv(uniform, false, matrix);
	}

	inline public function setMatrix2x2(uniform:GLUniformLocation, matrix:Float32Array) {
		GL.uniformMatrix2fv(uniform, false, matrix);
	}

	inline public function setFloat(uniform:GLUniformLocation, value:Float) {
		GL.uniform1f(uniform, value);
	}

	inline public function setFloat2(uniform:GLUniformLocation, x:Float, y:Float) {
		GL.uniform2f(uniform, x, y);
	}

	inline public function setFloat3(uniform:GLUniformLocation, x:Float, y:Float, z:Float) {
		GL.uniform3f(uniform, x, y, z);
	}

	inline public function setBool(uniform:GLUniformLocation, bool:Bool) {
		GL.uniform1i(uniform, bool ? 1 : 0);
	}

	public function setFloat4(uniform:GLUniformLocation, x:Float, y:Float, z:Float, w:Float) {
		GL.uniform4f(uniform, x, y, z, w);
	}

	inline public function setColor3(uniform:GLUniformLocation, color3:Color3) {
		GL.uniform3f(uniform, color3.r, color3.g, color3.b);
	}

	inline public function setColor4(uniform:GLUniformLocation, color3:Color3, alpha:Float) {
		GL.uniform4f(uniform, color3.r, color3.g, color3.b, alpha);
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
		GL.colorMask(enable, enable, enable, enable);
	}

	inline public function setAlphaMode(mode:Int) {
		if (this._alphaMode == mode) {
            return;
        }
		
		switch (mode) {
			case Engine.ALPHA_DISABLE:
				this.setDepthWrite(true);
				this._alphaState.alphaBlend = false;
				
			case Engine.ALPHA_COMBINE:
				this.setDepthWrite(false);
				this._alphaState.setAlphaBlendFunctionParameters(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_ONEONE:
				this.setDepthWrite(false);
				this._alphaState.setAlphaBlendFunctionParameters(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_ADD:
				this.setDepthWrite(false);
				this._alphaState.setAlphaBlendFunctionParameters(GL.SRC_ALPHA, GL.ONE, GL.ZERO, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_SUBTRACT:
				this.setDepthWrite(false);
				this._alphaState.setAlphaBlendFunctionParameters(GL.ZERO, GL.ONE_MINUS_SRC_COLOR, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_MULTIPLY:
				this.setDepthWrite(false);
				this._alphaState.setAlphaBlendFunctionParameters(GL.DST_COLOR, GL.ZERO, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
			case Engine.ALPHA_MAXIMIZED:
				this.setDepthWrite(false);
				this._alphaState.setAlphaBlendFunctionParameters(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_COLOR, GL.ONE, GL.ONE);
				this._alphaState.alphaBlend = true;
				
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
		
		this._depthCullingState.reset();
		this._alphaState.reset();
		
		this._cachedVertexBuffers = null;
		this._cachedIndexBuffer = null;
		this._cachedEffectForVertexBuffers = null;
	}

	inline public function setSamplingMode(texture:WebGLTexture, samplingMode:Int) {
		GL.bindTexture(GL.TEXTURE_2D, texture.data);
		
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
		
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, magFilter);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, minFilter);
		
		GL.bindTexture(GL.TEXTURE_2D, null);
		
		texture.samplingMode = samplingMode;
	}
	
	public function createTexture(url:String, noMipmap:Bool, invertY:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, onLoad:Void->Void = null, onError:Void->Void = null, buffer:Dynamic = null):WebGLTexture {
		
		var texture = new WebGLTexture(url, GL.createTexture());
		
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
					GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, potWidth, potHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, img.data);
					
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
	
	public function createRawCubeTexture(url:String, scene:Scene, size:Int, format:Int, type:Int, noMipmap:Bool = false, callback:ArrayBuffer->Array<ArrayBufferView>):WebGLTexture {
		var texture = new WebGLTexture("", GL.createTexture());
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
			
			GL.bindTexture(GL.TEXTURE_CUBE_MAP, texture.data);
			GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 0);
			
			for (index in 0...facesIndex.length) {
				var faceData = rgbeDataArrays[index];
				GL.texImage2D(facesIndex[index], 0, internalFormat, width, height, 0, internalFormat, textureType, faceData);
			}
			
			if (!noMipmap && isPot) {
				GL.generateMipmap(GL.TEXTURE_CUBE_MAP);
			}
			else {
				noMipmap = true;
			}
			
			if (textureType == GL.FLOAT && !this._caps.textureFloatLinearFiltering) {
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			}
			else {
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, noMipmap ? GL.LINEAR : GL.LINEAR_MIPMAP_LINEAR);
			}
			
			GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
			
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
		
		var texture = new WebGLTexture("", GL.createTexture());
		texture._baseWidth = width;
		texture._baseHeight = height;
		texture._width = width;
		texture._height = height;
		texture.references = 1;
		
		this.updateRawTexture(texture, data, format, invertY, compression);
		GL.bindTexture(GL.TEXTURE_2D, texture.data);
		
		// Filters
		var filters = getSamplingParameters(samplingMode, generateMipMaps);
		
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
		GL.bindTexture(GL.TEXTURE_2D, null);
		
		texture.samplingMode = samplingMode;
		
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
		
		GL.bindTexture(GL.TEXTURE_2D, texture.data);
		//GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);           
		
		if (compression != "") {
            GL.compressedTexImage2D(GL.TEXTURE_2D, 0, Reflect.getProperty(this.getCaps().s3tc, compression), texture._width, texture._height, 0, data);
        } 
		else {
            GL.texImage2D(GL.TEXTURE_2D, 0, internalFormat, texture._width, texture._height, 0, internalFormat, GL.UNSIGNED_BYTE, data);
        }
		
		if (texture.generateMipMaps) {
			GL.generateMipmap(GL.TEXTURE_2D);
		}
		GL.bindTexture(GL.TEXTURE_2D, null);
		this.resetTextureCache();
		texture.isReady = true;
	}

	public function createDynamicTexture(width:Int, height:Int, generateMipMaps:Bool, samplingMode:Int, forceExponantOfTwo:Bool = true):WebGLTexture {
		var texture = new WebGLTexture("", GL.createTexture());
		
        if(forceExponantOfTwo) {
		    width = com.babylonhx.math.Tools.GetExponentOfTwo(width, this._caps.maxTextureSize);
		    height = com.babylonhx.math.Tools.GetExponentOfTwo(height, this._caps.maxTextureSize);
        }
		
		this.resetTextureCache();
		texture._baseWidth = width;
		texture._baseHeight = height;
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
	
	inline public function updateDynamicTexture(texture:WebGLTexture, canvas:Image, invertY:Bool) {
		GL.bindTexture(GL.TEXTURE_2D, texture.data);
		//GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY ? 1 : 0);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, canvas.width, canvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, cast canvas.data);
		if (texture.generateMipMaps) {
			GL.generateMipmap(GL.TEXTURE_2D);
		}
		GL.bindTexture(GL.TEXTURE_2D, null);
		this.resetTextureCache();
		texture.isReady = true;
	}
	
	inline public function updateTextureSamplingMode(samplingMode:Int, texture:WebGLTexture) {
		var filters = getSamplingParameters(samplingMode, texture.generateMipMaps);
		
		if (texture.isCube) {
			GL.bindTexture(GL.TEXTURE_CUBE_MAP, texture.data);
			
			GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, filters.mag);
            GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, filters.min);
            GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
		}
		else {
			GL.bindTexture(GL.TEXTURE_2D, texture.data);
			
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
			GL.bindTexture(GL.TEXTURE_2D, null);
		}
	}

	public function updateVideoTexture(texture:WebGLTexture, video:Dynamic, invertY:Bool) {
        #if (html5 || js || web || purejs)
		
        if (texture._isDisabled) {
            return;
		}
		
        GL.bindTexture(GL.TEXTURE_2D, texture.data);
        GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY ? 0 : 1); // Video are upside down by default
		
        try {
            // Testing video texture support
            if(_videoTextureSupported == null) {
                untyped GL.context.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, video);
                if(GL.getError() != 0) {
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
				
                untyped GL.context.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, texture._workingCanvas);
            }
            else {
                untyped GL.context.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, cast(video, js.html.VideoElement));
            }
			
            if(texture.generateMipMaps) {
                GL.generateMipmap(GL.TEXTURE_2D);
            }
			
            GL.bindTexture(GL.TEXTURE_2D, null);
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
		var type = Engine.TEXTURETYPE_UNSIGNED_INT;
		var samplingMode = Texture.TRILINEAR_SAMPLINGMODE;
		if (options != null) {
            generateMipMaps = options.generateMipMaps != null ? options.generateMipMaps : options;
            generateDepthBuffer = options.generateDepthBuffer != null ? options.generateDepthBuffer : true;
			type = options.type == null ? type : options.type;
            if (options.samplingMode != null) {
                samplingMode = options.samplingMode;
            }
			if (type == Engine.TEXTURETYPE_FLOAT) {
				// if floating point (gl.FLOAT) then force to NEAREST_SAMPLINGMODE
				samplingMode = Texture.NEAREST_SAMPLINGMODE;
			}
        }
		
		var texture = new WebGLTexture("", GL.createTexture());
		GL.bindTexture(GL.TEXTURE_2D, texture.data);
		
		var width:Int = size.width != null ? size.width : size;
        var height:Int = size.height != null ? size.height : size;
		
		var filters = getSamplingParameters(samplingMode, generateMipMaps);
		
		if (type == Engine.TEXTURETYPE_FLOAT && !this._caps.textureFloat) {
			type = Engine.TEXTURETYPE_UNSIGNED_INT;
			trace("Float textures are not supported. Render target forced to TEXTURETYPE_UNSIGNED_BYTE type");
		}
		
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		#if (snow && cpp)
		var arrBuffEmpty:ArrayBufferView = null;
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, getWebGLTextureType(type), arrBuffEmpty);
		#else
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, getWebGLTextureType(type), null);
		#end
		
		var depthBuffer:GLRenderbuffer = null;
		// Create the depth buffer
		if (generateDepthBuffer) {
			depthBuffer = GL.createRenderbuffer();
			GL.bindRenderbuffer(GL.RENDERBUFFER, depthBuffer);
			GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);
		}
		// Create the framebuffer
		var framebuffer = GL.createFramebuffer();
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		if (generateDepthBuffer) {
			GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depthBuffer);
		}
		
		// Unbind
		GL.bindTexture(GL.TEXTURE_2D, null);
		GL.bindRenderbuffer(GL.RENDERBUFFER, null);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		
		texture._framebuffer = framebuffer;
		if (generateDepthBuffer) {
			texture._depthBuffer = depthBuffer;
		}
		texture._width = width;
		texture._height = height;
		texture.isReady = true;
		texture.generateMipMaps = generateMipMaps;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		this.resetTextureCache();
		
		this._loadedTexturesCache.push(texture);
		
		return texture;
	}
	
	public function createRenderTargetCubeTexture(size:Dynamic, ?options:Dynamic):WebGLTexture {
		var texture = new WebGLTexture("", GL.createTexture());
		
		var generateMipMaps:Bool = true;
		var samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE;
		if (options != null) {
			generateMipMaps = options.generateMipMaps == null ? options : options.generateMipMaps;
			if (options.samplingMode != null) {
				samplingMode = options.samplingMode;
			}
		}
		
		texture.isCube = true;
		texture.references = 1;
		texture.generateMipMaps = generateMipMaps;
		texture.references = 1;
		texture.samplingMode = samplingMode;
		
		var filters = getSamplingParameters(samplingMode, generateMipMaps);
		
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, texture.data);
		
		for (face in 0...6) {
			#if (snow && cpp)
			var arrBuffEmtpy:ArrayBufferView = null;
			GL.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + face, 0, GL.RGBA, size.width, size.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, arrBuffEmtpy);
			#else
			GL.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + face, 0, GL.RGBA, size.width, size.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
			#end
		}
		
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, filters.mag);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, filters.min);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		
		// Create the depth buffer
		var depthBuffer = GL.createRenderbuffer();
		GL.bindRenderbuffer(GL.RENDERBUFFER, depthBuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, size.width, size.height);
		
		// Create the framebuffer
		var framebuffer = GL.createFramebuffer();
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depthBuffer);
		
		// Mipmaps
        if (texture.generateMipMaps) {
            GL.bindTexture(GL.TEXTURE_CUBE_MAP, texture.data);
            GL.generateMipmap(GL.TEXTURE_CUBE_MAP);
        }
		
		// Unbind
		GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
		GL.bindRenderbuffer(GL.RENDERBUFFER, null);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		
		texture._framebuffer = framebuffer;
		texture._depthBuffer = depthBuffer;
		
		this.resetTextureCache();
		
		texture._width = size.width;
		texture._height = size.height;
		texture.isReady = true;
		
		return texture;
	}

	public function createCubeTexture(rootUrl:String, scene:Scene, files:Array<String> = null, noMipmap:Bool = false):WebGLTexture {
		var texture = new WebGLTexture(rootUrl, GL.createTexture());
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
				GL.TEXTURE_CUBE_MAP_POSITIVE_X, GL.TEXTURE_CUBE_MAP_POSITIVE_Y, GL.TEXTURE_CUBE_MAP_POSITIVE_Z,
				GL.TEXTURE_CUBE_MAP_NEGATIVE_X, GL.TEXTURE_CUBE_MAP_NEGATIVE_Y, GL.TEXTURE_CUBE_MAP_NEGATIVE_Z
			];
			
			var imgs:Array<Image> = [];
			
			function _setTex(img:Image, index:Int) {					
				/*var potWidth = Tools.GetExponantOfTwo(img.image.width, this._caps.maxTextureSize);
				var potHeight = Tools.GetExponantOfTwo(img.image.height, this._caps.maxTextureSize);
				var isPot = (img.image.width == potWidth && img.image.height == potHeight);*/
				this._workingCanvas = img;
					
				GL.texImage2D(faces[index], 0, GL.RGBA, this._workingCanvas.width, this._workingCanvas.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, img.data);
			}
			
			function generate() {
				var width = com.babylonhx.math.Tools.GetExponentOfTwo(imgs[0].width, this._caps.maxCubemapTextureSize);
				var height = width;
				
				GL.bindTexture(GL.TEXTURE_CUBE_MAP, texture.data);
				
				/*#if js
				GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 0);
				#end*/
					
				for (index in 0...faces.length) {
					_setTex(imgs[index], index);
				}
				
				if (!noMipmap) {
					GL.generateMipmap(GL.TEXTURE_CUBE_MAP);
				}
				
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, noMipmap ? GL.LINEAR :GL.LINEAR_MIPMAP_LINEAR);
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
				
				GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
				
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
			GL.deleteFramebuffer(texture._framebuffer);
		}
		
		if (texture._depthBuffer != null) {
			GL.deleteRenderbuffer(texture._depthBuffer);
		}
		
		GL.deleteTexture(texture.data);
		
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
			GL.activeTexture(getGLTexture(channel));
			GL.bindTexture(GL.TEXTURE_2D, null);
			GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
			this._activeTexturesCache[channel] = null;
		}
	}
	
	inline function getGLTexture(channel:Int):Int {
		return GL.TEXTURE0 + channel;
	}

	inline public function bindSamplers(effect:Effect) {
		GL.useProgram(effect.getProgram());
		var samplers = effect.getSamplers();
		for (index in 0...samplers.length) {
			var uniform = effect.getUniform(samplers[index]);
			GL.uniform1i(uniform, index);
		}
		this._currentEffect = null;
	}

	inline public function _bindTexture(channel:Int, texture:WebGLTexture) {
		GL.activeTexture(getGLTexture(channel));
		GL.bindTexture(GL.TEXTURE_2D, texture.data);
		
		this._activeTexturesCache[channel] = null;
	}

	inline public function setTextureFromPostProcess(channel:Int, postProcess:PostProcess) {
		if (postProcess._textures.length > 0) {
			this._bindTexture(channel, postProcess._textures.data[postProcess._currentRenderTextureInd]);
		}
	}

	public function setTexture(channel:Int, texture:BaseTexture) {
		if (channel < 0) {
			return;
		}
		// Not ready?
		if (texture == null || !texture.isReady()) {
			if (this._activeTexturesCache[channel] != null) {
				GL.activeTexture(getGLTexture(channel));
				GL.bindTexture(GL.TEXTURE_2D, null);
				GL.bindTexture(GL.TEXTURE_CUBE_MAP, null);
				this._activeTexturesCache[channel] = null;
			}
			return;
		}
		
		// Video
        var alreadyActivated = false;
		if (Std.is(texture, VideoTexture)) {
            GL.activeTexture(getGLTexture(channel));
            alreadyActivated = true;
            cast(texture, VideoTexture).update();
		} 
		else if (texture.delayLoadState == Engine.DELAYLOADSTATE_NOTLOADED) { // Delay loading
			texture.delayLoad();
			return;
		}
		
		if (this._activeTexturesCache[channel] == texture) {
			return;
		}
		this._activeTexturesCache[channel] = texture;
		
		var internalTexture = texture.getInternalTexture();

        if(!alreadyActivated) {
            GL.activeTexture(getGLTexture(channel));
        }

		if (internalTexture.isCube) {
			GL.bindTexture(GL.TEXTURE_CUBE_MAP, internalTexture.data);
			
			if (internalTexture._cachedCoordinatesMode != texture.coordinatesMode) {
				internalTexture._cachedCoordinatesMode = texture.coordinatesMode;
				// CUBIC_MODE and SKYBOX_MODE both require CLAMP_TO_EDGE.  All other modes use REPEAT.
				var textureWrapMode = (texture.coordinatesMode != Texture.CUBIC_MODE && texture.coordinatesMode != Texture.SKYBOX_MODE) ? GL.REPEAT : GL.CLAMP_TO_EDGE;
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, textureWrapMode);
				GL.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, textureWrapMode);
			}
			
			this._setAnisotropicLevel(GL.TEXTURE_CUBE_MAP, texture);
		} 
		else {
			GL.bindTexture(GL.TEXTURE_2D, internalTexture.data);
			
			if (internalTexture._cachedWrapU != texture.wrapU) {
				internalTexture._cachedWrapU = texture.wrapU;
				
				switch (texture.wrapU) {
					case Texture.WRAP_ADDRESSMODE:
						GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.MIRRORED_REPEAT);
						
				}
			}
			
			if (internalTexture._cachedWrapV != texture.wrapV) {
				internalTexture._cachedWrapV = texture.wrapV;
				switch (texture.wrapV) {
					case Texture.WRAP_ADDRESSMODE:
						GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
						
					case Texture.CLAMP_ADDRESSMODE:
						GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
						
					case Texture.MIRROR_ADDRESSMODE:
						GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.MIRRORED_REPEAT);
						
				}
			}
			
			this._setAnisotropicLevel(GL.TEXTURE_2D, texture);
		}
	}

	public function _setAnisotropicLevel(key:Int, texture:BaseTexture) {
		var anisotropicFilterExtension = this._caps.textureAnisotropicFilterExtension;
		
		if (anisotropicFilterExtension != null && texture._cachedAnisotropicFilteringLevel != texture.anisotropicFilteringLevel) {
			GL.texParameterf(key, anisotropicFilterExtension.TEXTURE_MAX_ANISOTROPY_EXT, Math.min(texture.anisotropicFilteringLevel, this._caps.maxAnisotropy));
			texture._cachedAnisotropicFilteringLevel = texture.anisotropicFilteringLevel;
		}
	}

	inline public function readPixels(x:Int, y:Int, width:Int, height:Int): #if (js || purejs) UInt8Array #else Array<Int> #end {
		var data = #if (js || purejs) new UInt8Array(height * width * 4) #else [] #end ;
		GL.readPixels(x, y, width, height, GL.RGBA, GL.UNSIGNED_BYTE, cast data);
		
		return data;
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
			GL.deleteProgram(this._compiledEffects[name]._program);
		}
	}

	// Statics	
	public static function compileShader(source:String, type:String, defines:String):GLShader {
        var shader:GLShader = GL.createShader(type == "vertex" ? GL.VERTEX_SHADER : GL.FRAGMENT_SHADER);
				
        GL.shaderSource(shader, (defines != null ? defines + "\n" : "") + source);
        GL.compileShader(shader);
		
        if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0) {
            throw(GL.getShaderInfoLog(shader));
        }
		
        return shader;
    }
	
	inline public static function getWebGLTextureType(type:Int):Int {
		return (type == Engine.TEXTURETYPE_FLOAT ? GL.FLOAT : GL.UNSIGNED_BYTE);
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
				
        GL.bindTexture(GL.TEXTURE_2D, texture.data);
		/*#if js
        GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, invertY == null ? 1 : (invertY ? 1 : 0));
		#end*/
		
		texture._baseWidth = width;
        texture._baseHeight = height;
        texture._width = potWidth;
        texture._height = potHeight;
        texture.isReady = true;
		
        processFunction(Std.int(potWidth), Std.int(potHeight));
		
        var filters = getSamplingParameters(samplingMode, !noMipmap);
		
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters.mag);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters.min);
		
        if (!noMipmap && !isCompressed) {
            GL.generateMipmap(GL.TEXTURE_2D);
        }
		
        GL.bindTexture(GL.TEXTURE_2D, null);
		
        resetTextureCache();        		
        scene._removePendingData(texture);
		
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
