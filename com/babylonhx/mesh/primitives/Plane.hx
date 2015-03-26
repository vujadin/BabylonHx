package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Plane') class Plane extends _Primitive {
	
	// Members
	public var size:Float;
	public var side:Int;
	

	public function new(id:String, scene:Scene, size:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.size = size;
		this.side = side;
		
		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreatePlane(this.size, this.side);
	}

	override public function copy(id:String):Geometry {
		return new Plane(id, this.getScene(), this.size, this.canBeRegenerated(), null, this.side);
	}
	
}
