package com.babylonhx.mesh.primitives;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Abstract class used to provide common services for all typed geometries
 */
@:expose('BABYLON._Primitive') class _Primitive extends Geometry {
	
	// Private 
	private var _beingRegenerated:Bool;
	private var _canBeRegenerated:Bool;
	

	/**
	 * Creates a new typed geometry
	 * @param id defines the unique ID of the geometry
	 * @param scene defines the hosting scene
	 * @param _canBeRegenerated defines if the geometry supports being regenerated with new parameters (false by default)
	 * @param mesh defines the hosting mesh (can be null)
	 */
	public function new(id:String, scene:Scene, canBeRegenerated:Bool = false, ?mesh:Mesh) {
		super(id, scene, null, false, mesh); // updatable = false to be sure not to update vertices
		this._canBeRegenerated = canBeRegenerated;
		this._beingRegenerated = true;
		this.regenerate();
		this._beingRegenerated = false;
	}

	/**
	 * Gets a value indicating if the geometry supports being regenerated with new parameters (false by default)
	 * @returns true if the geometry can be regenerated
	 */
	inline public function canBeRegenerated():Bool {
		return this._canBeRegenerated;
	}

	/**
	 * If the geometry supports regeneration, the function will recreates the geometry with updated parameter values
	 */
	public function regenerate() {
		if (!this._canBeRegenerated) {
			return;
		}
		this._beingRegenerated = true;
		this.setAllVerticesData(this._regenerateVertexData(), false);
		this._beingRegenerated = false;
	}

	/**
	 * Clone the geometry
	 * @param id defines the unique ID of the new geometry
	 * @returns the new geometry
	 */
	public function asNewGeometry(id:String):Geometry {
		return super.copy(id);
	}

	// overrides
	override public function setAllVerticesData(vertexData:VertexData, updatable:Bool = false) {
		if (!this._beingRegenerated) {
			return;
		}
		super.setAllVerticesData(vertexData, false);
	}

	override public function setVerticesData(kind:String, data:Float32Array, updatable:Bool = false, ?stride:Int) {
		if (!this._beingRegenerated) {
			return;
		}
		super.setVerticesData(kind, data, false, stride);
	}

	// to override
	// protected
	public function _regenerateVertexData():VertexData {
		throw("Abstract method");
	}

	override public function copy(id:String):Geometry {
		throw("Must be overriden in sub-classes.");
	}
	
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		
		serializationObject.canBeRegenerated = this.canBeRegenerated();
		
		return serializationObject;
	}
	
}
