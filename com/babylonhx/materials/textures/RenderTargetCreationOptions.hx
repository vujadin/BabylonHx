package com.babylonhx.materials.textures;

import com.babylonhx.engine.Engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RenderTargetCreationOptions {
	
	public var generateMipMaps:Bool = false;
	public var generateDepthBuffer:Bool = true;
    public var generateStencilBuffer:Bool = false;
    public var type:Int = Engine.TEXTURETYPE_UNSIGNED_INT;
    public var samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE;
    

	public function new() {
		
	}
	
}
