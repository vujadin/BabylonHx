package com.babylonhx.mesh.simplification;

import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DecimationVertex') class DecimationVertex {
	
	public var id:Dynamic;
	
	public var position:Vector3;
	public var normal:Vector3;
	public var uv:Vector2;
	
	public var q:QuadraticMatrix;
	public var isBorder:Bool;

	public var triangleStart:Int;
	public var triangleCount:Int;

	//if color is present instead of uvs.
	public var color:Color4;
	

	public function new(position:Vector3, normal:Vector3, uv:Vector2, id:Dynamic) {
		this.id = id;
		this.position = position;
		this.normal = normal;
		this.uv = uv;
				
		this.isBorder = true;
		this.q = new QuadraticMatrix();
		this.triangleCount = 0;
		this.triangleStart = 0;
	}
	
}
