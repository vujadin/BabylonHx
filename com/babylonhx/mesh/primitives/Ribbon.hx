package com.babylonhx.mesh.primitives;

import com.babylonhx.math.Vector3;


/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * A ribbon geometry
 * @description See http://doc.babylonjs.com/how_to/ribbon_tutorial, http://doc.babylonjs.com/resources/maths_make_ribbons 
 */
class Ribbon extends _Primitive {
	
	/**
	 * Defines the array of paths to use
	 */
	public var pathArray:Array<Array<Vector3>>;
	/**
	 * Defines if the last and first points of each path in your pathArray must be joined
	 */
	public var closeArray:Bool;
	/**
	 * Defines if the last and first points of each path in your pathArray must be joined
	 */
	public var closePath:Bool;
	/**
	 * Defines the offset between points 
	 */
	public var offset:Int;
	/**
	 * Defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE)
	 */
	public var side:Int;

	
	/**
	 * Creates a ribbon geometry
	 * @param id defines the unique ID of the geometry
	 * @param scene defines the hosting scene
	 * @param pathArray defines the array of paths to use
	 * @param closeArray defines if the last path and the first path must be  joined
	 * @param closePath defines if the last and first points of each path in your pathArray must be joined
	 * @param offset defines the offset between points 
	 * @param canBeRegenerated defines if the geometry supports being regenerated with new parameters (false by default)
	 * @param mesh defines the hosting mesh (can be null)
	 * @param side defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE)
	 */
	public function new(id:String, scene: Scene, pathArray:Array<Array<Vector3>>, closeArray:Bool, closePath:Bool, offset:Int, canBeRegenerated:Bool = false, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.pathArray = pathArray;
		this.closeArray = closeArray;
		this.closePath = closePath;
		this.offset = offset;
		this.side = side;
		
		super(id, scene, canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateRibbon({ pathArray: this.pathArray, closeArray: this.closeArray, closePath: this.closePath, offset: this.offset, side: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Ribbon(id, this.getScene(), this.pathArray, this.closeArray, this.closePath, this.offset, this.canBeRegenerated(), null, this.side);
	}
	
}
