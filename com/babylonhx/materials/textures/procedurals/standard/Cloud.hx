package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color4;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CloudProceduralTexture') class Cloud extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \r\n\r\nvarying vec2 vUV;\r\n\r\nuniform vec4 skyColor;\r\nuniform vec4 cloudColor;\r\n\r\nfloat rand(vec2 n) {\r\n\treturn fract(cos(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);\r\n}\r\n\r\nfloat noise(vec2 n) {\r\n\tconst vec2 d = vec2(0.0, 1.0);\r\n\tvec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));\r\n\treturn mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);\r\n}\r\n\r\nfloat fbm(vec2 n) {\r\n\tfloat total = 0.0, amplitude = 1.0;\r\n\tfor (int i = 0; i < 4; i++) {\r\n\t\ttotal += noise(n) * amplitude;\r\n\t\tn += n;\r\n\t\tamplitude *= 0.5;\r\n\t}\r\n\treturn total;\r\n}\r\n\r\nvoid main() {\r\n\r\n\tvec2 p = vUV * 12.0;\r\n\tvec4 c = mix(skyColor, cloudColor, fbm(p));\r\n\tgl_FragColor = c;\r\n\r\n}\r\n\r\n";

	
	private var _skyColor:Color4 = new Color4(0.15, 0.68, 1.0, 1.0);
	private var _cloudColor:Color4 = new Color4(1, 1, 1, 1.0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("cloudtextureFragmentShader")) {
			ShadersStore.Shaders.set("cloudtextureFragmentShader", fragmentShader);
		}
		
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
