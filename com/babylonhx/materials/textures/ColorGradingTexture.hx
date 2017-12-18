package com.babylonhx.materials.textures;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Matrix;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

import lime.utils.Float32Array;
import lime.utils.UInt8Array;

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
	
	private static var colorGradeBitmap:String = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAAQCAYAAAD506FJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAABxSURBVHhe7duhEcAwDARBOR2k/2IdFyCgSUDAL1gDzTw95lVV+z7PW+u83X3K3r67T9l/21/tFYggABBMACCYAEAwAYBgAgDBBACCCQAEEwAIJgAQTAAgmABAMAGAYAIAwVZt34G7+5S9fXef+ndf9QBh9xMnzxaE9AAAAABJRU5ErkJggg==";

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
	
	private var _engine:Engine;
	
	
	/**
	 * Instantiates a ColorGradingTexture from the following parameters.
	 * 
	 * @param url The location of the color gradind data (currently only supporting 3dl)
	 * @param scene The scene the texture will be used in
	 */
	public function new(url:String, scene:Scene) {
		super(scene);
		
		this._engine = scene.getEngine();
		this._textureMatrix = Matrix.Identity();
		this.name = url;
		this.url = url;
		this.hasAlpha = false;
		this.isCube = false;
		this.is3D = this._engine.webGLVersion > 1;
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
	override public function getTextureMatrix():Matrix {
		return this._textureMatrix;
	}
	
	/**
	 * Occurs when the file being loaded is a .3dl LUT file.
	 */
	private function load3dlTexture():InternalTexture {
		var mipLevels:Int = 0;
		var floatArrayView:Float32Array = null;
		var texture = this._engine.createRawTexture(null, 1, 1, Engine.TEXTUREFORMAT_RGBA, false, false, Texture.BILINEAR_SAMPLINGMODE);
		this._texture = texture;
		
		var callback = function(text:String) {
			var data:UInt8Array = null;
			var tempData:Float32Array = null;
			
			var line:String = "";
			var lines = text.split('\n');
			var size:Int = 0;
			var pixelIndexW:Int = 0;
			var pixelIndexH:Int = 0;
			var pixelIndexSlice:Int = 0;
			var maxColor:Float = 0;
			
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
					var r = Math.max(Std.parseInt(words[0]), 0);
					var g = Math.max(Std.parseInt(words[1]), 0);
					var b = Math.max(Std.parseInt(words[2]), 0);
					
					maxColor = Math.max(r, maxColor);
					maxColor = Math.max(g, maxColor);
					maxColor = Math.max(b, maxColor);
					
					var pixelStorageIndex = (pixelIndexW + pixelIndexSlice * size + pixelIndexH * size * size) * 4;
					
					if (tempData != null) {
						tempData[pixelStorageIndex + 0] = r;
						tempData[pixelStorageIndex + 1] = g;
						tempData[pixelStorageIndex + 2] = b;
					}
					
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
			
			if (tempData != null && data != null) {
				for (i in 0...tempData.length) {
					if (i > 0 && (i + 1) % 4 == 0) {
						data[i] = 255;
					}
					else {
						var value = tempData[i];
						data[i] = Std.int(value / maxColor * 255);
					}
				}
			}
			
			if (texture.is3D) {
				texture.updateSize(size, size, size);
				this._engine.updateRawTexture3D(texture, data, Engine.TEXTUREFORMAT_RGBA, false);
			}
			else {
				texture.updateSize(size * size, size);
				this._engine.updateRawTexture(texture, data, Engine.TEXTUREFORMAT_RGBA, false);
			}
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
	override public function delayLoad() {
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
	 * Binds the color grading to the shader.
	 * @param colorGrading The texture to bind
	 * @param effect The effect to bind to
	 */
	public static function Bind(colorGrading:BaseTexture, effect:Effect) {
		effect.setTexture("cameraColorGrading2DSampler", colorGrading);
		
		var x = colorGrading.level;                 // Texture Level
		var y = colorGrading.getSize().height;      // Texture Size example with 8
		var z = y - 1.0;                    // SizeMinusOne 8 - 1
		var w = 1 / y;                      // Space of 1 slice 1 / 8
		
		effect.setFloat4("vCameraColorGradingInfos", x, y, z, w);
		
		var slicePixelSizeU = w / y;    // Space of 1 pixel in U direction, e.g. 1/64
		var slicePixelSizeV = w;		// Space of 1 pixel in V direction, e.g. 1/8					    // Space of 1 pixel in V direction, e.g. 1/8
		
		var x2 = z * slicePixelSizeU;   // Extent of lookup range in U for a single slice so that range corresponds to (size-1) texels, for example 7/64
		var y2 = z / y;	                // Extent of lookup range in V for a single slice so that range corresponds to (size-1) texels, for example 7/8
		var z2 = 0.5 * slicePixelSizeU;	// Offset of lookup range in U to align sample position with texel centre, for example 0.5/64 
		var w2 = 0.5 * slicePixelSizeV;	// Offset of lookup range in V to align sample position with texel centre, for example 0.5/8
		
		effect.setFloat4("vCameraColorGradingScaleOffset", x2, y2, z2, w2);
	}
	
	/**
	 * Prepare the list of uniforms associated with the ColorGrading effects.
	 * @param uniformsList The list of uniforms used in the effect
	 * @param samplersList The list of samplers used in the effect
	 */
	public static function PrepareUniformsAndSamplers(uniformsList:Array<String>, samplersList:Array<String>) {
		uniformsList.push("vCameraColorGradingInfos");
		uniformsList.push("vCameraColorGradingScaleOffset");
		
		samplersList.push("cameraColorGrading2DSampler");
	}

	/**
	 * Parses a color grading texture serialized by Babylon.
	 * @param parsedTexture The texture information being parsedTexture
	 * @param scene The scene to load the texture in
	 * @param rootUrl The root url of the data assets to load
	 * @return A color gradind texture
	 */
	public static function Parse(parsedTexture:Dynamic, scene:Scene, rootUrl:String):ColorGradingTexture {
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
	override public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject:Dynamic = {};
		serializationObject.name = this.name;
		serializationObject.level = this.level;
		serializationObject.customType = "BABYLON.ColorGradingTexture";
		
		return serializationObject;
	}
	
}
