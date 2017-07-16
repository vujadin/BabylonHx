package com.babylonhx.mesh.csg;

/**
 * ...
 * @author Krtolica Vujadin
 */

// Represents a convex polygon. The vertices used to initialize a polygon must
// be coplanar and form a convex loop.
// 
// Each convex polygon has a `shared` property, which is shared between all
// polygons that are clones of each other or were split from the same polygon.
// This can be used to define per-polygon properties (such as surface color).
class Polygon {
	
	public var vertices:Array<Vertex>;
	public var shared:Dynamic;
	public var plane:Plane;
	

	public function new(vertices:Array<Vertex>, shared:Dynamic) {
		this.vertices = vertices;
		this.shared = shared;
		this.plane = Plane.FromPoints(vertices[0].pos, vertices[1].pos, vertices[2].pos);
	}

	inline public function clone():Polygon {
		var vertices = this.vertices.copy(); // this.vertices.map(function(v) { return v.clone(); } ).filter(function(v) { v.plane; } );
		
		return new Polygon(vertices, this.shared);
	}

	inline public function flip() {
		this.vertices.reverse();
		this.vertices.map(function(v) { v.flip(); } );
		this.plane.flip();
	}
	
}
