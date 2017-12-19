package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.engine.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
@:expose('BABYLON.OldVideoPostProcess') class OldVideoPostProcess extends PostProcess {
	
	// Source: https://www.shadertoy.com/view/Xdl3D8
	public static var fragmentShader:String = "" +
		"#ifdef GL_ES\nprecision highp float;\n#endif\n " +
		
		"#define BLACK_AND_WHITE \n" +
		"#define LINES_AND_FLICKER \n" +
		"#define BLOTCHES \n" +
		"#define GRAIN \n" +
		
		"#define FREQUENCY 15.0 \n" +
		
		"varying vec2 vUV; \n" +
		"uniform sampler2D textureSampler; \n" +
		
		"uniform float elapsedTime; \n" +
		"uniform vec2 screenSize; \n" +
		
		"float rand(vec2 co){ \n" +
		"	return fract(sin(dot(co.xy ,vec2(12.9898, 78.233))) * 43758.5453); \n" +
		"} \n" +
		
		"float rand(float c){ \n" +
		"	return rand(vec2(c, 1.0)); \n" +
		"} \n" +
		
		"float randomLine(float seed) \n" +
		"{ \n" +
		"	float b = 0.01 * rand(seed); \n" +
		"	float a = rand(seed + 1.0); \n" +
		"	float c = rand(seed + 2.0) - 0.5; \n" +
		"	float mu = rand(seed + 3.0); \n" +
		
		"	float l = 1.0; \n" +
		
		"	if (mu > 0.2) \n" +
		"		l = pow(abs(a * vUV.x + b * vUV.y + c), 1.0 / 8.0); \n" +
		"	else \n" +
		"		l = 2.0 - pow(abs(a * vUV.x + b * vUV.y + c), 1.0 / 8.0); \n" +
		
		"	return mix(0.5, 1.0, l); \n" +
		"} \n" +
		
		"// Generate some blotches. \n" +
		"float randomBlotch(float seed) \n" +
		"{ \n" +
		"	float x = rand(seed); \n" +
		"	float y = rand(seed + 1.0); \n" +
		"	float s = 0.01 * rand(seed + 2.0); \n" +
		
		"	vec2 p = vec2(x, y) - vUV; \n" +
		"	p.x *= screenSize.x / screenSize.y; \n" +
		"	float a = atan(p.y, p.x); \n" +
		"	float v = 1.0; \n" +
		"	float ss = s * s * (sin(6.2831 * a * x) * 0.1 + 1.0); \n" +
		
		"	if (dot(p, p) < ss ) v = 0.2; \n" +
		"	else \n" +
		"		v = pow(dot(p, p) - ss, 1.0 / 16.0); \n" +
		
		"	return mix(0.3 + 0.2 * (1.0 - (s / 0.02)), 1.0, v); \n" +
		"} \n" +
		
		"void main() \n" +
		"{ \n" +
		
		"	// Set frequency of global effect to 15 variations per second \n" +
		"	float t = float(int(elapsedTime * FREQUENCY)); \n" +
		
		"	// Get some image movement \n" +
		"	vec2 suv = vUV + 0.002 * vec2(rand(t), rand(t + 23.0)); \n" +
		
		"	// Get the image \n" +
		"	vec3 image = texture(textureSampler, vec2(suv.x, suv.y)).xyz; \n" +
		
		"	#ifdef BLACK_AND_WHITE \n" +
		"	// Convert it to B/W \n" +
		"	float luma = dot(vec3(0.2126, 0.7152, 0.0722), image); \n" +
		"	vec3 oldImage = luma * vec3(0.7, 0.7, 0.7); \n" +
		"	#else \n" +
		"	vec3 oldImage = image; \n" +
		"	#endif \n" +
		
		"	// Create a time-varying vignetting effect \n" +
		"	float vI = 16.0 * (vUV.x * (1.0 - vUV.x) * vUV.y * (1.0 - vUV.y)); \n" +
		"	vI *= mix(0.7, 1.0, rand(t + 0.5)); \n" +
		
		"	// Add additive flicker \n" +
		"	vI += 1.0 + 0.4 * rand(t + 8.); \n" +
		
		"	// Add a fixed vignetting (independent of the flicker) \n" +
		"	vI *= pow(16.0 * vUV.x * (1.0 - vUV.x) * vUV.y * (1.0 - vUV.y), 0.4); \n" +
		
		"	// Add some random lines (and some multiplicative flicker. Oh well.) \n" +
		"	#ifdef LINES_AND_FLICKER \n" +
		"	int l = int(8.0 * rand(t + 7.0)); \n" +
		
		"	if (0 < l) vI *= randomLine(t + 6.0 + 17. * float(0)); \n" +
		"	if (1 < l) vI *= randomLine(t + 6.0 + 17. * float(1)); \n" +
		"	if (2 < l) vI *= randomLine(t + 6.0 + 17. * float(2)); \n" +
		"	if (3 < l) vI *= randomLine(t + 6.0 + 17. * float(3)); \n" +
		"	if (4 < l) vI *= randomLine(t + 6.0 + 17. * float(4)); \n" +
		"	if (5 < l) vI *= randomLine(t + 6.0 + 17. * float(5)); \n" +
		"	if (6 < l) vI *= randomLine(t + 6.0 + 17. * float(6)); \n" +
		"	if (7 < l) vI *= randomLine(t + 6.0 + 17. * float(7)); \n" +
		
		"	#endif \n" +
		
		"	// Add some random blotches. \n" +
		"	#ifdef BLOTCHES \n" +
		"	int s = int( max(8.0 * rand(t+18.0) -2.0, 0.0 )); \n" +
		
		"	if (0 < s) vI *= randomBlotch(t + 6.0 + 19. * float(0)); \n" +
		"	if (1 < s) vI *= randomBlotch(t + 6.0 + 19. * float(1)); \n" +
		"	if (2 < s) vI *= randomBlotch(t + 6.0 + 19. * float(2)); \n" +
		"	if (3 < s) vI *= randomBlotch(t + 6.0 + 19. * float(3)); \n" +
		"	if (4 < s) vI *= randomBlotch(t + 6.0 + 19. * float(4)); \n" +
		"	if (5 < s) vI *= randomBlotch(t + 6.0 + 19. * float(5)); \n" +
		
		"	#endif \n" +
		
		"	// Show the image modulated by the defects \n" +
		"	gl_FragColor.rgb = oldImage * vI; \n" +
		
		"	// Add some grain (thanks, Jose!) \n" +
		"	#ifdef GRAIN \n" +
		"	gl_FragColor.rgb *= (1.0 + (rand(vUV + t * .01) - .2) * .15); \n" +
		"	#endif \n" +
		
		"}"; 

	public var elapsedTime:Float = 0;
	public var screenSize:Vector2 = new Vector2(100, 100);

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("oldVideoPixelShader")) {			
			ShadersStore.Shaders.set("oldVideoPixelShader", fragmentShader);
		}
		
		super(name, "oldVideo", ["screenSize", "elapsedTime"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.screenSize.x = camera.getScene().getEngine().getRenderWidth();
			this.screenSize.y = camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			this.elapsedTime += camera.getScene().getAnimationRatio() * 0.03;
			effect.setFloat("elapsedTime", this.elapsedTime);
			effect.setVector2("screenSize", this.screenSize);
		});
	}
	
}
