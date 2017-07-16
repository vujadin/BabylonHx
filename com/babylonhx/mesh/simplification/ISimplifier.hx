package com.babylonhx.mesh.simplification;

/**
 * @author Krtolica Vujadin
 */

/**
 * A simplifier interface for future simplification implementations.
 */

@:expose('BABYLON.ISimplifier') interface ISimplifier {
  
	/**
	 * Simplification of a given mesh according to the given settings.
	 * Since this requires computation, it is assumed that the function runs async.
	 * @param settings The settings of the simplification, including quality and distance
	 * @param successCallback A callback that will be called after the mesh was simplified.
	 * @param errorCallback in case of an error, this callback will be called. optional.
	 */
	function simplify(settings:ISimplificationSettings, successCallback:Mesh->Void, ?errorCallback:Void->Void):Void;
	
}
