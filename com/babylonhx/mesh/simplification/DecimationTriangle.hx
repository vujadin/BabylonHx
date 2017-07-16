package com.babylonhx.mesh.simplification;

import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DecimationTriangle') class DecimationTriangle {
	
	public var vertices:Array<DecimationVertex>;
	public var normal:Vector3;
	public var error:Array<Float>;
	public var deleted:Bool;
	public var isDirty:Bool;
	public var borderFactor:Float;
	public var deletePending:Bool;
	
	public var originalOffset:Int;

	
	public function new(vertices:Array<DecimationVertex>) {
		this.error = [];
		this.deleted = false;
		this.isDirty = false;
		this.borderFactor = 0;
		this.vertices = vertices;
		this.deletePending = false;
	}
	
}
