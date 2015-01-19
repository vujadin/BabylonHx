package com.babylonhx.mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.MeshLODLevel') class MeshLODLevel {
	
	public var mesh:Mesh;
	public var distance:Float;
	
	
	public function new(distance:Float, mesh:Mesh) {
		this.distance = distance;
		this.mesh = mesh;
	}
	
}
