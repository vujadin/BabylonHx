package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Torus') class Torus extends _Primitive {
	
	// Members
	public var diameter:Float;
	public var thickness:Float;
	public var tessellation:Int;
	

	public function new(id:String, scene:Scene, diameter:Float, thickness:Float, tessellation:Int, ?canBeRegenerated:Bool, ?mesh:Mesh) {
		this.diameter = diameter;
		this.thickness = thickness;
		this.tessellation = tessellation;

		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateTorus(this.diameter, this.thickness, this.tessellation);
	}

	override public function copy(id:String):Geometry {
		return new Torus(id, this.getScene(), this.diameter, this.thickness, this.tessellation, this.canBeRegenerated(), null);
	}
	
}
