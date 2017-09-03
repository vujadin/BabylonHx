package com.babylonhx.materials.textures;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MultiRenderTarget extends RenderTargetTexture {

	private var _internalTextures:Array<InternalTexture>;
	private var _textures:Array<Texture>;
	private var _count:Int;

	public var isSupported(get, never):Bool;
	private function get_isSupported():Bool {
		var engine = this.getScene().getEngine();
		return engine.webGLVersion > 1 || engine.getCaps().drawBuffersExtension;
	}

	private var _multiRenderTargetOptions:IMultiRenderTargetOptions;

	public var textures(get, never):Array<Texture>;
	private function get_textures():Array<Texture> {
		return this._textures;
	}

	public var depthTexture(get, never):Texture;
	private function get_depthTexture():Texture {
		return this._textures[this._textures.length - 1];
	}

	
	public function new(name:String, size:Dynamic, count:Int, scene:Scene, ?options:Dynamic) {
		options = options != null ? options : { };
		
		var generateMipMaps = options.generateMipMaps != null ? options.generateMipMaps : false;
		var generateDepthTexture = options.generateDepthTexture != null ? options.generateDepthTexture : false;
		var doNotChangeAspectRatio = options.doNotChangeAspectRatio == null ? true : options.doNotChangeAspectRatio;
		
		super(name, size, scene, generateMipMaps, doNotChangeAspectRatio);
		
		if (!this.isSupported) {
			this.dispose();
			return;
		}
		
		var types:Array<Int> = [];
		var samplingModes:Array<Int> = [];
		
		for (i in 0...count) {
			if (options.types != null && options.types[i] != null) {
				types.push(options.types[i]);
			} 
			else {
				types.push(Engine.TEXTURETYPE_FLOAT);
			}
			
			if (options.samplingModes != null && options.samplingModes[i] != null) {
				samplingModes.push(options.samplingModes[i]);
			} 
			else {
				samplingModes.push(Texture.BILINEAR_SAMPLINGMODE);
			}
		}
		
		var generateDepthBuffer = options.generateDepthBuffer == null ? true : options.generateDepthBuffer;
		var generateStencilBuffer = options.generateStencilBuffer == null ? false : options.generateStencilBuffer;
		
		this._count = count;
		this._size = size;
		this._multiRenderTargetOptions = new IMultiRenderTargetOptions();
		this._multiRenderTargetOptions.samplingModes = samplingModes;
		this._multiRenderTargetOptions.generateMipMaps = generateMipMaps;
		this._multiRenderTargetOptions.generateDepthBuffer = generateDepthBuffer;
		this._multiRenderTargetOptions.generateStencilBuffer = generateStencilBuffer;
		this._multiRenderTargetOptions.generateDepthTexture = generateDepthTexture;
		this._multiRenderTargetOptions.types = types;
		this._multiRenderTargetOptions.textureCount = count;
		
		this._createInternalTextures();
		this._createTextures();
	}
	
	override public function _rebuild() {
		this.releaseInternalTextures();
		this._createInternalTextures();
		
		for (i in 0...this._internalTextures.length) {
			var texture = this._textures[i];
			texture._texture = this._internalTextures[i];
		}
		
		// Keeps references to frame buffer and stencil/depth buffer
		this._texture = this._internalTextures[0];
	}

	private function _createInternalTextures() {
		this._internalTextures = this.getScene().getEngine().createMultipleRenderTarget(this._size ,this._multiRenderTargetOptions);
	}
	
	private function _createTextures() {
		this._textures = [];
		for (i in 0...this._internalTextures.length) {
			var texture = new Texture(null, this.getScene());
			texture._texture = this._internalTextures[i];
			this._textures.push(texture);
		}
		
		// Keeps references to frame buffer and stencil/depth buffer
		this._texture = this._internalTextures[0];
	}

	override private function set_samples(value:Int):Int {
		if (this._samples == value) {
			return value;
		}
		
		for (i in 0...this._internalTextures.length) {
			this._samples = this.getScene().getEngine().updateRenderTargetTextureSampleCount(this._internalTextures[i], value);
		}
		return value;
	}

	override public function resize(size:Dynamic) {
		this.releaseInternalTextures();
		this._internalTextures = this.getScene().getEngine().createMultipleRenderTarget(size, this._multiRenderTargetOptions);
		this._createInternalTextures();
	}

	override public function dispose() {
		this.releaseInternalTextures();
		
		super.dispose();
	}

	public function releaseInternalTextures() {
		if (this._internalTextures == null) {
			return;
		}
		
		var i = this._internalTextures.length - 1;
		while (i >= 0) {
			if (this._internalTextures[i] != null) {
				this._internalTextures[i].dispose();
				this._internalTextures.splice(i, 1);
			}
			--i;
		}
	}
	
}
