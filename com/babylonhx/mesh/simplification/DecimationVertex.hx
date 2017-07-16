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
	
	public var q:QuadraticMatrix;
	public var isBorder:Bool;

	public var triangleStart:Int;
	public var triangleCount:Int;
	
	public var originalOffsets:Array<Int>;
	

	public function new(position:Vector3, id:Dynamic) {
		this.id = id;
		this.position = position;
				
		this.isBorder = true;
		this.q = new QuadraticMatrix();
		this.triangleCount = 0;
		this.triangleStart = 0;
		this.originalOffsets = [];
	}
	
	public function updatePosition(newPosition:Vector3) {
		this.position.copyFrom(newPosition);
    }

}
