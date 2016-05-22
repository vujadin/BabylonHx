package com.babylonhx.tools;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Size;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This class describe a rectangle that were added to the map.
 * You have access to its coordinates either in pixel or normalized (UV)
 */
class PackedRect {
	
	private var _root:PackedRect;
	private var _parent:PackedRect;
	private var _contentSize:Size;
	private var _initialSize:Size;
	private var _leftNode:PackedRect;
	private var _rightNode:PackedRect;
	private var _bottomNode:PackedRect;

	private var _pos:Vector2;
	private var _size:Size;
	
	public var pos(get, never):Vector2;
	public var size(get, never):Size;
	public var contentSize(get, never):Size;
	public var UVs(get, never):Array<Vector2>;
	public var isUsed(get, never):Bool;
	public var isRecursiveFree(get, never):Bool;
	
	
	public function new(root:PackedRect, parent:PackedRect, pos:Vector2, size:Size) {
		this._pos = pos;
		this._size = size;
		this._root = root;
		this._parent = parent;
	}

	/**
	 * @returns the position of this node into the map
	 */
	private function get_pos():Vector2 {
		return this._pos;
	}

	/**
	 * @returns the size of the rectangle this node handles
	 */
	private function get_contentSize():Size {
		return this._contentSize;
	}

	/**
	 * Compute the UV of the top/left, top/right, bottom/right, bottom/left points of the rectangle this node 
	 * handles into the map
	 * @returns And array of 4 Vector2, containing UV coordinates for the four corners of the Rectangle into the map
	 */
	private function get_UVs():Array<Vector2> {
		var mainWidth = this._root.size.width;
		var mainHeight = this._root.size.height;
		
		var topLeft = new Vector2(this._pos.x / mainWidth, this._pos.y / mainHeight);
		var rightBottom = new Vector2((this._pos.x + this._contentSize.width - 1) / mainWidth, (this._pos.y + this._contentSize.height - 1) / mainHeight);
		var uvs:Array<Vector2> = [];
		uvs.push(topLeft);
		uvs.push(new Vector2(rightBottom.x, topLeft.y));
		uvs.push(rightBottom);
		uvs.push(new Vector2(topLeft.x, rightBottom.y));
		
		return uvs;
	}

	/**
	 * Free this rectangle from the map.
	 * Call this method when you no longer need the rectangle to be in the map.
	 */
	public function freeContent() {
		if (this.contentSize == null) {
			return;
		}
		
		this._contentSize = null;
		
		// If everything below is also free, reset the whole node, and attempt to reset parents if they also become free
		this.attemptDefrag();
	}

	private function get_isUsed():Bool {
		return this._contentSize != null || this._leftNode != null;
	}

	private function findAndSplitNode(contentSize:Size):PackedRect {
		var node = this.findNode(contentSize);
		
		// Not enough space...
		if (node == null) {
			return null;
		}
		
		node.splitNode(contentSize);
		
		return node;
	}

	private function findNode(size:Size):PackedRect {
		var resNode:PackedRect = null;
		
		// If this node is used, recurse to each of his subNodes to find an available one in its branch
		if (this.isUsed) {
			if (this._leftNode != null) {
				resNode = this._leftNode.findNode(size);
			}
			if (resNode == null && this._rightNode != null) {
				resNode = this._rightNode.findNode(size);
			}
			if (resNode == null && this._bottomNode != null) {
				resNode = this._bottomNode.findNode(size);
			}
		}		
		else if (this._initialSize != null && (size.width <= this._initialSize.width) && (size.height <= this._initialSize.height)) {
			// The node is free, but was previously allocated (_initialSize is set), 
			// rely on initialSize to make the test as it's the space we have
			resNode = this;
		}
		else if ((size.width <= this._size.width) && (size.height <= this._size.height)) {
			// The node is free and empty, rely on its size for the test
			resNode = this;
		}
		
		return resNode;
	}

	private function splitNode(contentSize:Size):PackedRect {
		// If there's no contentSize but an initialSize it means this node were previously allocated, 
		// but freed, we need to create a _leftNode as subNode and use to allocate the space we need 
		// (and this node will have a right/bottom subNode for the space left as this._initialSize may 
		// be greater than contentSize)
		if (this._contentSize == null && this._initialSize != null) {
			this._leftNode = new PackedRect(this._root, this, new Vector2(this._pos.x, this._pos.y), new Size(this._initialSize.width, this._initialSize.height));
			return this._leftNode.splitNode(contentSize);
		} 
		else {
			this._contentSize = contentSize.clone();
			this._initialSize = contentSize.clone();
			
			if (contentSize.width != this._size.width) {
				this._rightNode = new PackedRect(this._root, this, new Vector2(this._pos.x + contentSize.width, this._pos.y), new Size(this._size.width - contentSize.width, contentSize.height));
			}
			
			if (contentSize.height != this._size.height) {
				this._bottomNode = new PackedRect(this._root, this, new Vector2(this._pos.x, this._pos.y + contentSize.height), new Size(this._size.width, this._size.height - contentSize.height));
			}
			
			return this;
		}
	}

	private function attemptDefrag() {
		if (!this.isUsed && this.isRecursiveFree) {
			this.clearNode();

			if (this._parent) {
				this._parent.attemptDefrag();
			}
		}
	}

	private clearNode() {
		this._initialSize = null;
		this._rightNode = null;
		this._bottomNode = null;
	}

	private function get_isRecursiveFree():Bool {
		return this.contentSize == null && (this._leftNode == null || this._leftNode.isRecursiveFree) && (this._rightNode == null || this._rightNode.isRecursiveFree) && (this._bottomNode == null || this._bottomNode.isRecursiveFree);
	}

	private function evalFreeSize(size:Int):Int {
		var levelSize:Int = 0;
		
		if (!this.isUsed) {
			if (this._initialSize != null) {
				levelSize = this._initialSize.surface;
			} 
			else {
				levelSize = this._size.surface;
			}
		}
		
		if (this._rightNode != null) {
			levelSize += this._rightNode.evalFreeSize(0);
		}
		
		if (this._bottomNode != null) {
			levelSize += this._bottomNode.evalFreeSize(0);
		}
		
		return levelSize + size;
	}
	
}