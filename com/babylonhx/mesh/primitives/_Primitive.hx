package com.babylonhx.mesh.primitives;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON._Primitive') class _Primitive extends Geometry {
	
	// Private 
	private var _beingRegenerated:Bool;
	private var _canBeRegenerated:Bool;
	

	public function new(id:String, scene:Scene, ?vertexData:VertexData, canBeRegenerated:Bool = false/*?canBeRegenerated:Bool*/, ?mesh:Mesh) {
		this._beingRegenerated = true;
		this._canBeRegenerated = canBeRegenerated;
		super(id, scene, vertexData, false, mesh); // updatable = false to be sure not to update vertices
		this._beingRegenerated = false;
	}

	public function canBeRegenerated():Bool {
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
	override public function setAllVerticesData(vertexData:VertexData, updatable:Bool = false/*?updatable:Bool*/) {
		if (!this._beingRegenerated) {
			return;
		}
		super.setAllVerticesData(vertexData, false);
	}

	override public function setVerticesData(kind:String, data:Array<Float>, updatable:Bool = false/*?updatable:Bool*/, ?stride:Int) {
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
	
}
