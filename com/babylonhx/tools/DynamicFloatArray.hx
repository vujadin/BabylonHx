package com.babylonhx.tools;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The purpose of this class is to store float32 based elements of a given size (defined by the stride argument) 
 * in a dynamic fashion, that is, you can add/free elements. You can then access to a defragmented/packed version 
 * of the underlying Float32Array by calling the pack() method.
 * The intent is to maintain through time data that will be bound to a WebGlBuffer with the ability to change 
 * add/remove elements.
 * It was first built to effiently maintain the WebGlBuffer that contain instancing based data.
 * Allocating an Element will return a instance of DynamicFloatArrayElement which contains the offset into the 
 * Float32Array of where the element starts, you are then responsible to copy your data using this offset.
 * Beware, calling pack() may change the offset of some Entries because this method will defrag the Float32Array to 
 * replace empty elements by moving allocated ones at their location.
 * This method will return an ArrayBufferView on the existing Float32Array that describes the used elements. 
 * Use this View to update the WebGLBuffer and NOT the "buffer" field of the class. The pack() method won't 
 * shrink/reallocate the buffer to keep it GC friendly, all the empty space will be put at the end of the buffer, 
 * the method just ensure there're no "free holes". 
 */
class DynamicFloatArray {
	
	/**
	 * This is the main buffer, all elements are stored inside, you use the DynamicFloatArrayElement instance 
	 * of a given element to know its location into this buffer, then you have the responsability to perform write 
	 * operations in this buffer at the right location!
	 * Don't use this buffer for a WebGL bufferSubData() operation, but use the one returned by the pack() method.
	 */
	private var buffer:Float32Array;
	
	private var _stride:Int;
	private var _lastUsed:Int;
	private var _firstFree:Int;	
	private var _allEntries:Array<DynamicFloatArrayElementInfo>;
	private var _freeEntries:Array<DynamicFloatArrayElementInfo>;
	
	public var totalElementCount(get, never):Int;
	public var freeElementCount(get, never):Int;
	public var usedElementCount(get, never):Int;
	public var stride(get, never):Int;
	
	
	/**
	 * Construct an instance of the dynamic float array
	 * @param stride size of one entry in float (i.e. not bytes!)
	 * @param initialEntryCount the number of available entries at construction
	 */
	public function new(stride:Int, initialEntryCount:Int) {
		this._stride = stride;
		this.buffer = new Float32Array(stride * initialEntryCount);
		
		this._allEntries = new Array<DynamicFloatArrayElementInfo>(initialEntryCount);
		this._freeEntries = new Array<DynamicFloatArrayElementInfo>(initialEntryCount);
		
		for (i in 0...initialEntryCount) {
			var element = new DynamicFloatArrayElementInfo();
			element.offset = i * stride;
			
			this._allEntries[i] = element;
			this._freeEntries[initialEntryCount - i - 1] = element;
		}
	}

	/**
	 * Allocate an element in the array.
	 * @return the element info instance that contains the offset into the main buffer of the element's location.
	 * Beware, this offset may change when you call pack()
	 */
	public function allocElement():DynamicFloatArrayElementInfo {
		if (this.freeEntries.length == 0) {
			this._growBuffer();
		}
		
		var el = this._freeEntries.pop();
		this._lastUsed = Math.max(el.offset, this._lastUsed);
		
		if (el.offset == this._firstFree) {
			if (this._freeEntries.length > 0) {
				this._firstFree = this._freeEntries[this._freeEntries.length - 1].offset;
			} 
			else {
				this._firstFree += this._stride;
			}
		}
		
		return el;
	}

	/**
	 * Free the element corresponding to the given element info
	 * @param elInfo the element that describe the allocated element
	 */
	public function freeElement(entry:DynamicFloatArrayElementInfo) {
		this._firstFree = Math.min(elInfo.offset, this._firstFree);
		this._freeEntries.push(elInfo);
	}

