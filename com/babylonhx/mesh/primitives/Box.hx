package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Box') class Box extends _Primitive {
	
	// Members
	public var size:Float;
	public var side:Int;
	

	public function new(id:String, scene:Scene, size:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.size = size;
		this.side = side;
		
		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateBox({ size: this.size, sideOrientation: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Box(id, this.getScene(), this.size, this.canBeRegenerated(), null, this.side);
	}
	
	public static function Parse(parsedBox:Dynamic, scene:Scene):Box {
        if (Geometry.Parse(parsedBox, scene) != null) {
            return null; // null since geometry could be something else than a box...
        }
		
        var box = new Box(parsedBox.id, scene, parsedBox.size, parsedBox.canBeRegenerated, null);
        Tags.AddTagsTo(box, parsedBox.tags);
		
        scene.pushGeometry(box, true);
		
        return box;
    }
	
}
