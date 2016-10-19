package com.babylonhx.layer;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.tools.Observer;

/**
 * @author Krtolica Vujadin
 */

/**
 * Storage interface grouping all the information required for an excluded mesh.
 */
typedef IHighlightLayerExcludedMesh = {
	/** 
	 * The glowy mesh
	 */
	var mesh:Mesh;
	/**
	 * The mesh render callback use to prevent stencil use
	 */
	var beforeRender:Observer<Mesh>;
	/**
	 * The mesh render callback use to restore previous stencil use
	 */
	var afterRender:Observer<Mesh>;
}
	