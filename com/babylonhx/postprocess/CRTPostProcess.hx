package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.CRTPostProcess') class CRTPostProcess extends PostProcess {
	
	// https://www.shadertoy.com/view/MsjXzh#
	public static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; uniform vec2 screenSize; uniform vec2 tileSize; uniform float threads; void main(void) { vec2 posInTile = mod(vec2(gl_FragCoord), tileSize); vec2 tileNum = floor(vec2(gl_FragCoord) / tileSize); vec2 nrmPosInTile = posInTile / tileSize; tileNum.y += floor(abs(nrmPosInTile.x - 0.5) + nrmPosInTile.y); vec2 texCoord = tileNum * tileSize / screenSize.xy; vec3 color = texture2D(textureSampler, texCoord).rgb; color *= fract((nrmPosInTile.y + abs(nrmPosInTile.x - 0.5)) * floor(threads)); gl_FragColor = vec4(color, 1.0); }";
	
	public var screenSize:Vector2 = new Vector2(1, 1);

	public function new() {
		
	}
	
}
