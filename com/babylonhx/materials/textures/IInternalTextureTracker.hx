package com.babylonhx.materials.textures;

/**
 * @author Krtolica Vujadin
 */
/**
 * Internal interface used to track {BABYLON.InternalTexture} already bound to the GL context
 */
interface IInternalTextureTracker {
	
	/**
	 * Gets or set the previous tracker in the list
	 */
	var previous:IInternalTextureTracker;
	/**
	 * Gets or set the next tracker in the list
	 */
	var next:IInternalTextureTracker;
  
}