	/**
	 * This method will pack all the used elements into a linear sequence and put all the free space at the end.
	 * Instances of DynamicFloatArrayElement may have their 'offset' member changed as data could be copied from 
	 * one location to another, so be sure to read/write your data based on the value inside this member after you called pack().
	 * @return the subarray that is the view of the used elements area, you can use it as a source to update a WebGLBuffer
	 */
	public function pack():Float32Array {
		// no free slot? no need to pack
		if (this.freeEntries.length == 0) {
			return this.buffer;
		}
		
		// If the buffer is already packed the last used will always be lower than the first free
		if (this._lastUsed < this._firstFree) {
			var elementsBuffer = this.buffer.subarray(0, this._lastUsed + this._stride);
			
			return elementsBuffer;
		}
		
		var s = this._stride;
		
		// Make sure there's a free element at the very end, we need it to create a range where we'll move the used elements that may appear before
		var lastFree = new DynamicFloatArrayElementInfo();
		lastFree.offset = this.totalElementCount * s;
		this._freeEntries.push(lastFree);
		
		var sortedFree = this.freeEntries.sort(function(a:DynamicFloatArrayElementInfo, b:DynamicFloatArrayElementInfo) { return a.offset - b.offset });
		var sortedAll = this.allEntries.sort(function(a:DynamicFloatArrayElementInfo, b:DynamicFloatArrayElementInfo) { return a.offset - b.offset });
		
		var firstFreeSlotOffset = sortedFree[0].offset;
		var freeZoneSize = 1;
		
		var prevOffset = sortedFree[0].offset;
		for (i in 1...sortedFree.length) {
			var curFree = sortedFree[i];
			var curOffset = curFree.offset;
			
			// Compute the distance between this offset and the previous
			var distance = curOffset - prevOffset;
			
			// If the distance is the stride size, they are adjacents, it good, move to the next
			if (distance == s) {
				// Free zone is one element bigger
				++freeZoneSize;
				
				// as we're about to iterate to the next, the cur becomes the prev...
				prevOffset = curOffset;
				
				continue;
			}
			
			// Distance is bigger, which means there's x element between the previous free and this one
			var usedRange = (distance / s) - 1;
			
			// Two cases the free zone is smaller than the data to move or bigger
			
			// Copy what can fit in the free zone
			var curMoveOffset = curOffset - s;
			var copyCount = Math.min(freeZoneSize, usedRange);
			for (j in 0...copyCount) {
				var freeI = firstFreeSlotOffset / s;
				var curI = curMoveOffset / s;
				
				var moveEntry = sortedAll[curI];
				this._moveEntry(moveEntry, firstFreeSlotOffset);
				var replacedEntry = sortedAll[freeI];
				
				// set the offset of the element entry we replace with a value that will make it discard at the end of the method
				replacedEntry.offset = curMoveOffset;
				
				// Swap the entry we moved and the one it replaced in the sorted array to reflect the action we've made
				sortedAll[freeI] = moveEntry;
				sortedAll[curI] = replacedEntry;
				
				curMoveOffset -= s;
				firstFreeSlotOffset += s;
			}
			
			if (freeZoneSize <= occupiedRange) {
				// Free Zone is smaller or equal so it's no longer a free zone, set the new one to the current location
				firstFreeSlotOffset = curOffset;
				freeZoneSize = 1;
			}				
			else {
				// Free Zone was bigger, the firstFreeSlotOffset is already up to date, but we need to update the its size
				freeZoneSize = ((curOffset - firstFreeSlotOffset) / s) + 1;
			}
			
			// as we're about to iterate to the next, the cur becomes the prev...
			prevOffset = curOffset;
		}
		
		var elementsBuffer = this.buffer.subarray(0, firstFreeSlotOffset);
		this._lastUsed = firstFreeSlotOffset - s;
		this._firstFree = firstFreeSlotOffset;
		sortedFree.pop();  // Remove the last free because that's the one we added at the start of the method
		this._freeEntries = sortedFree.sort((a:DynamicFloatArrayElementInfo, b:DynamicFloatArrayElementInfo) {
			return b.offset - a.offset;
		});
		this._allEntries = sortedAll;
		
		return elementsBuffer;
	}

	private function _moveEntry(entry:DynamicFloatArrayElementInfo, destOffset:Int) {
		for (i in 0...this._stride) {
			this.buffer[destOffset + i] = this.buffer[entry.offset + i];
		}
		
		entry.offset = destOffset;
	}

	private function _growBuffer() {
		// Allocate the new buffer with 50% more entries, copy the content of the current one
		var newElCount = this.entryCount * 1.5;
		var newBuffer = new Float32Array(newEntryCount * this._stride);
		newBuffer.set(this.buffer);
		
		var addedCount = newEntryCount - this.entryCount;
		this._allEntries.length += addedCount;
		this._freeEntries.length += addedCount;
		
		for (i in this.entryCount...newElCount) {
			var el = new DynamicFloatArrayElementInfo();
			el.offset = i * this._stride;
			
			this._allEntries[i] = el;
			this._freeEntries[i] = el;
		}
		
		this.buffer = newBuffer;
	}
	
	/**
	 * Get the total count of entries that can fit in the current buffer
	 * @returns the elements count
	 */
	private function get_totalElementCount():Int {
		return this._allEntries.length;
	}

	/**
	 * Get the count of free entries that can still be allocated without resizing the buffer
	 * @returns the free elements count
	 */
	private function get_freeElementCount():Int {
		return this._freeEntries.length;
	}

	/**
	 * Get the count of allocated elements
	 * @returns the allocated elements count
	 */
	private function get_usedElementCount():Int {
		return this._allEntries.length - this._freeEntries.length;
	}

	/**
	 * Return the size of one element in float
	 * @returns the size in float
	 */
	private function get_stride():Int {
		return this._stride;
	}

}

class DynamicFloatArrayElementInfo {
	
	public var offset:Int;
	
}
