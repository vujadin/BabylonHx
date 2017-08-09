package com.babylonhx.morph;

import com.babylonhx.tools.Observable;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.AbstractMesh;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MorphTarget implements ISmartArrayCompatible {
	
	private var _positions:Float32Array;
	private var _normals:Float32Array;
	private var _tangents:Float32Array;
	private var _influence:Int;
	
	public var name:String;

	public var onInfluenceChanged:Observable<Bool> = new Observable<Bool>();

	public var influence(get, set):Int;
	inline private function get_influence():Int {
		return this._influence;
	}
	private function set_influence(value:Int):Int {
		if (this._influence == value) {
			return value;
		}
		
		var previous = this._influence;
		this._influence = value;
		
		if (this.onInfluenceChanged.hasObservers()) {
			this.onInfluenceChanged.notifyObservers(previous == 0 || value == 0);
		}
		
		return value;
	}
	
	public var __smartArrayFlags:Array<Int> = [];   // BHX
	

	public function new(name:String, influence:Int = 0) {
		this.influence = influence;
	}

	public var hasNormals(get, never):Bool;
	inline private function get_hasNormals():Bool {
		return this._normals != null;
	}

	public var hasTangents(get, never):Bool;
	inline private function get_hasTangents():Bool {
		return this._tangents != null;
	}

	inline public function setPositions(data:Float32Array) {
		this._positions = new Float32Array(data);
	}

	inline public function getPositions():Float32Array {
		return this._positions;
	}

	inline public function setNormals(data:Float32Array) {
		this._normals = new Float32Array(data);
	}

	inline public function getNormals():Float32Array {
		return this._normals;
	}

	inline public function setTangents(data:Float32Array) {
		this._tangents = new Float32Array(data);
	}

	inline public function getTangents():Float32Array {
		return this._tangents;
	}
	
	public function dispose(_:Bool = false) {
		this._positions = null;
		this._normals = null;
		this._tangents = null;
		this.__smartArrayFlags = null;
		this.onInfluenceChanged.clear();
		this.onInfluenceChanged = null;
	}

	/**
	 * Serializes the current target into a Serialization object.  
	 * Returns the serialized object.  
	 */
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.name = this.name;
		serializationObject.influence = this.influence;
		
		serializationObject.positions = this.getPositions();
		if (this.hasNormals) {
			serializationObject.normals = this.getNormals();
		}
		if (this.hasTangents) {
			serializationObject.tangents = this.getTangents();
		}
		
		return serializationObject;
	}

	// Statics
	public static function Parse(serializationObject:Dynamic):MorphTarget {
		var result = new MorphTarget(serializationObject.name , serializationObject.influence);
		
		result.setPositions(serializationObject.positions);
		
		if (serializationObject.normals != null) {
			result.setNormals(serializationObject.normals);
		}
		if (serializationObject.tangents != null) {
			result.setTangents(serializationObject.tangents);
		}
		
		return result;
	}

	public static function FromMesh(mesh:AbstractMesh, ?name:String, ?influence:Int):MorphTarget {
		if (name == null) {
			name = mesh.name;
		}
		
		var result = new MorphTarget(name, influence);
		
		result.setPositions(mesh.getVerticesData(VertexBuffer.PositionKind));
		
		if (mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			result.setNormals(mesh.getVerticesData(VertexBuffer.NormalKind));
		}
		if (mesh.isVerticesDataPresent(VertexBuffer.TangentKind)) {
			result.setTangents(mesh.getVerticesData(VertexBuffer.TangentKind));
		}
		
		return result;
	}
	
}
