package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * @filter        Hexagonal Pixelate
 * @description   Renders the image using a pattern of hexagonal tiles. Tile colors
 *                are nearest-neighbor sampled from the centers of the tiles.
 * @param centerX The x coordinate of the pattern center.
 * @param centerY The y coordinate of the pattern center.
 * @param scale   The width of an individual tile, in pixels.
 */
@:expose('BABYLON.HexagonalPixelatePostProcess') class HexagonalPixelatePostProcess extends PostProcess {
	
	// https://github.com/evanw/glfx.js/blob/master/src/filters/fun/hexagonalpixelate.js
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform float _scale; uniform vec2 screenSize; void main() { vec2 center = vec2(screenSize.x / 2.0, screenSize.y / 2.0); vec2 tex = (vUV * screenSize - center) / _scale; tex.y /= 0.866025404; tex.x -= tex.y * 0.5; vec2 a; if (tex.x + tex.y - floor(tex.x) - floor(tex.y) < 1.0) a = vec2(floor(tex.x), floor(tex.y)); else a = vec2(ceil(tex.x), ceil(tex.y)); vec2 b = vec2(ceil(tex.x), floor(tex.y)); vec2 c = vec2(floor(tex.x), ceil(tex.y)); vec3 TEX = vec3(tex.x, tex.y, 1.0 - tex.x - tex.y); vec3 A = vec3(a.x, a.y, 1.0 - a.x - a.y); vec3 B = vec3(b.x, b.y, 1.0 - b.x - b.y); vec3 C = vec3(c.x, c.y, 1.0 - c.x - c.y); float alen = length(TEX - A); float blen = length(TEX - B); float clen = length(TEX - C); vec2 choice; if (alen < blen) { if (alen < clen) choice = a; else choice = c; } else { if (blen < clen) choice = b; else choice = c; } choice.x += choice.y * 0.5; choice.y *= 0.866025404; choice *= _scale / screenSize; gl_FragColor = texture2D(textureSampler, choice + center / screenSize); }";

	public var screenSize:Vector2 = new Vector2(100, 100);
	public var scale:Float = 10.0;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("hexagonalPixelatePixelShader")) {			
			ShadersStore.Shaders.set("hexagonalPixelatePixelShader", fragmentShader);
		}
		
		super(name, "hexagonalPixelate", ["screenSize", "_scale"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.screenSize.x = camera.getScene().getEngine().getRenderWidth();
			this.screenSize.y = camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setVector2("screenSize", this.screenSize);
			effect.setFloat("_scale", this.scale);
		});
	}
	
}