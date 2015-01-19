package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Plane') class Plane extends _Primitive {
	
	// Members
	public var size:Float;
	

	public function new(id:String, scene:Scene, size:Float, ?canBeRegenerated:Bool, ?mesh:Mesh) {
		this.size = size;

		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreatePlane(this.size);
	}

	override public function copy(id:String):Geometry {
		return new Plane(id, this.getScene(), this.size, this.canBeRegenerated(), null);
	}
	
}
