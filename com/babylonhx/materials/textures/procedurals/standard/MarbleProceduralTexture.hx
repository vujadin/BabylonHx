package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

class MarbleProceduralTexture extends ProceduralTexture {
	
	private var _numberOfTilesHeight:Int = 3;
	private var _numberOfTilesWidth:Int = 3;
	private var _amplitude:Float = 9.0;
	private var _marbleColor:Color3 = new Color3(0.77, 0.47, 0.40);
	private var _jointColor = new Color3(0.72, 0.72, 0.72);

	
	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		super(name, size, "marble", scene, fallbackTexture, generateMipMaps);
		this.updateShaderUniforms();
		this.refreshRate = 0;
	}

	public function updateShaderUniforms() {
		this.setFloat("numberOfTilesHeight", this._numberOfTilesHeight);
		this.setFloat("numberOfTilesWidth", this._numberOfTilesWidth);
		this.setFloat("amplitude", this._amplitude);
		this.setColor3("marbleColor", this._marbleColor);
		this.setColor3("jointColor", this._jointColor);
	}

	public var numberOfTilesHeight(get, set):Int;
	private function get_numberOfTilesHeight():Int {
		return this._numberOfTilesHeight;
	}
	private function set_numberOfTilesHeight(value:Int):Int {
		this._numberOfTilesHeight = value;
		this.updateShaderUniforms();
		return value;
	}

	public var numberOfTilesWidth(get, set):Int;
	private function get_numberOfTilesWidth():Int {
		return this._numberOfTilesWidth;
	}
	private function set_numberOfTilesWidth(value:Int):Int {
		this._numberOfTilesWidth = value;
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

	public var marbleColor(get, set):Color3;
	private function get_marbleColor():Color3 {
		return this._marbleColor;
	}
	private function set_marbleColor(value:Color3):Color3 {
		this._marbleColor = value;
		this.updateShaderUniforms();
		return value;
	}
	
}
