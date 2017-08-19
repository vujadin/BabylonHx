package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Path2;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;

import lime.utils.Float32Array;
import lime.utils.Int32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.PolygonMeshBuilder') class PolygonMeshBuilder {

	private var _points:PolygonPoints = new PolygonPoints();
	private var _outlinepoints:PolygonPoints = new PolygonPoints();
	private var _holes:Array<PolygonPoints> = [];
		
	private var name:String;
	private var scene:Scene;
	
	private var _epoints:Array<Float> = [];
	private var _eholes:Array<Int> = [];

	
	public function new(name:String, contours:Dynamic, scene:Scene) {
		this.name = name;
		this.scene = scene;
		
		var points:Array<Vector2> = [];
		if (Std.is(contours, Path2)) {
			points = cast(contours, Path2).getPoints();
		} 
		else {
			points = cast contours;
		}
		
		this._addToepoint(points);
		
		this._points.add(points);
		this._outlinepoints.add(points);
	}
	
	private function _addToepoint(points:Array<Vector2>) {
		for (p in points) {
			this._epoints.push(p.x);
			this._epoints.push(p.y);
		}
	}

	public function addHole(hole:Array<Vector2>):PolygonMeshBuilder {
		this._points.add(hole);
		var holepoints = new PolygonPoints();
		holepoints.add(hole);
		this._holes.push(holepoints);
		
		this._eholes.push(Std.int(this._epoints.length / 2));
		this._addToepoint(hole);
		
		return this;
	}

	public function build(updatable:Bool = false, depth:Float = 10):Mesh {
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
		
		var indices:Array<Int> = Earcut.earcut(this._epoints, this._eholes, 2);
		
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
			
			var totalCount:Int = indices.length;
			var i:Int = 0;
			while (i < totalCount) {
				var i0 = indices[i + 0];
				var i1 = indices[i + 1];
				var i2 = indices[i + 2];
				
				indices.push(i2 + positionscount);
				indices.push(i1 + positionscount);
				indices.push(i0 + positionscount);
				
				i += 3;
			}
			
			//Add the sides
			this.addSide(positions, normals, uvs, indices, bounds, this._outlinepoints, depth, false);
			
			for(hole in this._holes) {
				this.addSide(positions, normals, uvs, indices, bounds, hole, depth, true);
			}                            
		}
		
		result.setVerticesData(VertexBuffer.PositionKind, new Float32Array(positions), updatable);
		result.setVerticesData(VertexBuffer.NormalKind, new Float32Array(normals), updatable);
		result.setVerticesData(VertexBuffer.UVKind, new Float32Array(uvs), updatable);
		result.setIndices(new Int32Array(indices));
		
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
