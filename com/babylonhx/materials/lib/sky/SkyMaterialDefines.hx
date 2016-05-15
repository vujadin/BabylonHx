package com.babylonhx.materials.lib.sky;


/**
 * ...
 * @author Krtolica Vujadin
 */
class SkyMaterialDefines extends MaterialDefines {
	
	public function new() {
		super();
		
		this.defines = [
			"CLIPPLANE" => false,
			"POINTSIZE" => false,
			"FOG" => false,
			"VERTEXCOLOR" => false,
			"VERTEXALPHA" => false
		];
	}
	
}
