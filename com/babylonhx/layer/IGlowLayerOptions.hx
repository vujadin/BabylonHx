package com.babylonhx.layer;

import com.babylonhx.cameras.Camera;

/**
 * @author Krtolica Vujadin
 */
/**
 * Glow layer options. This helps customizing the behaviour
 * of the glow layer.
 */
typedef IGlowLayerOptions = {

	/**
	 * Multiplication factor apply to the canvas size to compute the render target size
	 * used to generated the glowing objects (the smaller the faster).
	 */
	var mainTextureRatio:Float;

	/**
	 * Enforces a fixed size texture to ensure resize independant blur.
	 */
	@:optional var mainTextureFixedSize:Int;

	/**
	 * How big is the kernel of the blur texture.
	 */
	@:optional var blurKernelSize:Float;

	/**
	 * The camera attached to the layer.
	 */
	@:optional var camera:Camera;

	/**
	 * Enable MSAA by chosing the number of samples.
	 */
	@:optional var mainTextureSamples:Int;
	
}
