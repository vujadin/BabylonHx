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

	
	public function new(id: string, scene: Scene, pathArray:Array<Array<Vector3>>, closeArray:Bool, closePath:Bool, offset:Int, canBeRegenerated:Bool = false, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.pathArray = pathArray;
		this.closeArray = closeArray;
		this.closePath = closePath;
		this.offset = offset;
		this.side = side;

		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateRibbon(this.pathArray, this.closeArray, this.closePath, this.offset, this.side);
	}

	override public functioncopy(id:String):Geometry {
		return new Ribbon(id, this.getScene(), this.pathArray, this.closeArray, this.closePath, this.offset, this.canBeRegenerated(), null, this.side);
	}
	
}
