package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Ground') class Ground extends _Primitive {
	
	// Members
	public var width:Float;
	public var height:Float;
	public var subdivisions:Int;
	

	public function new(id:String, scene:Scene, width:Float, height:Float, subdivisions:Int, ?canBeRegenerated:Bool, ?mesh:Mesh) {
		this.width = width;
		this.height = height;
		this.subdivisions = subdivisions;

		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateGround({ width: this.width, height: this.height, subdivisions: this.subdivisions });
	}

	override public function copy(id:String):Geometry {
		return new Ground(id, this.getScene(), this.width, this.height, this.subdivisions, this.canBeRegenerated(), null);
	}
	
	public static function Parse(parsedGround:Dynamic, scene:Scene):Ground {
        if (Geometry.Parse(parsedGround, scene) == null) {
            return null; // null since geometry could be something else than a ground...
        }
		
        var ground = new Ground(parsedGround.id, scene, parsedGround.width, parsedGround.height, parsedGround.subdivisions, parsedGround.canBeRegenerated, null);
        Tags.AddTagsTo(ground, parsedGround.tags);
		
        scene.pushGeometry(ground, true);
		
        return ground;
    }
	
}
