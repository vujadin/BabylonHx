package com.babylonhx.materials.textures;

import lime.utils.ArrayBufferView;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RawTexture') class RawTexture extends Texture {
	
	public var format:Int;
	
	
	public function new(data:ArrayBufferView, width:Int, height:Int, format:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
		super(null, scene, !generateMipMaps, invertY);
		
		this.format = format;
		
		this._texture = scene.getEngine().createRawTexture(data, width, height, format, generateMipMaps, invertY, samplingMode);
		
		this.wrapU = Texture.CLAMP_ADDRESSMODE;
		this.wrapV = Texture.CLAMP_ADDRESSMODE;
	}
	
	public function update(data:ArrayBufferView) {
		this.getScene().getEngine().updateRawTexture(this._texture, data, this.format, this._invertY);
	}

	// Statics
	public static function CreateLuminanceTexture(data:ArrayBufferView, width:Int, height:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_LUMINANCE, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateLuminanceAlphaTexture(data:ArrayBufferView, width:Int, height:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_LUMINANCE_ALPHA, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateAlphaTexture(data:ArrayBufferView, width:Int, height:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_ALPHA, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateRGBTexture(data:ArrayBufferView, width:Int, height:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_RGB, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateRGBATexture(data:ArrayBufferView, width:Int, height:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_RGBA, scene, generateMipMaps, invertY, samplingMode);
	}
	
}
