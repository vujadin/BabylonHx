package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

class BrickProceduralTexture extends ProceduralTexture {
	
	private var _numberOfBricksHeight:Int = 15;
	private var _numberOfBricksWidth:Int = 5;
	private var _jointColor:Color3 = new Color3(0.72, 0.72, 0.72);
	private var _brickColor:Color3 = new Color3(0.77, 0.47, 0.40);

	
	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		super(name, size, "brick", scene, fallbackTexture, generateMipMaps);
		this.updateShaderUniforms();
		this.refreshRate = 0;
	}

	public function updateShaderUniforms() {
		this.setFloat("numberOfBricksHeight", this._numberOfBricksHeight);
		this.setFloat("numberOfBricksWidth", this._numberOfBricksWidth);
		this.setColor3("brickColor", this._brickColor);
		this.setColor3("jointColor", this._jointColor);
	}

	public var numberOfBricksHeight(get, set):Int;
	private function get_numberOfBricksHeight():Int {
		return this._numberOfBricksHeight;
	}
	private function set_numberOfBricksHeight(value:Int):Int {
		this._numberOfBricksHeight = value;
		this.updateShaderUniforms();
		return value;
	}

	public var numberOfBricksWidth(get, set):Int;
	private function get_numberOfBricksWidth():Int {
		return this._numberOfBricksWidth;
	}
	private function set_numberOfBricksWidth(value:Int):Int {
		this._numberOfBricksHeight = value;
		this.updateShaderUniforms();
		return value;
	}

	public var jointColor(get, set):Color3;
	private function get_jointColor():Color3 {
		return this._jointColor;
	}
	private function set_jointColor(value:Color3):Color3 {
		this._jointColor = value;
		this.updateShaderUniforms();
		return value;
	}

	public var brickColor(get, set):Color3;
	private function get_brickColor():Color3 {
		return this._brickColor;
	}
	private function set_brickColor(value:Color3):Color3 {
		this._brickColor = value;
		this.updateShaderUniforms();
		return value;
	}
	
}
