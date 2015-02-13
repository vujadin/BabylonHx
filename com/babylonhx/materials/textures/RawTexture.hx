package com.babylonhx.materials.textures;

#if nme
import nme.utils.ArrayBufferView;
#elseif openfl
import openfl.utils.ArrayBufferView;
#elseif snow
import snow.utils.ArrayBufferView;
#elseif kha

#end

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RawTexture') class RawTexture extends Texture {
	
	public function new(data:ArrayBufferView, width:Float, height:Float, format:Int, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE) {
		super(null, scene, !generateMipMaps, invertY);

		this._texture = scene.getEngine().createRawTexture(data, width, height, format, generateMipMaps, invertY, samplingMode);

		this.wrapU = Texture.CLAMP_ADDRESSMODE;
		this.wrapV = Texture.CLAMP_ADDRESSMODE;
	}

	// Statics
	public static function CreateLuminanceTexture(data:ArrayBufferView, width:Float, height:Float, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_LUMINANCE, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateLuminanceAlphaTexture(data:ArrayBufferView, width:Float, height:Float, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_LUMINANCE_ALPHA, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateAlphaTexture(data:ArrayBufferView, width:Float, height:Float, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_ALPHA, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateRGBTexture(data:ArrayBufferView, width:Float, height:Float, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_RGB, scene, generateMipMaps, invertY, samplingMode);
	}

	public static function CreateRGBATexture(data:ArrayBufferView, width:Float, height:Float, scene:Scene, generateMipMaps:Bool = true, invertY:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE):RawTexture {
		return new RawTexture(data, width, height, Engine.TEXTUREFORMAT_RGBA, scene, generateMipMaps, invertY, samplingMode);
	}
	
}
