package com.babylonhx.utils.engineCapabilities.js;

import com.babylonhx.utils.GL;

@:expose('BABYLON.EngineCapabilities') class EngineCapabilities {
	
	public var maxTexturesImageUnits:Int;
	public var maxTextureSize:Int;
	public var maxCubemapTextureSize:Int;
	public var maxRenderTextureSize:Null<Int>;
	public var standardDerivatives:Null<Bool>;
	public var s3tc:Dynamic;
	public var textureFloat:Null<Bool>;
	public var textureAnisotropicFilterExtension:Dynamic;
	public var highPrecisionShaderSupported:Bool;
	public var maxAnisotropy:Int;
	public var instancedArrays:Dynamic;
	public var uintIndices:Null<Bool>;
	
	public function new (supportedExtensions:Array<String>) {
		this.maxTexturesImageUnits = GL.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
		this.maxTextureSize = GL.getParameter(GL.MAX_TEXTURE_SIZE);
		this.maxCubemapTextureSize = GL.getParameter(GL.MAX_CUBE_MAP_TEXTURE_SIZE);
		this.maxRenderTextureSize = GL.getParameter(GL.MAX_RENDERBUFFER_SIZE);
						
		// Extensions
		try {
			this.standardDerivatives = (GL.getExtension('OES_standard_derivatives') != null);
			this.s3tc = GL.getExtension('WEBGL_compressed_texture_s3tc');
			this.textureFloat = (GL.getExtension('OES_texture_float') != null);
			this.textureAnisotropicFilterExtension = GL.getExtension('EXT_texture_filter_anisotropic') || GL.getExtension('WEBKIT_EXT_texture_filter_anisotropic') || GL.getExtension('MOZ_EXT_texture_filter_anisotropic');
			this.maxAnisotropy = this.textureAnisotropicFilterExtension != null ? GL.getParameter(this.textureAnisotropicFilterExtension.MAX_TEXTURE_MAX_ANISOTROPY_EXT) : 0;
			this.instancedArrays = new GLInstancedArrays();
			this.uintIndices = GL.getExtension('OES_element_index_uint') != null;	
			this.highPrecisionShaderSupported = true;
			if (GL.getShaderPrecisionFormat != null) {
				var highp = GL.getShaderPrecisionFormat(GL.FRAGMENT_SHADER, GL.HIGH_FLOAT);
				this.highPrecisionShaderSupported = highp != null && highp.precision != 0;
			}
		} catch (err:Dynamic) {
			trace("error with javascript engine capabilities");
			trace(err);
		}
		
	}
	
}