package com.babylonhx.culling.octrees;

import com.babylonhx.math.Plane;
import com.babylonhx.culling.Ray;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.tools.SmartArray;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Octree') class Octree<T:ISmartArrayCompatible> implements IOctreeContainer<T> {
	
	public var blocks:Array<OctreeBlock<T>>;
	public var dynamicContent:Array<T> = new Array<T>();
	public var maxDepth:Int;

	private var _maxBlockCapacity:Int;
	private var _selectionContent:SmartArray<T>;       
	private var _creationFunc:T->OctreeBlock<T>->Void;
	

	public function new(creationFunc:T->OctreeBlock<T>->Void, maxBlockCapacity:Int = 64, maxDepth:Int = 2) {
		this._maxBlockCapacity = maxBlockCapacity;
		this._selectionContent = new SmartArray<T>(1024);
		this._creationFunc = creationFunc;
		this.maxDepth = maxDepth;
	}

	// Methods
	inline public function update(worldMin:Vector3, worldMax:Vector3, entries:Array<T>) {
		Octree._CreateBlocks(worldMin, worldMax, entries, this._maxBlockCapacity, 0, this.maxDepth, this, this._creationFunc);
	}

	public function addMesh(entry:T):Void {
		for (index in 0...this.blocks.length) {
			var block = this.blocks[index];
			block.addEntry(entry);
		}
	}

	inline public function select(frustumPlanes:Array<Plane>, allowDuplicate:Bool = false):SmartArray<T> {
		this._selectionContent.reset();
		
		for (index in 0...this.blocks.length) {
			var block = this.blocks[index];
			block.select(frustumPlanes, this._selectionContent, allowDuplicate);
		}
		
		if (allowDuplicate) {
			this._selectionContent.concatArray(this.dynamicContent);
		} 
		else {
			this._selectionContent.concatArrayWithNoDuplicate(this.dynamicContent);                
		}
		
		return this._selectionContent;
	}

	inline public function intersects(sphereCenter:Vector3, sphereRadius:Float, allowDuplicate:Bool = false):SmartArray<T> {
		this._selectionContent.reset();
		
		for (index in 0...this.blocks.length) {
			var block = this.blocks[index];
			block.intersects(sphereCenter, sphereRadius, this._selectionContent, allowDuplicate);
		}
		
		if (allowDuplicate) {
			this._selectionContent.concatArray(this.dynamicContent);
		} else {
			this._selectionContent.concatArrayWithNoDuplicate(this.dynamicContent);
		}
		
		return this._selectionContent;
	}

	public function intersectsRay(ray:Ray):SmartArray<T> {
		this._selectionContent.reset();
		
		for (index in 0...this.blocks.length) {
			var block = this.blocks[index];
			block.intersectsRay(ray, this._selectionContent);
		}
		
		this._selectionContent.concatArrayWithNoDuplicate(this.dynamicContent);
		
		return this._selectionContent;
	}

	public static function _CreateBlocks<T:ISmartArrayCompatible>(worldMin:Vector3, worldMax:Vector3, entries:Array<T>, maxBlockCapacity:Int, currentDepth:Int, maxDepth:Int, target:IOctreeContainer<T>, creationFunc:T->OctreeBlock<T>->Void) {
		target.blocks = new Array<OctreeBlock<T>>();
		var blockSize = new Vector3((worldMax.x - worldMin.x) / 2, (worldMax.y - worldMin.y) / 2, (worldMax.z - worldMin.z) / 2);
		
		// Segmenting space
		for (x in 0...2) {
			for (y in 0...2) {
				for (z in 0...2) {
					var localMin = worldMin.add(blockSize.multiplyByFloats(x, y, z));
					var localMax = worldMin.add(blockSize.multiplyByFloats(x + 1, y + 1, z + 1));
					
					var block = new OctreeBlock<T>(localMin, localMax, maxBlockCapacity, currentDepth + 1, maxDepth, creationFunc);
					block.addEntries(entries);
					target.blocks.push(block);
				}
			}
		}
	}

	public static function CreationFuncForMeshes(entry:AbstractMesh, block:OctreeBlock<AbstractMesh>) {
		if (!entry.isBlocked && entry.getBoundingInfo().boundingBox.intersectsMinMax(block.minPoint, block.maxPoint)) {
			block.entries.push(entry);
		}
	}

	public static function CreationFuncForSubMeshes(entry:SubMesh, block:OctreeBlock<SubMesh>) {
		if (entry.getBoundingInfo().boundingBox.intersectsMinMax(block.minPoint, block.maxPoint)) {
			block.entries.push(entry);
		}
	}
	
}
