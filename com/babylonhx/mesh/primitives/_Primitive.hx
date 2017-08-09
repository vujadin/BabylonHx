package com.babylonhx.mesh.primitives;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON._Primitive') class _Primitive extends Geometry {
	
	// Private 
	private var _beingRegenerated:Bool;
	private var _canBeRegenerated:Bool;
	

	public function new(id:String, scene:Scene, canBeRegenerated:Bool = false, ?mesh:Mesh) {
		super(id, scene, null, false, mesh); // updatable = false to be sure not to update vertices
		this._canBeRegenerated = canBeRegenerated;
		this._beingRegenerated = true;
		this.regenerate();
		this._beingRegenerated = false;
	}

	inline public function canBeRegenerated():Bool {
		return this._canBeRegenerated;
	}

	public function regenerate() {
		if (!this._canBeRegenerated) {
			return;
		}
		this._beingRegenerated = true;
		this.setAllVerticesData(this._regenerateVertexData(), false);
		this._beingRegenerated = false;
	}

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
