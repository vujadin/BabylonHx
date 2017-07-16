package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.TiledGround') class TiledGround extends _Primitive {
	
	// Members
	public var xmin:Float;
	public var zmin:Float;
	public var xmax:Float;
	public var zmax:Float;
	public var subdivisions:Dynamic;
	public var precision:Dynamic;
	

	public function new(id:String, scene:Scene, xmin:Float, zmin:Float, xmax:Float, zmax:Float, subdivisions:Dynamic, precision:Dynamic, ?canBeRegenerated:Bool, ?mesh:Mesh) {
		this.xmin = xmin;
		this.zmin = zmin;
		this.xmax = xmax;
		this.zmax = zmax;
		this.subdivisions = subdivisions;
		this.precision = precision;
		
		super(id, scene, canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateTiledGround({xmin:this.xmin, zmin:this.zmin, xmax:this.xmax, zmax:this.zmax, subdivisions:this.subdivisions, precision:this.precision});
	}

	override public function copy(id:String):Geometry {
		return new TiledGround(id, this.getScene(), this.xmin, this.zmin, this.xmax, this.zmax, this.subdivisions, this.precision, this.canBeRegenerated(), null);
	}
	
}
