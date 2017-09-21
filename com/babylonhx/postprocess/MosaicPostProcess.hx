package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MosaicPostProcess extends PostProcess {

	// https://github.com/hughsk/post-process/blob/master/shaders/mosaic.frag
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform float width; uniform float height; uniform float t; uniform float pixel; uniform float edges; uniform float depth; uniform float shift; void main() { vec2 position = vec2(gl_FragCoord.x / width, gl_FragCoord.y / height); vec2 samplePos = position.xy; samplePos.x = floor(samplePos.x * (width / pixel)) / (width / pixel); samplePos.y = floor(samplePos.y * (height / pixel)) / (height / pixel); float st = sin(t * 0.005); float ct = cos(t * 0.005); float h = st * shift / width; float v = ct * shift / height; vec3  o = texture2D(textureSampler, samplePos).rgb; float r = texture2D(textureSampler, samplePos + vec2(+h, +v)).r; float g = texture2D(textureSampler, samplePos + vec2(-h, -v)).g; float b = texture2D(textureSampler, samplePos + vec2(.0, .0)).b; r = mix(o.r, r, fract(abs(st))); g = mix(o.g, g, fract(abs(ct))); float n = mod(gl_FragCoord.x, pixel) * edges; float m = mod(height - gl_FragCoord.y, pixel) * edges; vec3 c = vec3(r,g,b); c = floor(c*depth)/depth; c = c*(1.0-(n+m)*(n+m)); gl_FragColor = vec4(c, 1.0); }";
	
	private var screenSize:Vector2 = new Vector2(100, 100);
	
	public var t:Float = 0.06;
	public var pixelSize:Float = 8.0;
	public var edges:Float = 0.02;
	public var depth:Float = 128.0;
	public var shift:Float = 1.0;
	
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("mosaicPixelShader")) {			
			ShadersStore.Shaders.set("mosaicPixelShader", fragmentShader);
		}
		
		super(name, "mosaic", ["width", "height", "t", "pixel", "edges", "depth", "shift"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.screenSize.x = camera.getScene().getEngine().getRenderWidth();
			this.screenSize.y = camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {		
			effect.setFloat("width", this.screenSize.x);
			effect.setFloat("height", this.screenSize.y);
			effect.setFloat("t", this.t);
			effect.setFloat("pixel", this.pixelSize);
			effect.setFloat("edges", this.edges);
			effect.setFloat("depth", this.depth);
			effect.setFloat("shift", this.shift);
		});
	}
	
}
