package com.babylonhx;

import com.babylonhx.math.Matrix;
import com.babylonhx.animations.Animation;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Node') class Node implements ISmartArrayCompatible {
	
	public var parent:Node;
	public var name:String;
	public var id:String;
	public var state:String = "";

	public var animations:Array<Animation> = [];

	public var onReady:Node->Void;

	private var _childrenFlag:Int = -1;
	private var _isEnabled:Bool = true;
	private var _isReady:Bool = true;
	public var _currentRenderId:Int = -1;
	
	public var __smartArrayFlags:Array<Int>;

	public var _waitingParentId:Null<String>;

	private var _scene:Scene;
	public var _cache:Dynamic;
	

	public function new(name:String, scene:Scene) {
		this.name = name;
		this.id = name;
		this._scene = scene;
		this._initCache();
	}
	
	public function getScene():Scene {
		return this._scene;
	}

	public function getEngine():Engine {
		return this._scene.getEngine();
	}

	// override it in derived class
	public function getWorldMatrix():Matrix {
		return null;// Matrix.Identity();
	}

	// override it in derived class if you add new variables to the cache
	// and call the parent class method
	public function _initCache() {
		this._cache = {};
		this._cache.parent = null;
	}

	public function updateCache(force:Bool = false/*?force:Bool*/) {
		if (!force && this.isSynchronized()) {
			return;
		}
		
		this._cache.parent = this.parent;
		this._updateCache();
	}

	// override it in derived class if you add new variables to the cache
	// and call the parent class method if !ignoreParentClass
	public function _updateCache(ignoreParentClass:Bool = false/*?ignoreParentClass:Bool*/) {
		
	}

	// override it in derived class if you add new variables to the cache
	public function _isSynchronized():Bool {
		return true;
	}

	public function isSynchronizedWithParent():Bool {
		return this.parent != null ? this.parent._currentRenderId <= this._currentRenderId : true;
	}

	public function isSynchronized(updateCache:Bool = false/*?updateCache:Bool*/):Bool {
		var check = this.hasNewParent();
		check = check || !this.isSynchronizedWithParent();
		check = check || !this._isSynchronized();
		if (updateCache) {
			this.updateCache(true);
		}
		
		return !check;
	}

	public function hasNewParent(update:Bool = false/*?update:Bool*/):Bool {
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

	public function setEnabled(value:Bool) {
		this._isEnabled = value;
	}

	public function isDescendantOf(ancestor:Node):Bool {
		if (this.parent != null) {
			if (this.parent == ancestor) {
				return true;
			}
			
			return this.parent.isDescendantOf(ancestor);
		}
		return false;
	}

	public function _getDescendants(list:Array<Node>, results:Array<Node>) {
		for (index in 0...list.length) {
			var item = list[index];
			if (item.isDescendantOf(this)) {
				results.push(item);
			}
		}
	}

	public function getDescendants():Array<Node> {
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
	
}
