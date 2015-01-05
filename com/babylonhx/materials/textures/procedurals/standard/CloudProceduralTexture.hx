package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

class CloudProceduralTexture extends ProceduralTexture {
	
	private var _skyColor:Color3 = new Color3(0.15, 0.68, 1.0);
	private var _cloudColor:Color3 = new Color3(1, 1, 1);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		super(name, size, "cloud", scene, fallbackTexture, generateMipMaps);
		this.updateShaderUniforms();
		this.refreshRate = 0;
	}

	public function updateShaderUniforms() {
		this.setColor3("skyColor", this._skyColor);
		this.setColor3("cloudColor", this._cloudColor);
	}

	public var skyColor(get, set):Color3;
	private function get_skyColor():Color3 {
		return this._skyColor;
	}
	private function set_skyColor(value:Color3):Color3 {
		this._skyColor = value;
		this.updateShaderUniforms();
		return value;
	}

	public var cloudColor(get, set):Color3;
	private function get_cloudColor():Color3 {
		return this._cloudColor;
	}
	private function set_cloudColor(value:Color3):Color3 {
		this._cloudColor = value;
		this.updateShaderUniforms();
		return value;
	}
	
}
