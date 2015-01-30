package com.babylonhx.mesh.csg;

/**
 * ...
 * @author Krtolica Vujadin
 */

// Holds a node in a BSP tree. A BSP tree is built from a collection of polygons
// by picking a polygon to split along. That polygon (and all other coplanar
// polygons) are added directly to that node and the other polygons are added to
// the front and/or back subtrees. This is not a leafy BSP tree since there is
// no distinction between internal and leaf nodes.
class Node {
	
	private var plane:Plane = null;
	private var front:Node = null;
	private var back:Node = null;
	private var polygons:Array<Polygon> = [];
	

	public function new (?polygons:Array<Polygon>) {
		if (polygons != null) {
			this.build(polygons);
		}
	}

	public function clone():Node {
		var node = new Node();
		node.plane = this.plane.clone();
		node.front = this.front.clone();
		node.back = this.back.clone();
		node.polygons = this.polygons.copy();
		return node;
	}

	// Convert solid space to empty space and empty space to solid space.
	public function invert():Void {
		for (i in 0...this.polygons.length) {
			this.polygons[i].flip();
		}
		if (this.plane != null) {
			this.plane.flip();
		}
		if (this.front != null) {
			this.front.invert();
		}
		if (this.back != null) {
			this.back.invert();
		}
		var temp = this.front;
		this.front = this.back;
		this.back = temp;
	}

	// Recursively remove all polygons in `polygons` that are inside this BSP
	// tree.
	public function clipPolygons(polygons:Array<Polygon>) {
		if (this.plane == null) {
			return polygons.slice(0);
		}
		var _front:Array<Polygon> = [];
		var _back:Array<Polygon> = [];
		for (i in 0...polygons.length) {
			this.plane.splitPolygon(polygons[i], _front, _back, _front, _back);
		}
		if (this.front != null) {
			_front = this.front.clipPolygons(_front);
		}
		if (this.back != null) {
			_back = this.back.clipPolygons(_back);
		} else {
			_back = [];
		}
		return _front.concat(_back);
	}

	// Remove all polygons in this BSP tree that are inside the other BSP tree
	// `bsp`.
	public function clipTo(bsp:Node):Void {
		this.polygons = bsp.clipPolygons(this.polygons);
		if (this.front != null) {
			this.front.clipTo(bsp);
		}
		if (this.back != null) {
			this.back.clipTo(bsp);
		}
	}

	// Return a list of all polygons in this BSP tree.
	public function allPolygons():Array<Polygon> {
		var polygons = this.polygons.slice(0);
		if (this.front != null) polygons = polygons.concat(this.front.allPolygons());
		if (this.back != null) polygons = polygons.concat(this.back.allPolygons());
		return polygons;
	}

	// Build a BSP tree out of `polygons`. When called on an existing tree, the
	// new polygons are filtered down to the bottom of the tree and become new
	// nodes there. Each set of polygons is partitioned using the first polygon
	// (no heuristic is used to pick a good split).
	public function build(polygons:Array<Polygon>) {
		if (polygons == null || polygons.length == 0) {
			return;
		}
		
		if (this.plane == null) {
			this.plane = polygons[0].plane.clone();
		}
		
		var _front:Array<Polygon> = [];
		var _back:Array<Polygon> = [];
		for (i in 0...polygons.length) {
			this.plane.splitPolygon(polygons[i], this.polygons, this.polygons, _front, _back);
		}
		
		if (_front.length > 0) {
			if (this.front == null) {
				this.front = new Node();
			}
			this.front.build(_front);
		}
		
		if (_back.length > 0) {
			if (this.back == null) {
				this.back = new Node();
			}
			this.back.build(_back);
		}
	}
	
}
