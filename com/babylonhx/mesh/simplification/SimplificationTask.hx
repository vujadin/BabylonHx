package com.babylonhx.mesh.simplification;

import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SimplificationTask') class SimplificationTask {
	
	public var settings:Array<ISimplificationSettings>;
    public var simplificationType:Int;
    public var mesh:Mesh;
    public var successCallback:Void->Void;
    public var parallelProcessing:Bool;
	

	public function new(settings:Array<ISimplificationSettings>, simplificationType:Int, mesh:Mesh, ?successCallback:Void->Void, parallelProcessing:Bool = false) {
		this.settings = settings;
		this.simplificationType = simplificationType;
		this.mesh = mesh;
		this.successCallback = successCallback;
		this.parallelProcessing = parallelProcessing;
	}
	
}
