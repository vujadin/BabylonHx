package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RoadProceduralTexture') class Road extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \r\n\r\nvarying vec2 vUV;\r\nuniform vec3 roadColor;\r\n\r\nfloat rand(vec2 n) {\r\n\treturn fract(cos(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);\r\n}\r\n\r\nfloat noise(vec2 n) {\r\n\tconst vec2 d = vec2(0.0, 1.0);\r\n\tvec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));\r\n\treturn mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);\r\n}\r\n\r\nfloat fbm(vec2 n) {\r\n\tfloat total = 0.0, amplitude = 1.0;\r\n\tfor (int i = 0; i < 4; i++) {\r\n\t\ttotal += noise(n) * amplitude;\r\n\t\tn += n;\r\n\t\tamplitude *= 0.5;\r\n\t}\r\n\treturn total;\r\n}\r\n\r\nvoid main(void) {\r\n\tfloat ratioy = mod(gl_FragCoord.y * 100.0 , fbm(vUV * 2.0));\r\n\tvec3 color = roadColor * ratioy;\r\n\tgl_FragColor = vec4(color, 1.0);\r\n}";
	
	
	private var _roadColor:Color3 = new Color3(0.53, 0.53, 0.53);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("roadtextureFragmentShader")) {
			ShadersStore.Shaders.set("roadtextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "roadtexture", scene, fallbackTexture, generateMipMaps);
		
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
