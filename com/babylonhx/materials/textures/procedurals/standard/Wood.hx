package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.WoodProceduralTexture') class Wood extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \r\n\r\nvarying vec2 vPosition;\r\nvarying vec2 vUV;\r\n\r\nuniform float ampScale;\r\nuniform vec3 woodColor;\r\n\r\nfloat rand(vec2 n) {\r\n\treturn fract(cos(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);\r\n}\r\n\r\nfloat noise(vec2 n) {\r\n\tconst vec2 d = vec2(0.0, 1.0);\r\n\tvec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));\r\n\treturn mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);\r\n}\r\n\r\nfloat fbm(vec2 n) {\r\n\tfloat total = 0.0, amplitude = 1.0;\r\n\tfor (int i = 0; i < 4; i++) {\r\n\t\ttotal += noise(n) * amplitude;\r\n\t\tn += n;\r\n\t\tamplitude *= 0.5;\r\n\t}\r\n\treturn total;\r\n}\r\n\r\nvoid main(void) {\r\n\tfloat ratioy = mod(vUV.x * ampScale, 2.0 + fbm(vUV * 0.8));\r\n\tvec3 wood = woodColor * ratioy;\r\n\tgl_FragColor = vec4(wood, 1.0);\r\n}";
	
	
	private var _ampScale:Float = 100.0;
	private var _woodColor:Color3 = new Color3(0.32, 0.17, 0.09);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("woodtextureFragmentShader")) {
			ShadersStore.Shaders.set("woodtextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "woodtexture", scene, fallbackTexture, generateMipMaps);
		
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
