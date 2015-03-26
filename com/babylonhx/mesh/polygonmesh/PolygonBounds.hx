package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.PolygonBounds') class PolygonBounds {
	
	public var min:Vector2;
	public var max:Vector2;
	public var width:Float;
	public var height:Float;
	

	public function new(min:Vector2, max:Vector2, width:Float, height:Float) {
		this.min = min;
		this.max = max;
		this.width = width;
		this.height = height;
	}
	
}
