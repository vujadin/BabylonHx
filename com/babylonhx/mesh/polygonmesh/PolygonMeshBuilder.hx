package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Path2;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;
import org.poly2tri.Point;
import org.poly2tri.Sweep;
import org.poly2tri.SweepContext;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.PolygonMeshBuilder') class PolygonMeshBuilder {

	private var _swctx:SweepContext;
	private var _points:PolygonPoints;
	private var _outlinepoints:PolygonPoints; 
	private var _holes:Array<PolygonPoints>;
		
	private var name:String;
	private var scene:Scene;
	
	// VK: to keep track of holes ...
	private var currentPointsLength:Int = 0;

	
	public function new(name:String, contours:Dynamic, scene:Scene) {
		this.name = name;
		this.scene = scene;
						
		this._points = new PolygonPoints();
		this._outlinepoints = new PolygonPoints();
		this._holes = [];
		
		var points:Array<Vector2> = [];
		if (Std.is(contours, Path2)) {
			points = cast(contours, Path2).getPoints();
		} 
		else {
			points = cast contours;
		}
		this._swctx = new SweepContext();
		
		this._points.add(points);
		var pts:Array<IndexedPoint> = [];
		for (p in this._points.elements) {
			pts.push(new IndexedPoint(new Vector2(p.x, p.y), p.index));
		}
		this._swctx.addPolyline(cast pts);
		this._outlinepoints.add(points);
		
		this.currentPointsLength = this._points.elements.length;
	}

	public function addHole(hole:Array<Vector2>):PolygonMeshBuilder {
		this._points.add(hole);
		var points_:Array<IndexedPoint> = [];
		for (p in currentPointsLength...this._points.elements.length) {
			points_.push(new IndexedPoint(new Vector2(this._points.elements[p].x, this._points.elements[p].y), this._points.elements[p].index));
		}
		var holepoints = new PolygonPoints();
		holepoints.add(hole);
		this._holes.push(holepoints);
		this._swctx.addPolyline(cast points_);
		
		// update for next hole
		this.currentPointsLength = this._points.elements.length;
		
		return this;
	}

	public function build(updatable:Bool = false, depth:Float = 0):Mesh {
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
		
		var indices:Array<Int> = [];
		
		var sweep = new Sweep(this._swctx);
		sweep.triangulate();
		for(triangle in this._swctx.triangles) {
			for(point in triangle.points) {
				indices.push(cast(point, IndexedPoint).index);
			}
		}
				
		if (depth > 0) { 
			var positionscount = Std.int(positions.length / 3); //get the current pointcount
		   
			for(p in this._points.elements) { //add the elements at the depth
				normals.push(0);
				normals.push( -1.0);
				normals.push(0);                   
				positions.push(p.x);
				positions.push( -depth);
				positions.push(p.y);                
				uvs.push(1 - (p.x - bounds.min.x) / bounds.width);
				uvs.push(1 - (p.y - bounds.min.y) / bounds.height);
			}
			
			var p1:IndexedPoint = null; //we need to change order of point so the triangles are made in the rigth way.
			var p2:IndexedPoint = null;
			var poscounter:Int = 0;
			for(triangle in this._swctx.triangles) {
				for(point in triangle.points) {
					switch (poscounter) {
						case 0:
							p1 = cast point;
							
						case 1:
							p2 = cast point;
							
						case 2:
							indices.push((cast point).index + positionscount); 
							indices.push(p2.index + positionscount);
							indices.push(p1.index + positionscount);
							poscounter = -1;
							
					}
					poscounter++;
				}
			}
			
			//Add the sides
			this.addSide(positions, normals, uvs, indices, bounds, this._outlinepoints, depth, false);
			
			for(hole in this._holes) {
				this.addSide(positions, normals, uvs, indices, bounds, hole, depth, true);
			}                            
		}
		
		result.setVerticesData(VertexBuffer.PositionKind, positions, updatable);
		result.setVerticesData(VertexBuffer.NormalKind, normals, updatable);
		result.setVerticesData(VertexBuffer.UVKind, uvs, updatable);
		result.setIndices(indices);
		
		return result;
	}
	
	private function addSide(positions:Array<Float>, normals:Array<Float>, uvs:Array<Float>, indices:Array<Int>, bounds:Dynamic, points:PolygonPoints, depth:Float, flip:Bool) {
		var StartIndex:Int = Std.int(positions.length / 3);
		var ulength:Float = 0;
		for (i in 0...points.elements.length) {
			var p:IndexedPoint = points.elements[i];
			var p1:IndexedPoint = null;
			if ((i + 1) > points.elements.length - 1) {
				p1 = points.elements[0];
			}
			else {
				p1 = points.elements[i + 1];
			}
			
			positions.push(p.x);
			positions.push(0);
			positions.push(p.y);
			positions.push(p.x);
			positions.push( -depth);
			positions.push(p.y);
			positions.push(p1.x);
			positions.push(0);
			positions.push(p1.y);
			positions.push(p1.x);
			positions.push( -depth);
			positions.push(p1.y);
			
			var v1 = new Vector3(p.x, 0, p.y);
			var v2 = new Vector3(p1.x, 0, p1.y);
			var v3 = v2.subtract(v1);
			var v4 = new Vector3(0, 1, 0);
			var vn = Vector3.Cross(v3, v4);
			vn = vn.normalize();
			
			uvs.push(ulength / bounds.width);
			uvs.push(0);
			uvs.push(ulength / bounds.width);
			uvs.push(1);
			ulength += v3.length();
			uvs.push((ulength / bounds.width));
			uvs.push(0);
			uvs.push((ulength / bounds.width));
			uvs.push(1);
			
			if (!flip) {
				normals.push( -vn.x);
				normals.push( - vn.y);
				normals.push(-vn.z);
				normals.push( -vn.x);
				normals.push( -vn.y);
				normals.push(-vn.z);
				normals.push( -vn.x);
				normals.push( -vn.y);
				normals.push(-vn.z);
				normals.push( -vn.x);
				normals.push( -vn.y);
				normals.push(-vn.z);
				
				indices.push(StartIndex);
				indices.push(StartIndex + 1);
				indices.push(StartIndex + 2);
				
				indices.push(StartIndex + 1);
				indices.push(StartIndex + 3);
				indices.push(StartIndex + 2);
			}
			else {
				normals.push(vn.x);
				normals.push(vn.y);
				normals.push(vn.z);
				normals.push(vn.x);
				normals.push(vn.y);
				normals.push(vn.z);
				normals.push(vn.x);
				normals.push(vn.y);
				normals.push(vn.z);
				normals.push(vn.x);
				normals.push(vn.y);
				normals.push(vn.z);
				
				indices.push(StartIndex);
				indices.push(StartIndex + 2);
				indices.push(StartIndex + 1);
				
				indices.push(StartIndex + 1);
				indices.push(StartIndex + 2);
				indices.push(StartIndex + 3);
			}                
			StartIndex += 4;
		}
	}

}
