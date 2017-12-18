package com.babylonhx.engine;

import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.InternalTexture;
import com.babylonhx.materials.textures.RenderTargetCreationOptions;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Viewport;
import lime.utils.UInt32Array;

import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.WebGL2Context;
import lime.utils.ArrayBuffer;
import lime.utils.Float32Array;
import lime.utils.Int32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The null engine class provides support for headless version of babylon.js.
 * This can be used in server side scenario or for testing purposes
 */
class NullEngine extends Engine {
	
	private var _options:NullEngineOptions;
	

	public function new(?options:NullEngineOptions) {
		super(null, null);
		
		this._options = options != null ? options : new NullEngineOptions();
		
		// Init caps
		// We consider we are on a webgl1 capable device
		
		this._caps = new EngineCapabilities();
		this._caps.maxTexturesImageUnits = 16;
		this._caps.maxVertexTextureImageUnits = 16;
		this._caps.maxTextureSize = 512;
		this._caps.maxCubemapTextureSize = 512;
		this._caps.maxRenderTextureSize = 512;
		this._caps.maxVertexAttribs = 16;
		this._caps.maxVaryingVectors = 16;
		this._caps.maxFragmentUniformVectors = 16;
		this._caps.maxVertexUniformVectors = 16;
		
		// Extensions
		this._caps.standardDerivatives = false;
		
		this._caps.astc = null;
		this._caps.s3tc = null;
		this._caps.pvrtc = null;
		this._caps.etc1 = null;
		this._caps.etc2 = null;
		
		this._caps.textureAnisotropicFilterExtension = null;
		this._caps.maxAnisotropy = 0;
		this._caps.uintIndices = false;
		this._caps.fragmentDepthSupported = false;
		this._caps.highPrecisionShaderSupported = true;
		
		this._caps.colorBufferFloat = false;
		this._caps.textureFloat = false;
		this._caps.textureFloatLinearFiltering = false;
		this._caps.textureFloatRender = false;
		
		this._caps.textureHalfFloat = false;
		this._caps.textureHalfFloatLinearFiltering = false;
		this._caps.textureHalfFloatRender = false;
		
		this._caps.textureLOD = false;
		this._caps.drawBuffersExtension = false;
		
		this._caps.depthTextureExtension = false;
		this._caps.vertexArrayObject = false;
		this._caps.instancedArrays = false;
	}
	
	public function createVertexBuffer(vertices:Float32Array):WebGLBuffer {
		return new WebGLBuffer(null);
	}

	public function createIndexBuffer(indices:Int32Array):WebGLBuffer {
		return new WebGLBuffer(null);
	}

	public function clear(color:Color4, backBuffer:Bool, depth:Bool, stencil:Bool = false) {
	}

	public function getRenderWidth(useScreen:Bool = false):Int {
		if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget.width;
		}
		
