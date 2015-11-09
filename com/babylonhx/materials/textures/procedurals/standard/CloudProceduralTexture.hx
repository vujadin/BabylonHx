package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color4;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CloudProceduralTexture') class CloudProceduralTexture extends ProceduralTexture {
	
	private var _skyColor:Color4 = new Color4(0.15, 0.68, 1.0, 1.0);
	private var _cloudColor:Color4 = new Color4(1, 1, 1, 1.0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		super(name, size, "cloudtexture", scene, fallbackTexture, generateMipMaps);
		this.updateShaderUniforms();
		this.refreshRate = 0;
	}

	public function updateShaderUniforms() {
		this.setColor4("skyColor", this._skyColor);
		this.setColor4("cloudColor", this._cloudColor);
	}

	public var skyColor(get, set):Color4;
	private function get_skyColor():Color4 {
		return this._skyColor;
	}
	private function set_skyColor(value:Color4):Color4 {
		this._skyColor = value;
		this.updateShaderUniforms();
		return value;
	}

	public var cloudColor(get, set):Color4;
	private function get_cloudColor():Color4 {
		return this._cloudColor;
	}
	private function set_cloudColor(value:Color4):Color4 {
		this._cloudColor = value;
		this.updateShaderUniforms();
		return value;
	}
	
}
