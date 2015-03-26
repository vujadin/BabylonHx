package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Vector2;
import org.poly2tri.Point;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.IndexedPoint') class IndexedPoint extends Point {
	
	public var index:Int = 0;

	public function new(original:Vector2, index:Int = 0) {
		super(original.x, original.y);
		this.index = index;
	}
	
}
