package com.babylonhx;

import com.babylonhx.math.Matrix;
import com.babylonhx.animations.Animation;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.Node.NodeCache;

/**
 * ...
 * @author Krtolica Vujadin
 */

class NodeCache {
	
	public var parent:Node;
	
	// AbstractMesh
	public var position:Vector3;
	public var scaling:Vector3;
	public var pivotMatrixUpdated:Bool;
	public var rotationQuaternion:Quaternion;
	public var localMatrixUpdated:Bool;
	public var rotation:Vector3;
	public var upVector:Vector3;
	public var billboardMode:Int;
	
	// Camera
	public var mode:Null<Int>;
	public var minZ:Null<Float>;
	public var maxZ:Null<Float>;
	public var fov:Null<Float>;
	public var aspectRatio:Null<Float>;
	public var orthoLeft:Null<Float>;
	public var orthoRight:Null<Float>;
	public var orthoTop:Null<Float>;
	public var orthoBottom:Null<Float>;
	public var renderWidth:Null<Int>;
	public var renderHeight:Null<Int>;
	
	// TargetCamera
	public var lockedTarget:Vector3;
	
	// ArcRotateCamera
	public var target:Vector3;
	public var alpha:Null<Float>;
	public var beta:Null<Float>;
	public var gamma:Null<Float>;
	public var radius:Null<Float>;
	public var targetScreenOffset:Vector2;
	
	
	public function new() {
		//...
	}
	
}

@:expose('BABYLON.Node') class Node implements ISmartArrayCompatible {
	
	public var parent:Node;
	public var name:String;
	public var id:String;
	public var uniqueId:Int;
	public var state:String = "";

	public var animations:Array<Animation> = [];

	public var onReady:Node->Void;

	private var _childrenFlag:Int = -1;
	private var _isEnabled:Bool = true;
	private var _isReady:Bool = true;
	public var _currentRenderId:Int = -1;
	private var _parentRenderId:Int = -1;
	
	public var __smartArrayFlags:Array<Int> = [];

	public var _waitingParentId:Null<String>;

	private var _scene:Scene;
	public var _cache:NodeCache;
	

	public function new(name:String, scene:Scene) {
		this.name = name;
		this.id = name;
		this._scene = scene;
		this._initCache();
	}
	
	inline public function getScene():Scene {
		return this._scene;
	}

	inline public function getEngine():Engine {
		return this._scene.getEngine();
	}

	// override it in derived class
	public function getWorldMatrix():Matrix {
		return Matrix.Identity();
	}
	
	// override it in derived class if you add new variables to the cache
	// and call the parent class method
	public function _initCache() {
		this._cache = new NodeCache();
		this._cache.parent = null;
	}

	public function updateCache(force:Bool = false) {
		if (!force && this.isSynchronized()) {
			return;
		}
		
		this._cache.parent = this.parent;
		this._updateCache();
	}

	// override it in derived class if you add new variables to the cache
	// and call the parent class method if !ignoreParentClass
	public function _updateCache(ignoreParentClass:Bool = false) {
		
	}

	// override it in derived class if you add new variables to the cache
	public function _isSynchronized():Bool {
		return true;
	}
	
	inline public function _markSyncedWithParent() {
        this._parentRenderId = this.parent._currentRenderId;
    }

	public function isSynchronizedWithParent():Bool {
		if (this.parent == null) {
			return true;
		}
		
		if (this._parentRenderId != this.parent._currentRenderId) {
			return false;
		}
			
		return this.parent.isSynchronized();
	}

	inline public function isSynchronized(updateCache:Bool = false):Bool {
		var check = this.hasNewParent();
		check = check || !this.isSynchronizedWithParent();
		check = check || !this._isSynchronized();
		if (updateCache) {
			this.updateCache(true);
		}
		
		return !check;
	}

	public function hasNewParent(update:Bool = false):Bool {
		if (this._cache.parent == this.parent) {
			return false;
		}
		
		if (update) {
			this._cache.parent = this.parent;
		}
		
		return true;
	}

	public function isReady():Bool {
		return this._isReady;
	}

	public function isEnabled():Bool {
		if (!this._isEnabled) {
			return false;
		}
		
		if (this.parent != null) {
			return this.parent.isEnabled();
		}
		
		return true;
	}

	/**
	 * Set the enabled state of this node.
	 * @param {boolean} value - the new enabled state
	 * @see isEnabled
	 */
	inline public function setEnabled(value:Bool) {
		this._isEnabled = value;
	}

	/**
	 * Is this node a descendant of the given node.
	 * The function will iterate up the hierarchy until the ancestor was found or no more parents defined.
	 * @param {BABYLON.Node} ancestor - The parent node to inspect
	 * @see parent
	 */
	public function isDescendantOf(ancestor:Node):Bool {
		if (this.parent != null) {
			if (this.parent == ancestor) {
				return true;
			}
			
			return this.parent.isDescendantOf(ancestor);
		}
		return false;
	}

	inline public function _getDescendants(list:Array<Node>, results:Array<Node>) {
		for (index in 0...list.length) {
			var item = list[index];
			if (item.isDescendantOf(this)) {
				results.push(item);
			}
		}
	}

	/**
	 * Will return all nodes that have this node as parent.
	 * @return {BABYLON.Node[]} all children nodes of all types.
	 */
	inline public function getDescendants():Array<Node> {
		var results:Array<Node> = [];
		this._getDescendants(cast this._scene.meshes, results);
		this._getDescendants(cast this._scene.lights, results);
		this._getDescendants(cast this._scene.cameras, results);
		
		return results;
	}

	public function _setReady(state:Bool) {
		if (state == this._isReady) {
			return;
		}
		
		if (!state) {
			this._isReady = false;
			return;
		}
		
		this._isReady = true;
		if (this.onReady != null) {
			this.onReady(this);
		}
	}
	
	public function getAnimationByName(name:String):Animation {
		for (i in 0...this.animations.length) {
			var animation = this.animations[i];
			
			if (animation.name == name) {
				return animation;
			}
		}
		
		return null;
	}
	
}
