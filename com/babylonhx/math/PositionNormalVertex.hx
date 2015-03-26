package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PositionNormalVertex {
	
	public var position:Vector3;
	public var normal:Vector3;
	

	public function new(?position:Vector3, ?normal:Vector3) {
        this.position = position != null ? position : Vector3.Zero();
		this.normal = normal != null ? normal : Vector3.Up();
    }

    public function clone():PositionNormalVertex {
        return new PositionNormalVertex(this.position.clone(), this.normal.clone());
    }
	
}
