package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.TorusKnot') class TorusKnot extends _Primitive {
	
	// Members
	public var radius:Float;
	public var tube:Float;
	public var side:Int;
	public var radialSegments:Int;
	public var tubularSegments:Int;
	public var p:Float;
	public var q:Float;
	

	public function new(id:String, scene:Scene, radius:Float, tube:Float, radialSegments:Int, tubularSegments:Int, p:Float, q:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.radius = radius;
		this.tube = tube;
		this.side = side;
		this.radialSegments = radialSegments;
		this.tubularSegments = tubularSegments;
		this.p = p;
		this.q = q;
		
		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateTorusKnot(this.radius, this.tube, this.radialSegments, this.tubularSegments, this.p, this.q, this.side);
	}

	override public function copy(id:String):Geometry {
		return new TorusKnot(id, this.getScene(), this.radius, this.tube, this.radialSegments, this.tubularSegments, this.p, this.q, this.canBeRegenerated(), null, this.side);
	}
	
}
