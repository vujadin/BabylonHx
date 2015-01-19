package com.babylonhx;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.EngineCapabilities') class EngineCapabilities {
	
	public var maxTexturesImageUnits:Int;
	public var maxTextureSize:Int;
	public var maxCubemapTextureSize:Int;
	public var maxRenderTextureSize:Null<Int>;
	public var standardDerivatives:Null<Bool>;
	public var s3tc:Dynamic;
	public var textureFloat:Null<Bool>;
	public var textureAnisotropicFilterExtension:Dynamic;
	public var maxAnisotropy:Int;
	public var instancedArrays:Dynamic;
	public var uintIndices:Null<Bool>;
	
	public function new() {
		
	}
	
}
