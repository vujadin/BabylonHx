package com.babylonhx.materials.textures;

import com.babylonhx.ISmartArrayCompatible;

import com.babylonhx.utils.GL;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.WebGLTexture') class WebGLTexture implements ISmartArrayCompatible {
	
	public var data:GLTexture;
	
	public var _framebuffer:GLFramebuffer;
	public var _depthBuffer:GLRenderbuffer;
	public var generateMipMaps:Bool;	
	public var isCube:Bool;	
	
	public var isReady:Bool;
	public var noMipmap:Bool = true;
	public var references:Int;
	public var url:String;
	
	public var samplingMode:Int;
	
	public var _size:Dynamic;
	public var _baseHeight:Int;
	public var _baseWidth:Int;
	public var _cachedWrapU:Int;
	public var _cachedWrapV:Int;	
	public var _width:Int;	
	public var _height:Int;
	public var _cachedCoordinatesMode:Int;
	public var _isDisabled:Bool;
	public var _cubeFaces:Array<WebGLTexture>;

    #if (js || purejs)
    public var _workingCanvas:js.html.CanvasElement;
    public var _workingContext:js.html.CanvasRenderingContext2D;
	#end

	public var __smartArrayFlags:Array<Int> = [];
	
	
	public function new(url:String, data:GLTexture) {
		this.url = url;
		this.data = data;	
		
		this.generateMipMaps = false;
		this.isCube = false;
		
		this.samplingMode = Texture.TRILINEAR_SAMPLINGMODE;
		
		this._size = null;
		this._width = 1;
		this._height = 1;
		this._baseHeight = 1;
		this._baseWidth = 1;
		this._cachedWrapU = -1;
		this._cachedWrapV = -1;
		this._framebuffer = null;
		this._depthBuffer = null;
		this._cachedCoordinatesMode = -1;
		this._isDisabled = false;
		
		this.isReady = false;
		this.noMipmap = false;
		this.references = 0;
	}
	
}
