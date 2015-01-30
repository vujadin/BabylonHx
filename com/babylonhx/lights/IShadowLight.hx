package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.math.Vector3;


/**
 * @author Krtolica Vujadin
 */

interface IShadowLight {
  
	var position:Vector3;
	var direction: Vector3;
	var transformedPosition: Vector3;
	var name:String;

	function computeTransformedPosition():Bool;
	function getScene():Scene;

	var _shadowGenerator:ShadowGenerator;
	
}