		return this._options.renderWidth;
	}

	public function getRenderHeight(useScreen:Bool = false):Int {
		if (!useScreen && this._currentRenderTarget != null) {
			return this._currentRenderTarget.height;
		}
		
		return this._options.renderHeight;
	}

	public function setViewport(viewport:Viewport, requiredWidth:Int = -1, requiredHeight:Int = -1) {
		this._cachedViewport = viewport;
	}

	public function createShaderProgram(vertexCode:String, fragmentCode:String, defines:String, ?context:WebGL2Context):GLProgram {
		return {};
	}

	public function getUniforms(shaderProgram:GLProgram, uniformsNames:Array<String>):Array<GLUniformLocation> {
		return [];
	}

	public function getAttributes(shaderProgram:GLProgram, attributesNames:Array<String>):Array<Int> {
		return [];
	}

	public function bindSamplers(effect:Effect) {
		this._currentEffect = null;
	}

	public function enableEffect(effect:Effect) {
		this._currentEffect = effect;
		
		if (effect.onBind != null) {
			effect.onBind(effect);
		}
		effect.onBindObservable.notifyObservers(effect);
	}   
	
	public function setState(culling:Bool, zOffset:Int = 0, force:Bool = false, reverseSide:Bool = false) {
	}        
	
	public function setIntArray(uniform:GLUniformLocation, array:Int32Array) {
	}

	public setIntArray2(uniform:GLUniformLocation, array:Int32Array) {
	}

	public setIntArray3(uniform:GLUniformLocation, array:Int32Array) {
	}

	public setIntArray4(uniform:GLUniformLocation, array:Int32Array) {
	}

	public setFloatArray(uniform:GLUniformLocation, array:Float32Array) {
	}

	public setFloatArray2(uniform:GLUniformLocation, array:Float32Array) {
	}

	public setFloatArray3(uniform:GLUniformLocation, array:Float32Array) {
	}

	public setFloatArray4(uniform:GLUniformLocation, array:Float32Array) {
	}

	public setArray(uniform:GLUniformLocation, array:Array<Float>) {
	}

	public setArray2(uniform:GLUniformLocation, array:Array<Float>) {
	}

	public setArray3(uniform:GLUniformLocation, array:Array<Float>) {
	}

	public setArray4(uniform:GLUniformLocation, array:Array<Float>) {
	}

	public setMatrices(uniform:GLUniformLocation, matrices:Float32Array) {
	}

	public setMatrix(uniform:GLUniformLocation, matrix:Matrix) {
	}

	public setMatrix3x3(uniform:GLUniformLocation, matrix:Float32Array) {
	}

	public setMatrix2x2(uniform:GLUniformLocation, matrix:Float32Array) {
	}

	public setFloat(uniform:GLUniformLocation, value:Float) {
	}

	public setFloat2(uniform:GLUniformLocation, x:Float, y:Float) {
	}

	public setFloat3(uniform:GLUniformLocation, x:Float, y:Float, z:Float) {
	}

	public setBool(uniform:GLUniformLocation, bool:Bool) {
	}

	public setFloat4(uniform:GLUniformLocation, x:Float, y:Float, z:Float, w:Float) {
	}

	public setColor3(uniform:GLUniformLocation, color3:Color3) {
	}

	public setColor4(uniform:GLUniformLocation, color3:Color3, alpha:Float) {
	}

	public setAlphaMode(mode:Int, noDepthWriteChange:Bool = false) {
		if (this._alphaMode == mode) {
			return;
		}
		
		this._alphaState.alphaBlend = (mode != Engine.ALPHA_DISABLE);
		
		if (!noDepthWriteChange) {
			this.setDepthWrite(mode == Engine.ALPHA_DISABLE);
		}
		this._alphaMode = mode;
	}        

	public function bindBuffers(vertexBuffers:Map<String, VertexBuffer>, indexBuffer:WebGLBuffer, effect:Effect) {
	}
	
	public function wipeCaches(bruteForce:Bool = false) {
		if (this.preventCacheWipeBetweenFrames) {
			return;
		}
		this.resetTextureCache();
		this._currentEffect = null;
		
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
	}

	public draw(useTriangles:Bool, indexStart:Int, indexCount:Int, instancesCount:Int = 0) {
	}

	public function _createTexture():GLTexture {
		return null;
	}

	public function createTexture(urlArg:String, noMipmap:Bool, invertY:Bool, scene:Scene, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, onLoad:Void->Void = null, onError:Void->Void = null, buffer:ArrayBuffer = null, ?fallBack:InternalTexture, ?format:Int): InternalTexture {
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_URL);
		var url = urlArg;
		
		texture.url = url;
		texture.generateMipMaps = !noMipmap;
		texture.samplingMode = samplingMode;
		texture.invertY = invertY;
		texture.baseWidth = this._options.textureSize;
		texture.baseHeight = this._options.textureSize;
		texture.width = this._options.textureSize;
		texture.height = this._options.textureSize;            
		texture.format = format;
		
		texture.isReady = true;
		
		if (onLoad != null) {
			onLoad();
		}
		
		return texture;
	}
	
	public function createRenderTargetTexture(size:Dynamic, options:Dynamic):InternalTexture {
		var fullOptions = new RenderTargetCreationOptions();
		
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
		var texture = new InternalTexture(this, InternalTexture.DATASOURCE_RENDERTARGET);
		
		var width = size.width != null ? size.width : size;
		var height = size.height != null ? size.height : size;
		
		texture._depthStencilBuffer = null; // {}
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
		return texture;
	}     
	
	public function updateTextureSamplingMode(samplingMode:Int, texture:InternalTexture) {
		texture.samplingMode = samplingMode;
	}      
	
	public function bindFramebuffer(texture:InternalTexture, ?faceIndex:Int, ?requiredWidth:Int, ?requiredHeight:Int, forceFullscreenViewport:Bool = false) {
		if (this._currentRenderTarget != null) {
			this.unBindFramebuffer(this._currentRenderTarget);
		}
		this._currentRenderTarget = texture;
		this._currentFramebuffer = texture._MSAAFramebuffer != null ? texture._MSAAFramebuffer : texture._framebuffer;
		if (this._cachedViewport != null && !forceFullscreenViewport) {
			this.setViewport(this._cachedViewport, requiredWidth, requiredHeight);
		} 
	}

	public function unBindFramebuffer(texture:InternalTexture, disableGenerateMipMaps:Bool = false, ?onBeforeUnbind:Void->Void) {
		this._currentRenderTarget = null;
		
		if (onBeforeUnbind != null) {
			if (texture._MSAAFramebuffer != null) {
				this._currentFramebuffer = texture._framebuffer;
			}
			onBeforeUnbind();
		}
		this._currentFramebuffer = null;
	}

	public function createDynamicVertexBuffer(vertices:Float32Array):WebGLBuffer {
		/*var vbo = {
			capacity: 1,
			references: 1,                
			is32Bits: false
		}
		
		return vbo;*/
		return null;
	}

	public function updateDynamicIndexBuffer(indexBuffer:WebGLBuffer, indices:UInt32Array, offset:Int = 0) {
	}

	public function updateDynamicVertexBuffer(vertexBuffer:WebGLBuffer, vertices:Float32Array, offset:Int = 0, count:Int = -1) {
	}        

	public function _bindTextureDirectly(target:Int, texture:InternalTexture) {
		if (this._boundTexturesCache[this._activeChannel] != texture) {
			this._boundTexturesCache[this._activeChannel] = texture;
		}
	}

	public function _bindTexture(channel:Int, texture:InternalTexture) {
		if (channel < 0) {
			return;
		}
		
		this._bindTextureDirectly(0, texture);
	}

	public function _releaseBuffer(buffer:WebGLBuffer):Bool {
		buffer.references--;
		
		if (buffer.references == 0) {
			return true;
		}
		
		return false;
	}
	
}
