package com.babylonhx.mesh.simplification;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Reference') class Reference {
	
	public var vertexId:Int;
	public var triangleId:Int;
	

	public function new(vertexId:Int, triangleId:Int) {
		this.vertexId = vertexId;
		this.triangleId = triangleId;
	}
	
}
