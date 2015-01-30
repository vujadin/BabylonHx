package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Path2;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;
import org.poly2tri.Point;
import org.poly2tri.Sweep;
import org.poly2tri.SweepContext;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PolygonMeshBuilder {

	private var _swctx:SweepContext;
	private var _points:PolygonPoints;
	
	private var name:String;
	private var scene:Scene;

	
	public function new(name:String, contours:Dynamic, scene:Scene) {
		this.name = name;
		this.scene = scene;
				
		this._points = new PolygonPoints();
		
		var points:Array<Vector2> = [];
		if (Std.is(contours, Path2)) {
			points = cast(contours, Path2).getPoints();
		} else {
			points = cast contours;
		}
		this._swctx = new SweepContext();
		
		this._points.add(points);
		var pts:Array<IndexedPoint> = [];
		for (p in this._points.elements) {
			pts.push(new IndexedPoint(new Vector2(p.x, p.y), p.index));
		}
		this._swctx.addPolyline(cast pts);
	}

	private function addHole(hole:Array<Vector2>):PolygonMeshBuilder {
		this._points.add(hole);
		var points_:Array<IndexedPoint> = [];
		for (p in this._points.elements) {
			points_.push(new IndexedPoint(new Vector2(p.x, p.y), p.index));
		}
		this._swctx.addPolyline(cast points_);
		return this;
	}

	public function build(updatable:Bool = false):Mesh {
		var result = new Mesh(this.name, this.scene);
		
		var normals:Array<Float> = [];
		var positions:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var bounds = this._points.computeBounds();
		for(p in this._points.elements) {
			normals.push(0);
			normals.push(1.0);
			normals.push(0);
			positions.push(p.x);
			positions.push(0);
			positions.push(p.y);
			uvs.push((p.x - bounds.min.x) / bounds.width);
			uvs.push((p.y - bounds.min.y) / bounds.height);
		}
		
		var indices = [];
		
		var sweep = new Sweep(this._swctx);
		sweep.triangulate();
		for(triangle in this._swctx.triangles) {
			for(point in triangle.points) {
				indices.push(cast(point, IndexedPoint).index);
			}
		}
		
		result.setVerticesData(VertexBuffer.PositionKind, positions, updatable);
		result.setVerticesData(VertexBuffer.NormalKind, normals, updatable);
		result.setVerticesData(VertexBuffer.UVKind, uvs, updatable);
		result.setIndices(indices);
		
		return result;
	}

}
