package com.babylonhx.mesh.simplification;

/**
 * @author Krtolica Vujadin
 */

interface ISimplificationTask {
	
	var settings:Array<ISimplificationSettings>;
	var simplificationType:Int;
	var mesh:Mesh;
	var successCallback:Void->Void;
	var parallelProcessing:Bool;
  
}
