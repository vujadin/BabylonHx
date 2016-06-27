package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Torus') class Torus extends _Primitive {
	
	// Members
	public var diameter:Float;
	public var thickness:Float;
	public var tessellation:Int;
	public var side:Int;
	

	public function new(id:String, scene:Scene, diameter:Float, thickness:Float, tessellation:Int, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.diameter = diameter;
		this.thickness = thickness;
		this.tessellation = tessellation;
		this.side = side;
		
		super(id, scene, this._regenerateVertexData(), canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateTorus({ diameter: this.diameter, thickness: this.thickness, tesselation: this.tessellation, sideOrientation: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Torus(id, this.getScene(), this.diameter, this.thickness, this.tessellation, this.canBeRegenerated(), null, this.side);
	}
	
	public static function Parse(parsedTorus:Dynamic, scene:Scene):Geometry {
        if (Geometry.Parse(parsedTorus, scene) == null) {
            return null; // null since geometry could be something else than a torus...
        }
		
        var torus = new Torus(parsedTorus.id, scene, parsedTorus.diameter, parsedTorus.thickness, parsedTorus.tessellation, parsedTorus.canBeRegenerated, null);
        Tags.AddTagsTo(torus, parsedTorus.tags);
		
        scene.pushGeometry(torus, true);
		
        return torus;
    }
	
}
