package com.babylonhx.engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Define options used to create a depth texture
 */
typedef DepthTextureCreationOptions = {

	/** Specifies wether or not a stencil should be allocated in the texture */
	@:optional var generateStencil:Bool;
	/** Specifies wether or not bilinear filtering is enable on the texture */
	@:optional var bilinearFiltering:Bool;
	/** Specifies the comparison function to set on the texture. If 0 or undefined, the texture is not in comparison mode */
	@:optional var comparisonFunction:Int;
	
}
