package com.babylonhx.materials.textures;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Internal class used by the engine to get list of {BABYLON.InternalTexture} already bound to the GL context
 */
class DummyInternalTextureTracker implements IInternalTextureTracker {
	
	/**
	 * Gets or set the previous tracker in the list
	 */
	public var previous:IInternalTextureTracker = null;
	/**
	 * Gets or set the next tracker in the list
	 */
	public var next:IInternalTextureTracker = null;
	
	
	public function new() { }
	
}
