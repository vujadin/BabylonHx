package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * A box geometry
 * @description see http://doc.babylonjs.com/how_to/set_shapes#box
 */
@:expose('BABYLON.Box') class Box extends _Primitive {
	
	/**
	 * Defines the zise of the box (width, height and depth are the same)
	 */
	public var size:Float;
	/**
	 * Defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE) 
	 */
	public var side:Int;
	

	/**
	 * Creates a box geometry
	 * @param id defines the unique ID of the geometry
	 * @param scene defines the hosting scene
	 * @param size defines the zise of the box (width, height and depth are the same)
	 * @param canBeRegenerated defines if the geometry supports being regenerated with new parameters (false by default)
	 * @param mesh defines the hosting mesh (can be null)
	 * @param side defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE) 
	 */
	public function new(id:String, scene:Scene, size:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.size = size;
		this.side = side;
		
		super(id, scene, canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateBox({ size: this.size, sideOrientation: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Box(id, this.getScene(), this.size, this.canBeRegenerated(), null, this.side);
	}
	
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		
		serializationObject.size = this.size;
		
		return serializationObject;
	}
	
	public static function Parse(parsedBox:Dynamic, scene:Scene):Box {
        if (scene.getGeometryByID(parsedBox.id) != null) {
            return null; // null since geometry could be something else than a box...
        }
		
        var box = new Box(parsedBox.id, scene, parsedBox.size, parsedBox.canBeRegenerated, null);
        Tags.AddTagsTo(box, parsedBox.tags);
		
        scene.pushGeometry(box, true);
		
        return box;
    }
	
}
