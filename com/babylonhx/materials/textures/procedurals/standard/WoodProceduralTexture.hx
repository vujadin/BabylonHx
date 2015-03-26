package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

class WoodProceduralTexture extends ProceduralTexture {
	
	private var _ampScale:Float = 100.0;
	private var _woodColor:Color3 = new Color3(0.32, 0.17, 0.09);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		super(name, size, "wood", scene, fallbackTexture, generateMipMaps);
		this.updateShaderUniforms();
		this.refreshRate = 0;
	}

	public function updateShaderUniforms() {
		this.setFloat("ampScale", this._ampScale);
		this.setColor3("woodColor", this._woodColor);
	}

	public var ampScale(get, set):Float;
	private function get_ampScale():Float {
		return this._ampScale;
	}
	private function set_ampScale(value:Float):Float {
		this._ampScale = value;
		this.updateShaderUniforms();
		return value;
	}

	public var woodColor(get, set):Color3;
	private function get_woodColor():Color3 {
		return this._woodColor;
	}
	private function set_woodColor(value:Color3):Color3 {
		this._woodColor = value;
		this.updateShaderUniforms();
		return value;
	}
	
}
