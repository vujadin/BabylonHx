package com.gamestudiohx.babylonhx;

import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Vector3;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Node {
	
	public var name:String;
	public var id:String;
	public var parent:Node;
	public var position:Vector3;
    public var _childrenFlag:Int;
    public var _isReady:Bool;
    public var _isEnabled:Bool;
	public var _scene:Scene;
	
	public var _cache:Dynamic;

	public function new(scene:Scene) {
		this._scene = scene;
		this.parent = null;
		this._childrenFlag = -1;
		this._isReady = true;
		this._isEnabled = true;
		
		this._cache = {
			parent: null
		};
	}
	
	public function _initCache() {
        this._cache = {
			parent: null
		};
    }
	
	public function updateCache(force:Bool = true) {
        if (!force && this.isSynchronized())
            return;

        this._cache.parent = this.parent;

        this._updateCache();
    }
	
	public function _updateCache(ignoreParentClass:Bool = true) {
		
    }
	
	public function _isSynchronized():Bool {
        return true;
    }
	
	public function _syncChildFlag() {
        this._childrenFlag = this.parent != null ? this.parent._childrenFlag : this._scene.getRenderId();
    }
	
	public function isSynchronizedWithParent():Bool {
        return this.parent != null ? !this.parent._needToSynchonizeChildren(this._childrenFlag) : true;
    }
	
	public function isSynchronized(updateCache:Bool = true):Bool {		
        var check = this.hasNewParent();
        check = check || !this.isSynchronizedWithParent();
        check = check || !this._isSynchronized();
		
        if (updateCache) {
            this.updateCache(true);
		}

        return !check;
    }
	
	public function hasNewParent(update:Bool = true):Bool {
        if (this._cache.parent == this.parent)
            return false;

        if (update)
            this._cache.parent = this.parent;

        return true;
    }
	
	public function _needToSynchonizeChildren(childFlag:Int):Bool {
		return this._childrenFlag != childFlag;
	}
	
	public function isReady():Bool {
		return this._isReady;
	}
	
	public function isEnabled():Bool {
		if (!this.isReady() || !this._isEnabled) {
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
            var item:Node = list[index];
            if (item.isDescendantOf(this)) {
                results.push(item);
            }
        }
	}
	
	public function getWorldMatrix():Matrix {
		return null;
	}
	
	public function getDescendants():Array<Node> {
		var results:Array<Node> = [];
        this._getDescendants(cast this._scene.meshes, results);
        this._getDescendants(cast this._scene.lights, results);
        this._getDescendants(cast this._scene.cameras, results);

        return results;
	}
	
}
