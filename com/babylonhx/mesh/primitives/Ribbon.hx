package com.babylonhx.mesh.primitives;

import com.babylonhx.math.Vector3;


/**
 * ...
 * @author Krtolica Vujadin
 */

class Ribbon extends _Primitive {
	
	// Members
	public var pathArray:Array<Array<Vector3>>;
	public var closeArray:Bool;
	public var closePath:Bool;
	public var offset:Int;
	public var side:Int;

	
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
