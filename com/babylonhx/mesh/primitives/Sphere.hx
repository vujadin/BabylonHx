package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Sphere') class Sphere extends _Primitive {
	
	// Members
	public var segments:Int;
	public var diameter:Float;
	public var side:Int;
	

	public function new(id:String, scene:Scene, segments:Int, diameter:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.segments = segments;
		this.diameter = diameter;
		this.side = side;
		
		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateSphere(this.segments, this.diameter, this.side);
	}

	override public function copy(id:String):Geometry {
		return new Sphere(id, this.getScene(), this.segments, this.diameter, this.canBeRegenerated(), null, this.side);
	}
	
}
