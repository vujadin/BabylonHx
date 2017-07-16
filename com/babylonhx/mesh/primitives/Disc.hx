package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Disc extends _Primitive {
	
	public var radius:Float;
	public var tessellation:Float;
	

	public function new(id:String, scene:Scene, radius:Float, tessellation:Float, canBeRegenerated:Bool = false, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		super(id, scene, canBeRegenerated, mesh);
	}

	public function _regenerateVertexData():VertexData {
		return VertexData.CreateDisc({ radius: this.radius, tessellation: this.tessellation, sideOrientation: this.side });
	}

	public function copy(id:String):Geometry {
		return new Disc(id, this.getScene(), this.radius, this.tessellation, this.canBeRegenerated(), null, this.side);
	}
	
}
