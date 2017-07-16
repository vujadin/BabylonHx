package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PositionNormalTextureVertex {
	
	public var position:Vector3;
	public var normal:Vector3;
	public var uv:Vector2;
	

	public function new(?position:Vector3, ?normal:Vector3, ?uv:Vector2) {
		this.position = position != null ? position : Vector3.Zero();
		this.normal = normal != null ? normal : Vector3.Up();
		this.uv = uv != null ? uv : Vector2.Zero();
    }

    public function clone():PositionNormalTextureVertex {
        return new PositionNormalTextureVertex(this.position.clone(), this.normal.clone(), this.uv.clone());
    }
	
}
