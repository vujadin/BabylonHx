package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Cylinder geometry
 * @description see http://doc.babylonjs.com/how_to/set_shapes#cylinder-or-cone
 */
@:expose('BABYLON.Cylinder') class Cylinder extends _Primitive {
	
	/**
	 * Defines the height of the cylinder
	 */
	public var height:Float;
	/**
	 * Defines the diameter of the cylinder's top cap
	 */
	public var diameterTop:Float;
	/**
	 * Defines the diameter of the cylinder's bottom cap
	 */
	public var diameterBottom:Float;
	/**
	 * Defines the tessellation factor to apply to the cylinder
	 */
	public var tessellation:Int;
	/**
	 * Defines the number of subdivisions to apply to the cylinder (1 by default)
	 */
	public var subdivisions:Int;
	/**
	 * Defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE)
	 */
	public var side:Int;
	

	/**
	 * Creates a new cylinder geometry
	 * @param id defines the unique ID of the geometry
	 * @param scene defines the hosting scene
	 * @param height defines the height of the cylinder
	 * @param diameterTop defines the diameter of the cylinder's top cap
	 * @param diameterBottom defines the diameter of the cylinder's bottom cap
	 * @param tessellation defines the tessellation factor to apply to the cylinder (number of radial sides)
	 * @param subdivisions defines the number of subdivisions to apply to the cylinder (number of rings) (1 by default)
	 * @param canBeRegenerated defines if the geometry supports being regenerated with new parameters (false by default)
	 * @param mesh defines the hosting mesh (can be null)
	 * @param side defines if the created geometry is double sided or not (default is BABYLON.Mesh.DEFAULTSIDE) 
	 */
	public function new(id:String, scene:Scene, height:Float, diameterTop:Float, diameterBottom:Float, tessellation:Int, subdivisions:Int = 1, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE) {
		this.height = height;
		this.diameterTop = diameterTop;
		this.diameterBottom = diameterBottom;
		this.tessellation = tessellation;
		this.subdivisions = subdivisions;
		this.side = side;
		
		super(id, scene, canBeRegenerated, mesh);
	}

	override public function _regenerateVertexData():VertexData {
		return VertexData.CreateCylinder({ height: this.height, diameterTop: this.diameterTop, diameterBottom: this.diameterBottom, tesselation: this.tessellation, subdivisions: this.subdivisions, sideOrientation: this.side });
	}

	override public function copy(id:String):Geometry {
		return new Cylinder(id, this.getScene(), this.height, this.diameterTop, this.diameterBottom, this.tessellation, this.subdivisions, this.canBeRegenerated(), null, this.side);
	}
	
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		
		serializationObject.height = this.height;
		serializationObject.diameterTop = this.diameterTop;
		serializationObject.diameterBottom = this.diameterBottom;
		serializationObject.tessellation = this.tessellation;
		
		return serializationObject;
	}
	
	public static function Parse(parsedCylinder:Dynamic, scene:Scene):Cylinder {
        if (Geometry.Parse(parsedCylinder, scene) == null) {
            return null; // null since geometry could be something else than a cylinder...
        }
		
        var cylinder = new Cylinder(parsedCylinder.id, scene, parsedCylinder.height, parsedCylinder.diameterTop, parsedCylinder.diameterBottom, parsedCylinder.tessellation, parsedCylinder.subdivisions, parsedCylinder.canBeRegenerated, null);
        Tags.AddTagsTo(cylinder, parsedCylinder.tags);
		
        scene.pushGeometry(cylinder, true);
		
        return cylinder;
    }
	
}
