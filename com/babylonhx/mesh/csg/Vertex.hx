package com.babylonhx.mesh.csg;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

// Represents a vertex of a polygon. Use your own vertex class instead of this
// one to provide additional features like texture coordinates and vertex
// colors. Custom vertex classes need to provide a `pos` property and `clone()`,
// `flip()`, and `interpolate()` methods that behave analogous to the ones
// defined by `BABYLON.CSG.Vertex`. This class provides `normal` so convenience
// functions like `BABYLON.CSG.sphere()` can return a smooth vertex normal, but `normal`
// is not used anywhere else. 
// Same goes for uv, it allows to keep the original vertex uv coordinates of the 2 meshes
class Vertex {
	
	public var pos:Vector3;
	public var normal:Vector3;
	public var uv:Vector2;
	
	
	inline public function new(pos:Vector3, normal:Vector3, uv:Vector2) {
		this.pos = pos;
		this.normal = normal;
		this.uv = uv;
	}

	inline public function clone():Vertex {
		return new Vertex(this.pos.clone(), this.normal.clone(), this.uv.clone());
	}

	// Invert all orientation-specific data (e.g. vertex normal). Called when the
	// orientation of a polygon is flipped.
	inline public function flip() {
		this.normal = this.normal.scale(-1);
	}

	// Create a new vertex between this vertex and `other` by linearly
	// interpolating all properties using a parameter of `t`. Subclasses should
	// override this to interpolate additional properties.
	public function interpolate(other:Vertex, t:Float):Vertex {
		return new Vertex(
			Vector3.Lerp(this.pos, other.pos, t),
			Vector3.Lerp(this.normal, other.normal, t),
			Vector2.Lerp(this.uv, other.uv, t)
		);
	}
	
}
