package com.babylonhx.materials.textures;

/**
 * @author Krtolica Vujadin
 */
/*interface*/ class IMultiRenderTargetOptions {
	
	public var generateMipMaps:Bool;
    public var types:Array<Int>;
    public var samplingModes:Array<Int>;
    public var generateDepthBuffer:Bool;
    public var generateStencilBuffer:Bool;
    public var generateDepthTexture:Bool;
    public var textureCount:Int;
	
	
	public function new() { }
  
}
