package com.babylonhx.mesh.simplification;

/**
 * @author Krtolica Vujadin
 */

/**
 * Expected simplification settings.
 * Quality should be between 0 and 1 (1 being 100%, 0 being 0%);
 */

@:expose('BABYLON.ISimplificationSettings') interface ISimplificationSettings {
  
	var quality:Int;
    var distance:Float;
	var optimizeMesh:Bool;
	
}
