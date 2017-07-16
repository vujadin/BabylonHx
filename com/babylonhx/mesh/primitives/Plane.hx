package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Plane') class Plane extends _Primitive {
	
	// Members
	public var size:Float;
	public var side:Int;
	

	public function new(id:String, scene:Scene, size:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.size = size;
		this.side = side;
		
		super(id, scene, canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreatePlane({ width: this.size, height: this.size, sideOrientation: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Plane(id, this.getScene(), this.size, this.canBeRegenerated(), null, this.side);
	}
	
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		
		serializationObject.size = this.size;
		
		return serializationObject;
	}
	
	public static function Parse(parsedPlane:Dynamic, scene:Scene):Geometry {
        if (Geometry.Parse(parsedPlane, scene) == null) {
            return null; // null since geometry could be something else than a plane...
        }
		
        var plane = new com.babylonhx.mesh.primitives.Plane(parsedPlane.id, scene, parsedPlane.size, parsedPlane.canBeRegenerated, null);
        Tags.AddTagsTo(plane, parsedPlane.tags);
		
        scene.pushGeometry(plane, true);
		
        return plane;
    }
	
}
