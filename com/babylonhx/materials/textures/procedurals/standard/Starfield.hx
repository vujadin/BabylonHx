package com.babylonhx.materials.textures.procedurals.standard;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.StarfieldProceduralTexture') class Starfield extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \r\n\r\n#define iterations 15\r\n#define formuparam 0.53\r\n\r\n#define volsteps 20\r\n#define stepsize 0.1\r\n\r\n#define tile 0.850\r\n\r\n#define brightness 0.0015\r\n#define darkmatter 0.400\r\n#define distfading 0.730\r\n#define saturation 0.850\r\n\r\nvarying vec2 vPosition;\r\nvarying vec2 vUV;\r\n\r\nuniform float time;\r\nuniform float alpha;\r\nuniform float beta;\r\nuniform float zoom;\r\n\r\nvoid main()\r\n{\r\n\tvec3 dir = vec3(vUV * zoom, 1.);\r\n\r\n\tfloat localTime = time * 0.0001;\r\n\r\n\t// Rotation\r\n\tmat2 rot1 = mat2(cos(alpha), sin(alpha), -sin(alpha), cos(alpha));\r\n\tmat2 rot2 = mat2(cos(beta), sin(beta), -sin(beta), cos(beta));\r\n\tdir.xz *= rot1;\r\n\tdir.xy *= rot2;\r\n\tvec3 from = vec3(1., .5, 0.5);\r\n\tfrom += vec3(localTime*2., localTime, -2.);\r\n\tfrom.xz *= rot1;\r\n\tfrom.xy *= rot2;\r\n\r\n\t//volumetric rendering\r\n\tfloat s = 0.1, fade = 1.;\r\n\tvec3 v = vec3(0.);\r\n\tfor (int r = 0; r < volsteps; r++) {\r\n\t\tvec3 p = from + s*dir*.5;\r\n\t\tp = abs(vec3(tile) - mod(p, vec3(tile*2.))); // tiling fold\r\n\t\tfloat pa, a = pa = 0.;\r\n\t\tfor (int i = 0; i < iterations; i++) {\r\n\t\t\tp = abs(p) / dot(p, p) - formuparam; // the magic formula\r\n\t\t\ta += abs(length(p) - pa); // absolute sum of average change\r\n\t\t\tpa = length(p);\r\n\t\t}\r\n\t\tfloat dm = max(0., darkmatter - a*a*.001); //dark matter\r\n\t\ta *= a*a; // add contrast\r\n\t\tif (r > 6) fade *= 1. - dm; // dark matter, don't render near\r\n\t\t\t\t\t\t\t\t  //v+=vec3(dm,dm*.5,0.);\r\n\t\tv += fade;\r\n\t\tv += vec3(s, s*s, s*s*s*s)*a*brightness*fade; // coloring based on distance\r\n\t\tfade *= distfading; // distance fading\r\n\t\ts += stepsize;\r\n\t}\r\n\tv = mix(vec3(length(v)), v, saturation); //color adjust\r\n\tgl_FragColor = vec4(v*.01, 1.);\r\n}";
	

	private var _time:Float = 1.0;
	private var _alpha:Float = 0.5;
	private var _beta:Float = 0.8;
	private var _zoom:Float = 0.8;
	
	public var time(get, set):Float;
	public var alpha(get, set):Float;
	public var beta(get, set):Float;
	public var zoom(get, set):Float;
	

	public function new(name:String, size:Int, scene:Scene, ?fallbackTexture:Texture, generateMipMaps:Bool = false) {
		if (!ShadersStore.Shaders.exists("starfieldtextureFragmentShader")) {
			ShadersStore.Shaders.set("starfieldtextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "starfieldtexture", scene, fallbackTexture, generateMipMaps);
		
		this.updateShaderUniforms();
	}

	public function updateShaderUniforms() {
		this.setFloat("time", this._time);      
		this.setFloat("alpha", this._alpha);  
		this.setFloat("beta", this._beta);  
		this.setFloat("zoom", this._zoom); 
	}

	private function get_time():Float {
		return this._time;
	}
	private function set_time(value:Float):Float {
		this._time = value;
		this.updateShaderUniforms();
		
		return value;
	}      
	
	private function get_alpha():Float {
		return this._alpha;
	}

	private function set_alpha(value:Float):Float {
		this._alpha = value;
		this.updateShaderUniforms();
		
		return value;
	}    

	private function get_beta():Float{
		return this._beta;
	}

	private function set_beta(value:Float):Float {
		this._beta = value;
		this.updateShaderUniforms();
		
		return value;
	} 

	private function get_zoom():Float {
		return this._zoom;
	}

	private function set_zoom(value:Float):Float {
		this._zoom = value;
		this.updateShaderUniforms();
		
		return value;
	} 
	
}
