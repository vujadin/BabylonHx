package com.babylonhx;

import com.babylonhx.mesh.AbstractMesh;

/**
 * @author Krtolica Vujadin
 */

interface IActiveMeshCandidateProvider {
	
	function getMeshes(scene:Scene):Array<AbstractMesh>;
    /*readonly*/var checksIsEnabled:Bool; // Indicates if the meshes have been checked to make sure they are isEnabled().
  
}
