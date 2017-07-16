package com.babylonhx.tools;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Size;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The purpose of this class is to pack several Rectangles into a big map, while trying 
 * to fit everything as optimaly as possible.
 * This class is typically used to build lightmaps, sprite map or to pack several little 
 * textures into a big one.
 * Note that this class allows allocated Rectangles to be freed: that is the map is dynamically 
 * maintained so you can add/remove rectangle based on their lifecycle.
 */
class RectPackingMap extends PackedRect {
	
	public var freeSpace(get, never):Float;
	
	
	/**
	 * Create an instance of the object with a dimension using the given size
	 * @param size The dimension of the rectangle that will contain all the sub ones.
	 */
	public function new(size:Size) {
		super(null, null, Vector2.Zero(), size);
		
		this._root = this;
	}

	/**
	 * Add a rectangle, finding the best location to store it into the map
	 * @param size the dimension of the rectangle to store
	 * @return the Node containing the rectangle information, or null if we couldn't find a free spot
	 */
	public function addRect(size:Size):PackedRect {
		var node = this.findAndSplitNode(size);
		
		return node;
	}

	/**
	 * Return the current space free normalized between [0;1]
	 * @returns {} 
	 */
	private function get_freeSpace():Float {
		var freeSize = 0;
		freeSize = this.evalFreeSize(freeSize);
		
		return freeSize / (this._size.width * this._size.height);
	}
	
}
	