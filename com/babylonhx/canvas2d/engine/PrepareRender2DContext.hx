package com.babylonhx.canvas2d.engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PrepareRender2DContext {
	
	/**
	 * True if the primitive must be refreshed no matter what
	 * This mode is needed because sometimes the primitive doesn't change by itself, but external changes make a refresh of its InstanceData necessary
	 */
    public var forceRefreshPrimitive:Bool;
	

	public function new() {
		this.forceRefreshPrimitive = false;
	}
	
}
