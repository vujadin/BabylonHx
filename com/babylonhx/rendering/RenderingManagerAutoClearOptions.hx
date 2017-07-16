package com.babylonhx.rendering;

/**
 * @author Krtolica Vujadin
 */

/**
 * Interface describing the different options available in the rendering manager
 * regarding Auto Clear between groups.
 */
interface RenderingManagerAutoClearOptions {
	
	var autoClear:Bool;
    var depth:Bool;
    var stencil:Bool;
  
}
