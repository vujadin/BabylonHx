package com.babylonhx.layer;

import com.babylonhx.cameras.Camera;

/**
 * @author Krtolica Vujadin
 */
/**
 * Effect layer options. This helps customizing the behaviour
 * of the effect layer.
 */
typedef IEffectLayerOptions = {
	
	/**
	 * Multiplication factor apply to the canvas size to compute the render target size
	 * used to generated the objects (the smaller the faster).
	 */
	var mainTextureRatio:Float;

	/**
	 * Enforces a fixed size texture to ensure effect stability across devices.
	 */
	@:optional var mainTextureFixedSize:Int;

	/**
	 * Alpha blending mode used to apply the blur. Default depends of the implementation.
	 */
	@:optional var alphaBlendingMode:Int;

	/**
	 * The camera attached to the layer.
	 */
	@:optional var camera:Camera;
	
}
