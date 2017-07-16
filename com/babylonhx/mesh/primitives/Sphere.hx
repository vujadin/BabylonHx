package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Sphere') class Sphere extends _Primitive {
	
	// Members
	public var segments:Int;
	public var diameter:Float;
	public var side:Int;
	

	public function new(id:String, scene:Scene, segments:Int, diameter:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.segments = segments;
		this.diameter = diameter;
		this.side = side;
		
		super(id, scene, canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateSphere({ segments: this.segments, diameter: this.diameter, sideOrientation: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Sphere(id, this.getScene(), this.segments, this.diameter, this.canBeRegenerated(), null, this.side);
	}
	
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		
		serializationObject.segments = this.segments;
		serializationObject.diameter = this.diameter;
		
		return serializationObject;
	}
	
	public static function Parse(parsedSphere:Dynamic, scene:Scene):Sphere {
        if (Geometry.Parse(parsedSphere, scene) == null) {
            return null; // null since geometry could be something else than a sphere...
        }
		
        var sphere = new Sphere(parsedSphere.id, scene, parsedSphere.segments, parsedSphere.diameter, parsedSphere.canBeRegenerated, null);
        Tags.AddTagsTo(sphere, parsedSphere.tags);
		
        scene.pushGeometry(sphere, true);
		
        return sphere;
    }
	
}
