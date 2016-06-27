package com.babylonhx;

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
	public var maxTextureSize:Int;
	public var maxCubemapTextureSize:Int;
	public var maxRenderTextureSize:Null<Int>;
	public var standardDerivatives:Null<Bool>;
	public var s3tc:Dynamic;
	public var textureFloat:Null<Bool>;
	public var textureAnisotropicFilterExtension:Dynamic;
	public var highPrecisionShaderSupported:Bool;
	public var fragmentDepthSupported:Bool;
	public var textureFloatLinearFiltering:Bool;
	public var drawBufferExtension:Dynamic;
	public var maxAnisotropy:Int;
	public var textureLOD:Bool;
	public var textureLODExt:String = "";
	public var textureCubeLodFnName:String = "textureCubeLodEXT";
	
	#if (!mobile && cpp)
	public var instancedArrays:IAMethods;
	#else
	public var instancedArrays:Dynamic;
	#end
	
	public var uintIndices:Null<Bool>;
	
	
	public function new() {
		
	}
	
}
