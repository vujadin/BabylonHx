package com.babylonhx.culling.octrees;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Ray;
import com.babylonhx.tools.SmartArray;

/**
* ...
* @author Krtolica Vujadin
*/
@:expose('BABYLON.OctreeBlock') class OctreeBlock<T> implements IOctreeContainer<T> {
	
	public var entries:Array<T> = [];
	public var blocks:Array<OctreeBlock<T>>;

	private var _depth:Int;
	private var _maxDepth:Int;
	private var _capacity:Int;
	private var _minPoint:Vector3;
	private var _maxPoint:Vector3;
	private var _boundingVectors:Array<Vector3> = [];
	private var _creationFunc:T->OctreeBlock<T>->Void;

	public function new(minPoint:Vector3, maxPoint:Vector3, capacity:Int, depth:Int, maxDepth:Int, creationFunc:T->OctreeBlock<T>->Void) {
		this._capacity = capacity;
		this._depth = depth;
		this._maxDepth = maxDepth;
		this._creationFunc = creationFunc;
		
		this._minPoint = minPoint;
		this._maxPoint = maxPoint;
		
		this._boundingVectors.push(minPoint.clone());
		this._boundingVectors.push(maxPoint.clone());
		
		this._boundingVectors.push(minPoint.clone());
		this._boundingVectors[2].x = maxPoint.x;

		this._boundingVectors.push(minPoint.clone());
		this._boundingVectors[3].y = maxPoint.y;

		this._boundingVectors.push(minPoint.clone());
		this._boundingVectors[4].z = maxPoint.z;

		this._boundingVectors.push(maxPoint.clone());
		this._boundingVectors[5].z = minPoint.z;

		this._boundingVectors.push(maxPoint.clone());
		this._boundingVectors[6].x = minPoint.x;

		this._boundingVectors.push(maxPoint.clone());
		this._boundingVectors[7].y = minPoint.y;
	}

	// Property
	public var capacity(get, null):Int;
	private function get_capacity():Int {
		return this._capacity;
	}

	public var minPoint(get, null):Vector3;
	private function get_minPoint():Vector3 {
		return this._minPoint;
	}

	public var maxPoint(get, null):Vector3;
	private function get_maxPoint():Vector3 {
		return this._maxPoint;
	}

	// Methods
	public function addEntry(entry:T):Void {
		if (this.blocks != null) {
			for (index in 0...this.blocks.length) {
				var block = this.blocks[index];
				block.addEntry(entry);
			}
			return;
		}

		this._creationFunc(entry, this);

		if (this.entries.length > this.capacity && this._depth < this._maxDepth) {
			this.createInnerBlocks();
		}
	}

	public function addEntries(entries:Array<T>):Void {
		for (index in 0...entries.length) {
			var mesh = entries[index];
			this.addEntry(mesh);
		}
	}

	public function select(frustumPlanes:Array<Plane>, selection:SmartArray, allowDuplicate:Bool = false/*?allowDuplicate:Bool*/) {
		if (BoundingBox.IsInFrustum(this._boundingVectors, frustumPlanes)) {
			if (this.blocks != null) {
				for (index in 0...this.blocks.length) {
					var block = this.blocks[index];
					block.select(frustumPlanes, selection, allowDuplicate);
				}
				return;
			}

			if (allowDuplicate) {
				selection.concat(this.entries);
			} else {
				selection.concatWithNoDuplicate(this.entries);
			}
		}
	}

	public function intersects(sphereCenter:Vector3, sphereRadius:Float, selection:SmartArray, allowDuplicate:Bool = false/*?allowDuplicate:Bool*/) {
		if (BoundingBox.IntersectsSphere(this._minPoint, this._maxPoint, sphereCenter, sphereRadius)) {
			if (this.blocks != null) {
				for (index in 0...this.blocks.length) {
					var block = this.blocks[index];
					block.intersects(sphereCenter, sphereRadius, selection, allowDuplicate);
				}
				return;
			}

			if (allowDuplicate) {
				selection.concat(this.entries);
			} else {
				selection.concatWithNoDuplicate(this.entries);
			}
		}
	}

	public function intersectsRay(ray:Ray, selection:SmartArray) {
		if (ray.intersectsBoxMinMax(this._minPoint, this._maxPoint)) {
			if (this.blocks != null) {
				for (index in 0...this.blocks.length) {
					var block = this.blocks[index];
					block.intersectsRay(ray, selection);
				}
				return;
			}
			selection.concatWithNoDuplicate(this.entries);
		}
	}

	public function createInnerBlocks():Void {
		Octree._CreateBlocks(this._minPoint, this._maxPoint, this.entries, this._capacity, this._depth, this._maxDepth, this, this._creationFunc);
	}
}