package com.babylonhx;

import lime.graphics.opengl.ext.WEBGL_compressed_texture_s3tc;
import lime.graphics.opengl.ext.EXT_texture_filter_anisotropic;
import lime.graphics.opengl.ext.WEBGL_draw_buffers;

/**
 * ...
 * @author Krtolica Vujadin
 */

#if (!mobile && cpp) 
typedef IAMethods = {
	vertexAttribDivisorANGLE: Dynamic,
	drawElementsInstancedANGLE: Dynamic,
	drawArraysInstancedANGLE: Dynamic
}
#end

@:expose('BABYLON.EngineCapabilities') class EngineCapabilities {
	
	public var maxTexturesImageUnits:Int;
	public var maxVertexTextureImageUnits:Int;
	public var maxTextureSize:Int;
	public var maxCubemapTextureSize:Int;
	public var maxRenderTextureSize:Null<Int>;
	public var maxVertexAttribs:Int;
	public var maxVaryingVectors:Int;
	public var maxVertexUniformVectors:Int;
	public var maxFragmentUniformVectors:Int;
	public var standardDerivatives:Bool;
	public var s3tc:Dynamic;// WEBGL_compressed_texture_s3tc;
	public var pvrtc:Dynamic; //WEBGL_compressed_texture_pvrtc;
	public var etc1:Dynamic; //WEBGL_compressed_texture_etc1;
	public var etc2:Dynamic; //WEBGL_compressed_texture_etc;
	public var astc:Dynamic; //WEBGL_compressed_texture_astc;
	public var textureFloat:Bool;
	public var vertexArrayObject:Bool;
	public var textureAnisotropicFilterExtension:Dynamic;// EXT_texture_filter_anisotropic;
	public var maxAnisotropy:Int;
	public var instancedArrays:Bool;
	public var uintIndices:Bool;
	public var highPrecisionShaderSupported:Bool;
	public var fragmentDepthSupported:Bool;
	public var textureFloatLinearFiltering:Bool;
	public var textureFloatRender:Bool;
	public var textureHalfFloat:Bool;
	public var textureHalfFloatLinearFiltering:Bool;
	public var textureHalfFloatRender:Bool;
	public var textureLOD:Bool;
	public var drawBuffersExtension:Dynamic;// WEBGL_draw_buffers;
	public var colorBufferFloat:Bool;
	
	/*
	public var maxTexturesImageUnits:Int;
	public var maxTextureSize:Int;
	public var maxCubemapTextureSize:Int;
	public var maxRenderTextureSize:Null<Int>;
	public var maxVertexAttribs:Int;
	public var maxVaryingVectors:Int;
    public var maxVertexUniformVectors:Int;
    public var maxFragmentUniformVectors:Int;
	public var standardDerivatives:Null<Bool>;
	public var s3tc:Dynamic;
	public var textureFloat:Null<Bool>;
	public var textureAnisotropicFilterExtension:Dynamic;
	public var maxAnisotropy:Int;
	#if (!mobile && cpp)
	public var instancedArrays:IAMethods;
	#else
	public var instancedArrays:Dynamic;
	#end
	public var uintIndices:Null<Bool>;
	public var highPrecisionShaderSupported:Bool;
	public var fragmentDepthSupported:Bool;
	public var textureFloatLinearFiltering:Bool;
	public var textureFloatRender:Bool;
	public var textureHalfFloat:Bool;
	public var textureHalfFloatLinearFiltering:Bool;
	public var textureHalfFloatRender:Bool;
	public var textureLOD:Bool;
	public var drawBuffersExtension:Dynamic;
	
	public var textureLODExt:String = "";
	public var textureCubeLodFnName:String = "textureCubeLodEXT";
	*/
	
	public function new() {
		
	}
	
}
