package com.babylonhx.layer;

import com.babylonhx.cameras.Camera;

/**
 * @author Krtolica Vujadin
 */

/**
 * Highlight layer options. This helps customizing the behaviour
 * of the highlight layer.
 */
typedef IHighlightLayerOptions = {
	
	/**
	 * Multiplication factor apply to the canvas size to compute the render target size
	 * used to generated the glowing objects (the smaller the faster).
	 */
	var mainTextureRatio:Null<Float>;

	/**
	 * Multiplication factor apply to the main texture size in the first step of the blur to reduce the size 
	 * of the picture to blur (the smaller the faster).
	 */
	var blurTextureSizeRatio:Null<Float>;

	/**
	 * How big in texel of the blur texture is the vertical blur.
	 */
	var blurVerticalSize:Null<Float>;

	/**
	 * How big in texel of the blur texture is the horizontal blur.
	 */
	var blurHorizontalSize:Null<Float>;

	/**
	 * Alpha blending mode used to apply the blur. Default is combine.
	 */
	var alphaBlendingMode:Null<Int>;
	
	/**
     * The camera attached to the layer.
     */
    var camera:Null<Camera>;
  
}
