package com.babylonhx.rendering;

/**
 * @author Krtolica Vujadin
 */

/**
 * Interface describing the different options available in the rendering manager
 * regarding Auto Clear between groups.
 */

@:allow(com.babylonhx.rendering.RenderingManager)
class RenderingManageAutoClearOptions {
	
	var autoClear:Bool;
    var depth:Bool;
    var stencil:Bool;
	
	public function new(autoClear:Bool, depth:Bool, stencil:Bool) {
		this.autoClear = autoClear;
		this.depth = depth;
		this.stencil = stencil;
	}
  
}
