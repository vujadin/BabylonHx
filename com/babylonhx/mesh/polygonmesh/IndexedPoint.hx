package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Vector2;


/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.IndexedPoint') class IndexedPoint extends Vector2 {
	
	public var index:Int = 0;

	public function new(original:Vector2, index:Int = 0) {
		super(original.x, original.y);
		this.index = index;
	}
	
}
