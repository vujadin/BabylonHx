package com.babylonhx.materials.textures;
import com.babylonhx.ISmartArrayCompatible;

#if nme
import nme.gl.GLTexture;
import nme.gl.GLFramebuffer;
import nme.gl.GLRenderbuffer;
#elseif openfl
import openfl.gl.GLTexture;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLRenderbuffer;
#elseif snow
import snow.render.opengl.GL;
#elseif kha

#end

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BabylonTexture') class BabylonTexture implements ISmartArrayCompatible {
	
	public var data:GLTexture;
	
	public var _framebuffer:GLFramebuffer;
	public var _depthBuffer:GLRenderbuffer;
	public var generateMipMaps:Bool;	
	public var isCube:Bool;
	public var _size:Dynamic;
	
	public var isReady:Bool;
	public var noMipmap:Bool = true;
	public var references:Int;
	public var url:String;
	
	public var samplingMode:Int;
	
	public var _baseHeight:Int;
	public var _baseWidth:Int;
	public var _cachedWrapU:Int;
	public var _cachedWrapV:Int;
	
	public var _width:Float;	
	public var _height:Float;
	
	public var __smartArrayFlags:Array<Int>;
	
	
	public function new(url:String, data:GLTexture) {
		this.url = url;
		this.data = data;
		
		this._framebuffer = null;
		this._depthBuffer = null;
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
		
		this.isReady = false;
		this.noMipmap = false;
		this.references = 0;
	}
	
}