package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;


/**
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.IShadowLight') interface IShadowLight {
  
	var position:Vector3;
	var direction:Vector3;
	var transformedPosition:Vector3;
	var name:String;

	function computeTransformedPosition():Bool;
	function getScene():Scene;
	
	function setShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>, useVSM:Bool):Void;
	
	function supportsVSM():Bool;
	function needRefreshPerFrame():Bool;

	var _shadowGenerator:ShadowGenerator;
	
}