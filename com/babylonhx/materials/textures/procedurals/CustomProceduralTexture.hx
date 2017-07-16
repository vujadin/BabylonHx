package com.babylonhx.materials.textures.procedurals;

import com.babylonhx.tools.Tools;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import haxe.Json;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CustomProceduralTexture') class CustomProceduralTexture extends ProceduralTexture {
	
	private var _animate:Bool = true;
	private var _time:Float = 0;
	private var _config:Dynamic;
	private var _texturePath:String;
	

	public function new(name:String, texturePath:String, size:Int, scene:Scene, ?fallbackTexture:Texture, generateMipMaps:Bool = false) {
		super(name, size, null, scene, fallbackTexture, generateMipMaps);
		this._texturePath = texturePath;
		
		// Try to load json
		this.loadJson(texturePath);
		this.refreshRate = 1;
	}

	private function loadJson(jsonUrl:String) {
		function noConfigFile() {
			trace("No config file found in " + jsonUrl + " trying to use ShaderStore or DOM element");
			try {
				this.setFragment(this._texturePath);
			}
			catch (ex:Dynamic) {
				trace("No json or ShaderStore or DOM element found for CustomProceduralTexture");
				throw("No json or ShaderStore or DOM element found for CustomProceduralTexture");
			}
		}
		
		var configFileUrl = jsonUrl + "/config.json";
		
		Tools.LoadFile(configFileUrl, function(data:Dynamic) {
			try {
				this._config = Json.parse(data);
				
				this.updateShaderUniforms();
				this.updateTextures();
				this.setFragment(this._texturePath + "/custom");
				
				this._animate = this._config.animate;
				this.refreshRate = this._config.refreshrate;
			}
			catch (ex:Dynamic) {
				noConfigFile();
			}
		}, null, null, false, noConfigFile);		
	}

	override public function isReady():Bool {
		if (!super.isReady()) {
			return false;
		}
		
		for (name in this._textures.keys()) {
			var texture = this._textures.get(name);
			
			if (!texture.isReady()) {
				return false;
			}
		}
		
		return true;
	}

	override public function render(useCameraPostProcess:Bool = false) {
		if (this._animate) {
			this._time += this.getScene().getAnimationRatio() * 0.03;
			this.updateShaderUniforms();
		}
		
		super.render(useCameraPostProcess);
	}

	public function updateTextures() {
		for (i in 0...this._config.sampler2Ds.length) {
			this.setTexture(this._config.sampler2Ds[i].sample2Dname, new Texture(this._texturePath + "/" + this._config.sampler2Ds[i].textureRelativeUrl, this.getScene()));
		}
	}

	public function updateShaderUniforms() {
		if (this._config != null) {
			for (j in 0...this._config.uniforms.length) {
				var uniform = this._config.uniforms[j];
				
				switch (uniform.type) {
					case "float":
						this.setFloat(uniform.name, uniform.value);
						
					case "color3":
						this.setColor3(uniform.name, new Color3(uniform.r, uniform.g, uniform.b));
						
					case "color4":
						this.setColor4(uniform.name, new Color4(uniform.r, uniform.g, uniform.b, uniform.a));
						
					case "vector2":
						this.setVector2(uniform.name, new Vector2(uniform.x, uniform.y));
						
					case "vector3":
						this.setVector3(uniform.name, new Vector3(uniform.x, uniform.y, uniform.z));
						
				}
			}
		}
		
		this.setFloat("time", this._time);
	}

	public var animate(get, set):Bool;
	inline private function get_animate():Bool {
		return this._animate;
	}
	inline private function set_animate(value:Bool):Bool {
		this._animate = value;
		return value;
	}
	
}
