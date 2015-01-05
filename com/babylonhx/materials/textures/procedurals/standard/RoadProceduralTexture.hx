package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

class RoadProceduralTexture extends ProceduralTexture {
	
	private var _roadColor:Color3 = new Color3(0.53, 0.53, 0.53);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		super(name, size, "road", scene, fallbackTexture, generateMipMaps);
		this.updateShaderUniforms();
		this.refreshRate = 0;
	}

	public function updateShaderUniforms() {
		this.setColor3("roadColor", this._roadColor);
	}

	public var roadColor(get, set):Color3;
	private function get_roadColor():Color3 {
		return this._roadColor;
	}
	private function set_roadColor(value:Color3):Color3 {
		this._roadColor = value;
		this.updateShaderUniforms();
		return value;
	}
	
}
