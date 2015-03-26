package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Cylinder') class Cylinder extends _Primitive {
	
	// Members
	public var height:Float;
	public var diameterTop:Float;
	public var diameterBottom:Float;
	public var tessellation:Int;
	public var subdivisions:Int;
	public var side:Int;
	

	public function new(id:String, scene:Scene, height:Float, diameterTop:Float, diameterBottom:Float, tessellation:Int, subdivisions:Int = 1, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.height = height;
		this.diameterTop = diameterTop;
		this.diameterBottom = diameterBottom;
		this.tessellation = tessellation;
		this.subdivisions = subdivisions;
		this.side = side;
		
		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateCylinder(this.height, this.diameterTop, this.diameterBottom, this.tessellation, this.subdivisions, this.side);
	}

	override public function copy(id:String):Geometry {
		return new Cylinder(id, this.getScene(), this.height, this.diameterTop, this.diameterBottom, this.tessellation, this.subdivisions, this.canBeRegenerated(), null, this.side);
	}
	
}
