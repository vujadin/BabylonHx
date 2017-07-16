package com.babylonhx ;

/**
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.IDisposable') interface IDisposable {
	
	function dispose(doNotRecurse:Bool = false):Void;
	
}