package com.babylonhx.materials.textures;

import com.babylonhx.utils.Image;
import com.babylonhx.utils.typedarray.UInt8Array;


/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.DynamicTexture') class DynamicTexture extends Texture {
	
	private var _generateMipMaps:Bool;
	public var _canvas:Image;
	
	public var canRescale(get, never):Bool;
	
	public function getContext():UInt8Array {
		return _canvas.data;
	}
	
	public function setData(data:Array<Int>) {
		_canvas.data = new UInt8Array(data);
	}
	

	public function new(name:String, options:Dynamic, scene:Scene, generateMipMaps:Bool, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, format:Int = Engine.TEXTUREFORMAT_RGBA) {
		super(null, scene, !generateMipMaps, null, samplingMode, null, null, null, null, format);
		
		this.name = name;
		
		this.wrapU = Texture.CLAMP_ADDRESSMODE;
		this.wrapV = Texture.CLAMP_ADDRESSMODE;
		
		this._generateMipMaps = generateMipMaps;
		
		if (options.data != null) {
			this._canvas = new Image(options.data, options.width, options.height);
			this._texture = scene.getEngine().createDynamicTexture(options.width, options.height, generateMipMaps, samplingMode);
		}
		else if (options.width != null) {
			this._canvas = new Image(null, options.width, options.height);
			this._texture = scene.getEngine().createDynamicTexture(options.width, options.height, generateMipMaps, samplingMode);
		} 
		else {
			this._canvas = new Image(null, options, options);
			this._texture = scene.getEngine().createDynamicTexture(options, options, generateMipMaps, samplingMode);
		}
		
		var textureSize = this.getSize();
	}
	
	private function get_canRescale():Bool {
		return true;
	}
	
	private function _recreate(textureSize:Dynamic) {
		this._canvas.width = textureSize.width;
		this._canvas.height = textureSize.height;
		
		this.releaseInternalTexture();
		
		this._texture = this.getScene().getEngine().createDynamicTexture(textureSize.width, textureSize.height, this._generateMipMaps, this._samplingMode);
	}

	override public function scale(ratio:Float) {
		var textureSize = this.getSize();
		
		textureSize.width = Std.int(textureSize.width * ratio);
		textureSize.height *= Std.int(textureSize.height * ratio);
		
		//this._canvas.width = textureSize.width;
		//this._canvas.height = textureSize.height;
		
		this._recreate(textureSize);
	}
	
	public function scaleTo(width:Int, height:Int) {
		var textureSize = this.getSize();
		
		textureSize.width  = width;
		textureSize.height = height;
		
		this._recreate(textureSize);
	}

	public function clear() {
		var size = this.getSize();
		//this._context.fillRect(0, 0, size.width, size.height);
		for (i in 0...size.width) {
			for (j in 0...size.height) {
				trace('-- todo');
				//this._canvas.push(0xffffff);
			}
		}
	}

	public function update(invertY:Bool = false) {
		this.getScene().getEngine().updateDynamicTexture(this._texture, this._canvas, invertY, null, this._format);
	}

	/*public drawText(text: string, x: number, y: number, font: string, color: string, clearColor: string, invertY?: boolean, update = true) {
		var size = this.getSize();
		if (clearColor) {
			this._context.fillStyle = clearColor;
			this._context.fillRect(0, 0, size.width, size.height);
		}

		this._context.font = font;
		if (x === null) {
			var textSize = this._context.measureText(text);
			x = (size.width - textSize.width) / 2;
		}

		this._context.fillStyle = color;
		this._context.fillText(text, x, y);

		if (update) {
			this.update(invertY);
		}
	}*/

	override public function clone():DynamicTexture {
		var textureSize = this.getSize();
		var newTexture = new DynamicTexture(this.name, textureSize.width, this.getScene(), this._generateMipMaps);
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		
		// Dynamic Texture
		newTexture.wrapU = this.wrapU;
		newTexture.wrapV = this.wrapV;
		
		return newTexture;
	}
	
}
