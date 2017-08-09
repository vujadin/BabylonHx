package com.babylonhx.morph;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MorphTargetManager {

	private var _targets:Array<MorphTarget> = [];
	private var _targetObservable:Array<Observer<Bool>> = [];
	private var _activeTargets:SmartArray<MorphTarget> = new SmartArray<MorphTarget>(16);
	private var _scene:Scene;
	private var _influences:Float32Array;
	private var _supportsNormals:Bool = false;
	private var _supportsTangents:Bool = false;
	private var _vertexCount:Int = 0;
	private var _uniqueId:Int = 0;
	private var _tempInfluences:Array<Int> = [];
	

	public function new(?scene:Scene) {
		if (scene == null) {
			scene = Engine.LastCreatedScene;
		}
		
		this._scene = scene;
		this._scene.morphTargetManagers.push(this);
		this._uniqueId = scene.getUniqueId();
	}

	public var uniqueId(get, never):Int;
	inline private function get_uniqueId():Int {
		return this._uniqueId;
	}
	
	public var vertexCount(get, never):Int;
	inline private function get_vertexCount():Int {
		return this._vertexCount;
	}
	
	public var supportsNormals(get, never):Bool;
	inline private function get_supportsNormals():Bool {
		return this._supportsNormals;
	}

	public var supportsTangents(get, never):Bool;
	inline private function get_supportsTangents():Bool {
		return this._supportsTangents;
	}

	public var numTargets(get, never):Int;
	inline private function get_numTargets():Int {
		return this._targets.length;
	}

	public var numInfluencers(get, never):Int;
	inline private function get_numInfluencers():Int {
		return this._activeTargets.length;
	}

	public var influences(get, never):Float32Array;
	inline private function get_influences():Float32Array {
		return this._influences;
	}

	inline public function getActiveTarget(index:Int):MorphTarget {
		return this._activeTargets.data[index];
	}

	inline public function getTarget(index:Int):MorphTarget {
		return this._targets[index];
	}
   
	public function addTarget(target:MorphTarget) {
		if (this._vertexCount > 0) {
			if (this._vertexCount != Std.int(target.getPositions().length / 3)) {
				Tools.Error("Incompatible target. Targets must all have the same vertices count.");
				return;
			}
		}
		
		this._targets.push(target);
		this._targetObservable.push(target.onInfluenceChanged.add(function(needUpdate:Bool, _) {
			this._syncActiveTargets(needUpdate);
		}));
		this._syncActiveTargets(true);        
	}

	public function removeTarget(target:MorphTarget) {
		var index = this._targets.indexOf(target);
		if (index >= 0) {
			this._targets.splice(index, 1);
			
			target.onInfluenceChanged.remove(this._targetObservable.splice(index, 1)[0]);
			this._vertexCount = 0;
			this._syncActiveTargets(true);
		}
	}

	/**
	 * Serializes the current manager into a Serialization object.  
	 * Returns the serialized object.  
	 */
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.id = this.uniqueId;
		
		serializationObject.targets = [];
		for (target in this._targets) {
			serializationObject.targets.push(target.serialize());
		}
		
		return serializationObject;
	}

	inline private function _onInfluenceChanged(needUpdate:Bool) {
		this._syncActiveTargets(needUpdate);
	}

	private function _syncActiveTargets(needUpdate:Bool) {
		var influenceCount:Int = 0;
		this._activeTargets.reset();
		this._supportsNormals = true;
		this._supportsTangents = true;
		for (target in this._targets) {
			if (target.influence > 0) {
				this._activeTargets.push(target);
				this._tempInfluences[influenceCount++] = target.influence;
				
				this._supportsNormals = this._supportsNormals && target.hasNormals;
				this._supportsTangents = this._supportsTangents && target.hasTangents;
				
				if (this._vertexCount == 0) {
					this._vertexCount = Std.int(target.getPositions().length / 3);
				}
			}
		}
		
		if (this._influences == null || this._influences.length != influenceCount) {
            this._influences = new Float32Array(influenceCount);
        }
		
        for (index in 0...influenceCount) {
            this._influences[index] = this._tempInfluences[index];
        }
		
		if (needUpdate) {
			// Flag meshes as dirty to resync with the active targets
			for (mesh in this._scene.meshes) {
				if (mesh.getClassName() == 'Mesh' && untyped mesh.morphTargetManager == this) {
					untyped mesh._syncGeometryWithMorphTargetManager();
				}
			}
		}
	}

	// Statics
	public static function Parse(serializationObject:Dynamic, scene:Scene):MorphTargetManager {
		var result = new MorphTargetManager(scene);
		
		result._uniqueId = serializationObject.id;
		
		var targets:Array<Dynamic> = cast serializationObject.targets;
		for (targetData in targets) {
			result.addTarget(MorphTarget.Parse(targetData));
		}
		
		return result;
	}
	
}
