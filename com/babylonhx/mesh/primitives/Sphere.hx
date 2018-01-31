package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * A sphere geometry
 * @description see http://doc.babylonjs.com/how_to/set_shapes#sphere
 */
@:expose('BABYLON.Sphere') class Sphere extends _Primitive {
	
	/**
	 * Defines the number of segments to use to create the sphere
	 */
	public var segments:Int;
	/**
	 * Defines the diameter of the sphere
	 */
	public var diameter:Float;
	/**
	 * Defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE) 
	 */
	public var side:Int;
	

	/**
	 * Create a new sphere geometry
	 * @param id defines the unique ID of the geometry
	 * @param scene defines the hosting scene
	 * @param segments defines the number of segments to use to create the sphere
	 * @param diameter defines the diameter of the sphere
	 * @param canBeRegenerated defines if the geometry supports being regenerated with new parameters (false by default)
	 * @param mesh defines the hosting mesh (can be null)
	 * @param side defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE) 
	 */
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
