package com.babylonhx.layer;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Color3;
import com.babylonhx.tools.Observer;

/**
 * @author Krtolica Vujadin
 */

/**
 * Storage interface grouping all the information required for glowing a mesh.
 */
typedef IHighlightLayerMesh = {
	
	/** 
	 * The glowy mesh
	 */
	var mesh:Mesh;
	/**
	 * The color of the glow
	 */
	var color:Color3;
	/**
	 * The mesh render callback use to insert stencil information
	 */
	var observerHighlight:Observer<Mesh>;
	/**
	 * The mesh render callback use to come to the default behavior
	 */
	var observerDefault:Observer<Mesh>;
	/**
	 * If it exists, the emissive color of the material will be used to generate the glow.
	 * Else it falls back to the current color.
	 */
	var glowEmissiveOnly:Bool;
  
}
