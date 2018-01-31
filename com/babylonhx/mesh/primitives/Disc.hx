package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * A disc geometry
 * @description see http://doc.babylonjs.com/how_to/set_shapes#disc-or-regular-polygon
 */
class Disc extends _Primitive {
	
	/**
	 * Defines the radius of the disc
	 */
	public var radius:Float;
	/**
	 * Defines the tesselation factor to apply to the disc
	 */
	public var tessellation:Float;
	/**
	 * Defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE) 
	 */
	public var side:Int;
	

	/**
	 * Creates a new disc geometry
	 * @param id defines the unique ID of the geometry
	 * @param scene defines the hosting scene
	 * @param radius defines the radius of the disc
	 * @param tessellation defines the tesselation factor to apply to the disc
	 * @param canBeRegenerated defines if the geometry supports being regenerated with new parameters (false by default)
	 * @param mesh defines the hosting mesh (can be null)
	 * @param side defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE) 
	 */
	public function new(id:String, scene:Scene, radius:Float, tessellation:Float, canBeRegenerated:Bool = false, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		super(id, scene, canBeRegenerated, mesh);
		
		this.radius = radius;
		this.tessellation = tessellation;
		this.side = side;
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateDisc({ radius: this.radius, tessellation: this.tessellation, sideOrientation: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Disc(id, this.getScene(), this.radius, this.tessellation, this.canBeRegenerated(), null, this.side);
	}
	
}
