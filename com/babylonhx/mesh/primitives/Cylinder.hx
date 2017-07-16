package com.babylonhx.mesh.primitives;

import com.babylonhx.tools.Tags;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Cylinder') class Cylinder extends _Primitive {
	
	// Members
	public var height:Float;
	public var diameterTop:Float;
	public var diameterBottom:Float;
	public var tessellation:Int;
	public var subdivisions:Int;
	public var side:Int;
	

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
