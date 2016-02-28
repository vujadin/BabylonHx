package com.babylonhx.materials.textures;

import com.babylonhx.math.Color3;
import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.math.SphericalHarmonics;
import com.babylonhx.math.SphericalPolynomial;
import com.babylonhx.math.Matrix;
import com.babylonhx.tools.hdr.CubeMapToSphericalPolynomialTools;
import com.babylonhx.tools.hdr.HDRTools;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt8Array;



/**
 * ...
 * @author Krtolica Vujadin
 */
class HDRCubeTexture extends BaseTexture {
	
	public var url:String;

	private var _useInGammaSpace:Bool = false;
    private var _generateHarmonics:Bool = true;
	private var _noMipmap:Bool;
	private var _extensions:Array<String>;
	private var _textureMatrix:Matrix;
	private var _size:Int;
	private var _usePMREMGenerator:Bool;
	
	private static var _facesMapping = [
		"left",
		"down",
		"front",
		"right",
		"up",
		"back"
	];

	public var sphericalPolynomial:SphericalPolynomial = null;
	
	public var isPMREM:Bool = false;
	

	public function new(url:String, scene:Scene, size:Int, noMipmap:Bool = false, generateHarmonics:Bool = true, useInGammaSpace:Bool = false, usePMREMGenerator:Bool = false) {
		super(scene);
		
		this.coordinatesMode = Texture.CUBIC_MODE;
		
		this.name = url;
		this.url = url;
		this._noMipmap = noMipmap;
		this.hasAlpha = false;
		this._size = size;
		this._useInGammaSpace = useInGammaSpace;
		this._usePMREMGenerator = usePMREMGenerator;
        this.isPMREM = usePMREMGenerator;
		
		if (url == null) {
			return;
		}
		
		this._texture = this._getFromCache(url, noMipmap);
		
		if (this._texture == null) {
			if (!scene.useDelayedTextureLoading) {
				this.loadTexture();
			} 
			else {
				this.delayLoadState = Engine.DELAYLOADSTATE_NOTLOADED;
			}
		}
		
		this.isCube = true;
		
		this._textureMatrix = Matrix.Identity();
	}
	
	private function loadTexture() {
		var callback = function(buffer:Dynamic):Array<ArrayBufferView> {
			trace(buffer);
			trace("buffer.length: " + buffer.length);
			// Extract the raw linear data.
			var data = HDRTools.GetCubeMapTextureData(buffer, this._size);
			
			// Generate harmonics if needed.
			if (this._generateHarmonics) {
				this.sphericalPolynomial = CubeMapToSphericalPolynomialTools.ConvertCubeMapToSphericalPolynomial(data);
			}
			
			var results:Array<ArrayBufferView> = [];
			var byteArray:UInt8Array = null;
			
			// Create uintarray fallback.
			var textureFloat = this.getScene().getEngine().getCaps().textureFloat;
			if (textureFloat == null || textureFloat == false) {
				// 3 channels of 1 bytes per pixel in bytes.
				var byteBuffer = new ArrayBuffer(this._size * this._size * 3);
				byteArray = new UInt8Array(byteBuffer);
			}
			
			for (j in 0...6) {
				var dataFace:Float32Array = Reflect.getProperty(data, _facesMapping[j]);
				
				// If special cases.
				if (this._useInGammaSpace || byteArray != null) {
					for(i in 0...this._size * this._size) {						 
						// Put in gamma space if requested.
						if (this._useInGammaSpace) {
							dataFace[(i * 3) + 0] = Math.pow(dataFace[(i * 3) + 0], Color3.ToGammaSpace);
							dataFace[(i * 3) + 1] = Math.pow(dataFace[(i * 3) + 1], Color3.ToGammaSpace);
							dataFace[(i * 3) + 2] = Math.pow(dataFace[(i * 3) + 2], Color3.ToGammaSpace);
						}
						
						// Convert to int texture for fallback.
						if (byteArray != null) {
							// R
							byteArray[(i * 3) + 0] = Std.int(dataFace[Std.int(i * 3) + 0] * 255);
							byteArray[(i * 3) + 0] = Std.int(Math.min(255, byteArray[(i * 3) + 0]));
							// G
							byteArray[(i * 3) + 1] = Std.int(dataFace[Std.int(i * 3) + 1] * 255);
							byteArray[(i * 3) + 1] = Std.int(Math.min(255, byteArray[Std.int(i * 3) + 1]));
							// B
							byteArray[(i * 3) + 2] = Std.int(dataFace[Std.int(i * 3) + 2] * 255);
							byteArray[(i * 3) + 2] = Std.int(Math.min(255, byteArray[(i * 3) + 2]));
						}
					}
				}
				
				results.push(dataFace);
			}
			
			return results;
		}
		
		this._texture = this.getScene().getEngine().createRawCubeTexture(this.url, this.getScene(), this._size, Engine.TEXTUREFORMAT_RGB, Engine.TEXTURETYPE_FLOAT, this._noMipmap, callback);
	}
	
	override public function clone():HDRCubeTexture {
		var newTexture = new HDRCubeTexture(this.url, this.getScene(), this._size, this._noMipmap, this._generateHarmonics, this._useInGammaSpace);
		
		// Base texture
		newTexture.level = this.level;
		newTexture.wrapU = this.wrapU;
		newTexture.wrapV = this.wrapV;
		newTexture.coordinatesIndex = this.coordinatesIndex;
		newTexture.coordinatesMode = this.coordinatesMode;
		
		return newTexture;
	}

	// Methods
	override public function delayLoad() {
		if (this.delayLoadState != Engine.DELAYLOADSTATE_NOTLOADED) {
			return;
		}
		
		this.delayLoadState = Engine.DELAYLOADSTATE_LOADED;
		this._texture = this._getFromCache(this.url, this._noMipmap);
		
		if (this._texture == null) {
			this.loadTexture();
		}
	}

	override public function getReflectionTextureMatrix():Matrix {
		return this._textureMatrix;
	}
	
	public static function Parse(parsedTexture:Dynamic, scene:Scene, rootUrl:String):HDRCubeTexture {
		var texture:HDRCubeTexture = null;
		if (parsedTexture.name != null && (parsedTexture.isRenderTarget == null || parsedTexture.isRenderTarget == false)) {
			texture = new HDRCubeTexture(rootUrl + parsedTexture.name, scene, parsedTexture.size, parsedTexture.generateHarmonics, parsedTexture.useInGammaSpace);
			texture.name = parsedTexture.name;
			texture.hasAlpha = parsedTexture.hasAlpha;
			texture.level = parsedTexture.level;
			texture.coordinatesMode = parsedTexture.coordinatesMode;
		}
		
		return texture;
	}

	override public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject:Dynamic = { };
		serializationObject.name = this.name;
		serializationObject.hasAlpha = this.hasAlpha;
		serializationObject.isCube = true;
		serializationObject.level = this.level;
		serializationObject.size = this._size;
		serializationObject.coordinatesMode = this.coordinatesMode;
		serializationObject.useInGammaSpace = this._useInGammaSpace;
		serializationObject.generateHarmonics = this._generateHarmonics;
		
		return serializationObject;
	}
	
}
