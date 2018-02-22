package com.babylonhx;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Matrix;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.AnimationRange;
import com.babylonhx.behaviors.Behavior;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.TransformNode;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tools;

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
	public var fovMode:Null<Int>;
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

/**
 * Node is the basic class for all scene objects (Mesh, Light Camera).
 */
@:expose('BABYLON.Node') class Node implements ISmartArrayCompatible {
	
	/**
	 * Gets or sets the name of the node
	 */
	@serialize()
	public var name:String;
	
	/**
	 * Gets or sets the id of the node
	 */
	@serialize()
	public var id:String;
	
	/**
	 * Gets or sets the unique id of the node
	 */
	@serialize()
	public var uniqueId:Int;
	
	/**
	 * Gets or sets a string used to store user defined state for the node
	 */
	@serialize()
	public var state:String = "";
	
	/**
	 * Gets or sets an object used to store user defined information for the node
	 */
	@serialize()
    public var metadata:Dynamic = null;
	
	/**
	 * Gets or sets a boolean used to define if the node must be serialized
	 */
	public var doNotSerialize:Bool = false;
	
	/** @ignore */
	public var _isDisposed:Bool = false;

	/**
	 * Gets a list of {BABYLON.Animation} associated with the node
	 */
	public var animations:Array<Animation> = [];
	private var _ranges:Map<String, AnimationRange> = new Map();

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
	
	private var _parentNode:Node = null;
	private var _children:Array<Node>;
	
	/**
	 * Gets a boolean indicating if the node has been disposed
	 * @returns true if the node was disposed
	 */
	public var isDisposed(get, never):Bool;
	inline function get_isDisposed():Bool {
		return this._isDisposed;
	} 
	
	/**
	 * Gets or sets the parent of the node
	 */
	public var parent(get, set):Node;
	private function set_parent(parent:Node):Node {
		if (this._parentNode == parent) {
			return parent;
		}
		
		// Remove self from list of children of parent
		if (this._parentNode != null && this._parentNode._children != null) {
			var index = this._parentNode._children.indexOf(this);
			if (index != -1) {
				this._parentNode._children.splice(index, 1);
			}
		}
		
		// Store new parent
		this._parentNode = parent;
		
		// Add as child to new parent
		if (this._parentNode != null) {
			if (this._parentNode._children == null) {
				this._parentNode._children = new Array<Node>();
			}
			this._parentNode._children.push(this);
		}
		
		return parent;
	}
	inline private function get_parent():Node {
		return this._parentNode;
	}
	
	/**
	 * Gets a string idenfifying the name of the class
	 * @returns "Node" string
	 */
	public function getClassName():String {
		return "Node";
	}
	
	/**
	* An event triggered when the node is disposed.
	* @type {BABYLON.Observable}
	*/
	public var onDisposeObservable:Observable<Node> = new Observable<Node>();
	private var _onDisposeObserver:Observer<Node>;
	public var onDispose(never, set):Node->Null<EventState>->Void;
	/**
	 * Sets a callback that will be raised when the node will be disposed
	 */
	private function set_onDispose(callback:Node->Null<EventState>->Void) {
		if (this._onDisposeObserver != null) {
			this.onDisposeObservable.remove(this._onDisposeObserver);
		}
		this._onDisposeObserver = this.onDisposeObservable.add(callback);
		
		return callback;
	}
	
	public var __serializableMembers:Dynamic;
	
	public var tags:Dynamic = { };
	
	
	/**
	 * Creates a new Node
	 * @param {string} name - the name and id to be given to this node
	 * @param {BABYLON.Scene} the scene this node will be added to
	 */
	public function new(name:String, scene:Scene = null) {
		this.name = name;
		this.id = name;
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
		this.uniqueId = this._scene.getUniqueId();
		this._initCache();
	}
	
	/**
	 * Gets the scene of the node
	 * @returns a {BABYLON.Scene}
	 */
	inline public function getScene():Scene {
		return this._scene;
	}

	/**
	 * Gets the engine of the node
	 * @returns a {BABYLON.Engine}
	 */
	inline public function getEngine():Engine {
		return this._scene.getEngine();
	}
	
	// Behaviors
	private var _behaviors:Array<Behavior<Node>> = [];
	public var behaviors(get, never):Array<Behavior<Node>>;

	var observer:Observer<Scene> = null;
	/**
	 * Attach a behavior to the node
	 * @see http://doc.babylonjs.com/features/behaviour
	 * @param behavior defines the behavior to attach
	 * @returns the current Node
	 */
	public function addBehavior(behavior:Behavior<Node>):Node {
		var index = this._behaviors.indexOf(behavior);
		
		if (index != -1) {
			return null;
		}
		
		behavior.init();
		if (this._scene.isLoading) {
			// We defer the attach when the scene will be loaded
			observer = this._scene.onDataLoadedObservable.add(function(_, _) {
				behavior.attach(this);
				Tools.delay(function() {
					// Need to use a timeout to avoid removing an observer while iterating the list of observers
					this._scene.onDataLoadedObservable.remove(observer);
				}, 0);
			});
		} 
		else {
			behavior.attach(this);
		}
		this._behaviors.push(behavior);
		
		return this;
	}

	/**
	 * Remove an attached behavior
	 * @see http://doc.babylonjs.com/features/behaviour
	 * @param behavior defines the behavior to attach
	 * @returns the current Node
	 */
	public function removeBehavior(behavior:Behavior<Node>):Node {
		var index = this._behaviors.indexOf(behavior);
		
		if (index == -1) {
			return null;
		}
		
		this._behaviors[index].detach();
		this._behaviors.splice(index, 1);
		
		return this;
	}     
	
	/**
	 * Gets the list of attached behaviors
	 * @see http://doc.babylonjs.com/features/behaviour
	 */
	inline private function get_behaviors():Array<Behavior<Node>> {
		return this._behaviors;
	}

	/**
	 * Gets an attached behavior by name
	 * @param name defines the name of the behavior to look for
	 * @see http://doc.babylonjs.com/features/behaviour
	 * @returns null if behavior was not found else the requested behavior
	 */
	public function getBehaviorByName(name:String):Behavior<Node> {
		for (behavior in this._behaviors) {
			if (behavior.name == name) {
				return behavior;
			}
		}
		
		return null;
	}

	/**
	 * Returns the world matrix of the node
	 * @returns a matrix containing the node's world matrix
	 */
	public function getWorldMatrix():Matrix {
		// override it in derived class
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
	public function _updateCache(ignoreParentClass:Bool = false) { }

	// override it in derived class if you add new variables to the cache
	public function _isSynchronized():Bool {
		return true;
	}
	
	inline public function _markSyncedWithParent() {
		if (this.parent != null) {
			this._parentRenderId = this.parent._currentRenderId;
		}
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

	/**
	 * Is this node ready to be used/rendered
	 * @return {boolean} is it ready
	 */
	public function isReady(completeCheck:Bool = false, forceInstanceSupport:Bool = false):Bool {
		return this._isReady;
	}

	/**
	 * Is this node enabled. 
	 * If the node has a parent and is enabled, the parent will be inspected as well.
	 * If the node has a parent, all ancestors will be checked and false will be returned if any are false (not enabled), otherwise will return true.
     * @param {boolean} [checkAncestors=true] - Indicates if this method should check the ancestors. The default is to check the ancestors. If set to false, the method will return the value of this node without checking ancestors.
	 * @return {boolean} whether this node (and its parent) is enabled.
	 * @see setEnabled
	 */
	public function isEnabled(checkAncestors:Bool = true):Bool {
		if (checkAncestors == false) {
			return this._isEnabled;
		}
		
		if (!this._isEnabled) {
			return false;
		}
		
		if (this.parent != null) {
			return this.parent.isEnabled(checkAncestors);
		}
		
		return true;
	}

	/**
	 * Set the enabled state of this node.
	 * @param {boolean} value - the new enabled state
	 * @see isEnabled
	 */
	public function setEnabled(value:Bool) {
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

	/**
	 * Evaluate the list of children and determine if they should be considered as descendants 
	 * considering the given criterias
	 * @param {BABYLON.Node[]} results the result array containing the nodes matching the given criterias
	 * @param {boolean} directDescendantsOnly if true only direct descendants of 'this' will be considered, 
	 * if false direct and also indirect (children of children, an so on in a recursive manner) descendants 
	 * of 'this' will be considered.
	 * @param predicate: an optional predicate that will be called on every evaluated children, the predicate 
	 * must return true for a given child to be part of the result, otherwise it will be ignored.
	 */
	public function _getDescendants(results:Array<Node>, directDescendantsOnly:Bool = false, ?predicate:Node->Bool) {
		if (this._children == null) {
			return;
		}
		
		for (index in 0...this._children.length) {
			var item = this._children[index];
			
			if (predicate == null || predicate(item)) {
				results.push(item);
			}
			
			if (!directDescendantsOnly) {
				item._getDescendants(results, false, predicate);
			}
		}
	}

	/**
	 * Will return all nodes that have this node as ascendant
	 * @param directDescendantsOnly defines if true only direct descendants of 'this' will be considered, if false direct and also indirect (children of children, an so on in a recursive manner) descendants of 'this' will be considered
	 * @param predicate defines an optional predicate that will be called on every evaluated child, the predicate must return true for a given child to be part of the result, otherwise it will be ignored
	 * @return all children nodes of all types
	 */
	inline public function getDescendants(directDescendantsOnly:Bool = false, ?predicate:Node->Bool):Array<Node> {
		var results:Array<Node> = [];
		
		this._getDescendants(results, directDescendantsOnly, predicate);
		
		return results;
	}
	
	/**
	 * Get all child-transformNodes of this node
	 * @param directDescendantsOnly defines if true only direct descendants of 'this' will be considered, if false direct and also indirect (children of children, an so on in a recursive manner) descendants of 'this' will be considered
	 * @param predicate defines an optional predicate that will be called on every evaluated child, the predicate must return true for a given child to be part of the result, otherwise it will be ignored
	 * @returns an array of {BABYLON.TransformNode}
	 */
	public function getChildMeshes(directDecendantsOnly:Bool = false, ?predicate:Node->Bool):Array<AbstractMesh> {
		var results:Array<AbstractMesh> = [];
		
		this._getDescendants(cast results, directDecendantsOnly, function(node:Node):Bool {
			return ((predicate == null || predicate(node)) && Std.is(node, AbstractMesh));
		});
		
		return results;
	}
	
	/**
	 * Get all direct children of this node
	 * @param predicate defines an optional predicate that will be called on every evaluated child, the predicate must return true for a given child to be part of the result, otherwise it will be ignored
	 * @returns an array of {BABYLON.Node}
	 */
	public function getChildTransformNodes(directDescendantsOnly:Bool = false, ?predicate:Node->Bool):Array<TransformNode> {
		var results:Array<TransformNode> = [];
		
		this._getDescendants(cast results, directDescendantsOnly, function(node:Node) {
			return ((predicate == null || predicate(node)) && Std.is(node, TransformNode));
		});
		return results;
	}
	
	/**
	 * Get all direct children of this node.
	*/
	public function getChildren(?predicate:Node->Bool):Array<Node> {
		return this.getDescendants(true, predicate);
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
	
	/**
	 * Creates an animation range for this node
	 * @param name defines the name of the range
	 * @param from defines the starting key
	 * @param to defines the end key
	 */
	public function getAnimationByName(name:String):Animation {
		for (i in 0...this.animations.length) {
			var animation = this.animations[i];
			
			if (animation.name == name) {
				return animation;
			}
		}
		
		return null;
	}
	
	public function createAnimationRange(name:String, from:Float, to:Float) {
		// check name not already in use
		if (this._ranges[name] == null) {
			this._ranges[name] = new AnimationRange(name, from, to);
			for (i in 0...this.animations.length) {
				if (this.animations[i] != null) {
					this.animations[i].createRange(name, from, to);
				}
			}
		}
	}

	/**
	 * Delete a specific animation range
	 * @param name defines the name of the range to delete
	 * @param deleteFrames defines if animation frames from the range must be deleted as well
	 */
	public function deleteAnimationRange(name:String, deleteFrames:Bool = true) {
		for (i in 0...this.animations.length) {
			if (this.animations[i] != null) {
				this.animations[i].deleteRange(name, deleteFrames);
			}
		}
		
		this._ranges.remove(name);
	}

	/**
	 * Get an animation range by name
	 * @param name defines the name of the animation range to look for
	 * @returns null if not found else the requested animation range
	 */
	public function getAnimationRange(name:String):AnimationRange {
		return this._ranges[name];
	}

	/**
	 * Will start the animation sequence
	 * @param name defines the range frames for animation sequence
	 * @param loop defines if the animation should loop (false by default)
	 * @param speedRatio defines the speed factor in which to run the animation (1 by default)
	 * @param onAnimationEnd defines a function to be executed when the animation ended (undefined by default)
	 * @returns the object created for this animation. If range does not exist, it will return null
	 */
	public function beginAnimation(name:String, loop:Bool = false, speedRatio:Float = 1.0, ?onAnimationEnd:Void->Void):Animatable {
		var range = this.getAnimationRange(name);
		
		if (range == null) {
			return null;
		}
		
		return this._scene.beginAnimation(this, cast range.from, cast range.to, loop, speedRatio, onAnimationEnd);
	}
	
	/**
	 * Serialize animation ranges into a JSON compatible object
	 * @returns serialization object
	 */
	public function serializeAnimationRanges() {
		var serializationRanges:Array<Dynamic> = [];
		for (name in this._ranges.keys()) {
			var localRange = this._ranges[name];
			if (localRange == null) {
				continue;
			}
			var range:Dynamic = { };
			range.name = name;
			range.from = this._ranges[name].from;
			range.to   = this._ranges[name].to;
			serializationRanges.push(range);
		}
		
		return serializationRanges;
	}
	
	/**
	 * Computes the world matrix of the node
	 * @param force defines if the cache version should be invalidated forcing the world matrix to be created from scratch
	 * @returns the world matrix
	 */
    public function computeWorldMatrix(force:Bool = false):Matrix {
        // override it in derived class
		return Matrix.Identity();
    }
	
	// BHX: doNotRecurse !!
	public function dispose(doNotRecurse:Bool = false) {
		this.parent = null;
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
		this.onDisposeObservable.clear();
		
		// Behaviors
		for (behavior in this._behaviors) {
			behavior.detach();
		}
		
		this._behaviors = [];
		this._isDisposed = true;
	}
	
	/**
	 * Parse animation range data from a serialization object and store them into a given node
	 * @param node defines where to store the animation ranges
	 * @param parsedNode defines the serialization object to read data from
	 * @param scene defines the hosting scene
	 */
	public static function ParseAnimationRanges(node:Node, parsedNode:Dynamic, scene:Scene) {
		if (parsedNode.ranges != null){
		    for (index in 0...parsedNode.ranges.length) {
			    var data = parsedNode.ranges[index];
			    node.createAnimationRange(data.name, data.from, data.to);
		    }
		}
	}
	
}
