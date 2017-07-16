package com.babylonhx.lights;

import com.babylonhx.lights.shadows.IShadowGenerator;
import com.babylonhx.materials.UniformBuffer;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;


/**
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.IShadowLight') interface IShadowLight {
  
	var id:String;
	var position:Vector3;
	var direction(get, set):Vector3;
	var transformedPosition:Vector3;
	var transformedDirection:Vector3;
	var name:String;
	var shadowMinZ(get, set):Float;
	var shadowMaxZ(get, set):Float;

	function computeTransformedInformation():Bool;
	function getScene():Scene;

	var customProjectionMatrixBuilder:Matrix->Array<AbstractMesh>->Matrix->Void;
	
	function setShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>):IShadowLight;
	function getDepthScale():Float;

	function needCube():Bool;
	function needProjectionMatrixCompute():Bool;
	function forceProjectionMatrixCompute():Void;

	function getShadowDirection(?faceIndex:Int):Vector3;
	
	// BHX
	function _markMeshesAsLightDirty():Void;
	var _shadowGenerator:IShadowGenerator;
	var shadowEnabled:Bool;
	var _uniformBuffer:UniformBuffer;
	
	function getDepthMinZ(activeCamera:Camera):Float;
	function getDepthMaxZ(activeCamera:Camera):Float;
	
}
