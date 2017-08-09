package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.GrassProceduralTexture') class Grass extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \r\n\r\nvarying vec2 vPosition;\r\nvarying vec2 vUV;\r\n\r\nuniform vec3 herb1Color;\r\nuniform vec3 herb2Color;\r\nuniform vec3 herb3Color;\r\nuniform vec3 groundColor;\r\n\r\nfloat rand(vec2 n) {\r\n\treturn fract(cos(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);\r\n}\r\n\r\nfloat noise(vec2 n) {\r\n\tconst vec2 d = vec2(0.0, 1.0);\r\n\tvec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));\r\n\treturn mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);\r\n}\r\n\r\nfloat fbm(vec2 n) {\r\n\tfloat total = 0.0, amplitude = 1.0;\r\n\tfor (int i = 0; i < 4; i++) {\r\n\t\ttotal += noise(n) * amplitude;\r\n\t\tn += n;\r\n\t\tamplitude *= 0.5;\r\n\t}\r\n\treturn total;\r\n}\r\n\r\nvoid main(void) {\r\n\tvec3 color = mix(groundColor, herb1Color, rand(gl_FragCoord.xy * 4.0));\r\n\tcolor = mix(color, herb2Color, rand(gl_FragCoord.xy * 8.0));\r\n\tcolor = mix(color, herb3Color, rand(gl_FragCoord.xy));\r\n\tcolor = mix(color, herb1Color, fbm(gl_FragCoord.xy * 16.0));\r\n\tgl_FragColor = vec4(color, 1.0);\r\n}";

	
	private var _grassColors:Array<Color3>;
	private var _herb1:Color3 = new Color3(0.29, 0.38, 0.02);
	private var _herb2:Color3 = new Color3(0.36, 0.49, 0.09);
	private var _herb3:Color3 = new Color3(0.51, 0.6, 0.28);
	private var _groundColor:Color3 = new Color3(1, 1, 1);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("grasstextureFragmentShader")) {
			ShadersStore.Shaders.set("grasstextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "grasstexture", scene, fallbackTexture, generateMipMaps);
		
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
