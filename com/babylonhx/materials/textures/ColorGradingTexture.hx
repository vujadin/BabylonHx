package com.babylonhx.materials.textures;

import com.babylonhx.math.Matrix;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This represents a color grading texture. This acts as a lookup table LUT, useful during post process
 * It can help converting any input color in a desired output one. This can then be used to create effects
 * from sepia, black and white to sixties or futuristic rendering...
 * 
 * The only supported format is currently 3dl.
 * More information on LUT: https://en.wikipedia.org/wiki/3D_lookup_table/
 */
class ColorGradingTexture extends BaseTexture {

	/**
	 * The current internal texture size.
	 */        
	private var _size:Int;
	
	/**
	 * The current texture matrix. (will always be identity in color grading texture)
	 */
	private var _textureMatrix:Matrix;
	
	/**
	 * The texture URL.
	 */
	public var url:String = "";

	/**
	 * Empty line regex stored for GC.
	 */
	private static var _noneEmptyLineRegex = ~/\S+/;
	
	
	/**
	 * Instantiates a ColorGradingTexture from the following parameters.
	 * 
	 * @param url The location of the color gradind data (currently only supporting 3dl)
	 * @param scene The scene the texture will be used in
	 */
	public function new(url:String, scene:Scene) {
		super(scene);
		
		this._textureMatrix = Matrix.Identity();
		this.name = url;
		this.url = url;
		this.hasAlpha = false;
		this.isCube = false;
		this.wrapU = Texture.CLAMP_ADDRESSMODE;
		this.wrapV = Texture.CLAMP_ADDRESSMODE;
		this.anisotropicFilteringLevel = 1;
		
		this._texture = this._getFromCache(url, true);
		
		if (this._texture == null) {
			if (!scene.useDelayedTextureLoading) {
				this.loadTexture();
			} 
			else {
				this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
			}
		}
	}

	/**
	 * Returns the texture matrix used in most of the material.
	 * This is not used in color grading but keep for troubleshooting purpose (easily swap diffuse by colorgrading to look in).
	 */
	public function getTextureMatrix():Matrix {
		return this._textureMatrix;
	}
	
	/**
	 * Occurs when the file being loaded is a .3dl LUT file.
	 */
	private function load3dlTexture():WebGLTexture {
		var mipLevels:Int = 0;
		var floatArrayView:Float32Array = null;
		var texture = this.getScene().getEngine().createRawTexture(null, 1, 1, Engine.TEXTUREFORMAT_RGBA, false, false, Texture.BILINEAR_SAMPLINGMODE);
		this._texture = texture;
		
		var callback = function(text:String) {
			var data:UInt8Array;
			var tempData:Float32Array;
			
			var line:String = "";
			var lines = text.split('\n');
			var size:Int = 0;
			var pixelIndexW:Int = 0;
			var pixelIndexH:Int = 0;
			var pixelIndexSlice:Int = 0;
			var maxColor:Int = 0;
			
			for (i in 0...lines.length) {
				line = lines[i];
				
				if (!ColorGradingTexture._noneEmptyLineRegex.match(line)) {
					continue;
				}
				
				if (line.indexOf('#') == 0) {
					continue;
				}
				
				var words = line.split(" ");
				if (size == 0) {
					// Number of space + one
					size = words.length;
					data = new UInt8Array(size * size * size * 4); // volume texture of side size and rgb 8
					tempData = new Float32Array(size * size * size * 4);
					
					continue;
				}
				
				if (size != 0) {
					var r = Math.max(parseInt(words[0]), 0);
					var g = Math.max(parseInt(words[1]), 0);
					var b = Math.max(parseInt(words[2]), 0);
					
					maxColor = Math.max(r, maxColor);
					maxColor = Math.max(g, maxColor);
					maxColor = Math.max(b, maxColor);
					
					var pixelStorageIndex = (pixelIndexW + pixelIndexSlice * size + pixelIndexH * size * size) * 4;
					
					tempData[pixelStorageIndex + 0] = r;
					tempData[pixelStorageIndex + 1] = g;
					tempData[pixelStorageIndex + 2] = b;
					tempData[pixelStorageIndex + 3] = 0;
					
					pixelIndexSlice++;
					if (pixelIndexSlice % size == 0) {
						pixelIndexH++;
						pixelIndexSlice = 0;
						if (pixelIndexH % size == 0) {
							pixelIndexW++;
							pixelIndexH = 0;
						}
					}
				}
			}
			
			for (i in 0...tempData.length) {
				var value = tempData[i];
				data[i] = (value / maxColor * 255);
			}
			
			this.getScene().getEngine().updateTextureSize(texture, size * size, size);
			this.getScene().getEngine().updateRawTexture(texture, data, Engine.TEXTUREFORMAT_RGBA, false);
		}
		
		Tools.LoadFile(this.url, callback);
		
		return this._texture;
	}

	/**
	 * Starts the loading process of the texture.
	 */
	private function loadTexture() {
		if (this.url != "" && this.url.toLowerCase().indexOf(".3dl") == (this.url.length - 4)) {
			this.load3dlTexture();
		}
	}

	/**
	 * Clones the color gradind texture.
	 */
	override public function clone():ColorGradingTexture {
		var newTexture = new ColorGradingTexture(this.url, this.getScene());
		
		// Base texture
		newTexture.level = this.level;
		
		return newTexture;
	}

	/**
	 * Called during delayed load for textures.
	 */
	public function delayLoad() {
		if (this.delayLoadState != Engine.DELAYLOADSTATE_NOTLOADED) {
			return;
		}
		
		this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
		this._texture = this._getFromCache(this.url, true);
		
		if (this._texture == null) {
			this.loadTexture();
		}
	}

	/**
	 * Parses a color grading texture serialized by Babylon.
	 * @param parsedTexture The texture information being parsedTexture
	 * @param scene The scene to load the texture in
	 * @param rootUrl The root url of the data assets to load
	 * @return A color gradind texture
	 */
	override public static function Parse(parsedTexture:Dynamic, scene:Scene, rootUrl:String):ColorGradingTexture {
		var texture:ColorGradingTexture = null;
		if (parsedTexture.name != null && (parsedTexture.isRenderTarget == null || parsedTexture.isRenderTarget == false)) {
			texture = new ColorGradingTexture(parsedTexture.name, scene);
			texture.name = parsedTexture.name;
			texture.level = parsedTexture.level;
		}
		
		return texture;
	}
	
	/**
	 * Serializes the LUT texture to json format.
	 */
	public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject:Dynamic = {};
		serializationObject.name = this.name;
		serializationObject.level = this.level;

		return serializationObject;
	}
	
}
