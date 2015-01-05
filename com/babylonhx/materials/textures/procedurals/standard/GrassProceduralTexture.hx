package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

class GrassProceduralTexture extends ProceduralTexture {
	
	private var _grassColors:Array<Color3>;
	private var _herb1:Color3 = new Color3(0.29, 0.38, 0.02);
	private var _herb2:Color3 = new Color3(0.36, 0.49, 0.09);
	private var _herb3:Color3 = new Color3(0.51, 0.6, 0.28);
	private var _groundColor:Color3 = new Color3(1, 1, 1);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		super(name, size, "grass", scene, fallbackTexture, generateMipMaps);
		
		this._grassColors = [
			new Color3(0.29, 0.38, 0.02),
			new Color3(0.36, 0.49, 0.09),
			new Color3(0.51, 0.6, 0.28)
		];
		
		this.updateShaderUniforms();
		this.refreshRate = 0;
	}

	public function updateShaderUniforms() {
		this.setColor3("herb1Color", this._grassColors[0]);
		this.setColor3("herb2Color", this._grassColors[1]);
		this.setColor3("herb3Color", this._grassColors[2]);
		this.setColor3("groundColor", this._groundColor);
	}

	public var grassColors(get, set):Array<Color3>;
	private function get_grassColors():Array<Color3> {
		return this._grassColors;
	}
	private function set_grassColors(value:Array<Color3>):Array<Color3> {
		this._grassColors = value;
		this.updateShaderUniforms();
		return value;
	}

	public var groundColor(get, set):Color3;
	private function get_groundColor():Color3 {
		return this._groundColor;
	}
	private function set_groundColor(value:Color3):Color3 {
		this._groundColor = value;
		this.updateShaderUniforms();
		return value;
	}
	
}
