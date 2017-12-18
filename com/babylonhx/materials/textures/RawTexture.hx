package com.babylonhx.materials.textures;

import com.babylonhx.engine.Engine;

import lime.utils.ArrayBufferView;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RawTexture') class RawTexture extends Texture {
	
	public var format:Int;
	
	private var _engine:Engine;
	
	
	public function new(data:ArrayBufferView, width:Int, height:Int, format:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, type:Int = Engine.TEXTURETYPE_UNSIGNED_INT) {
		super(null, scene, !generateMipMaps, invertY);
		
		this.format = format;
		
		this._engine = scene.getEngine();		
		this._texture = scene.getEngine().createRawTexture(data, width, height, format, generateMipMaps, invertY, samplingMode, null, type);
		
		this.wrapU = Texture.CLAMP_ADDRESSMODE;
		this.wrapV = Texture.CLAMP_ADDRESSMODE;
	}
	
	public function update(data:ArrayBufferView) {
		this._engine.updateRawTexture(this._texture, data, this._texture.format, this._invertY, "", this._texture.type);
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

	public static function CreateRGBTexture(data:ArrayBufferView, width:Int, height:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, type:Int = Engine.TEXTURETYPE_UNSIGNED_INT):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_RGB, scene, generateMipMaps, invertY, samplingMode, type);
	}

	public static function CreateRGBATexture(data:ArrayBufferView, width:Int, height:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, type:Int = Engine.TEXTURETYPE_UNSIGNED_INT):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_RGBA, scene, generateMipMaps, invertY, samplingMode, type);
	}
	
}
