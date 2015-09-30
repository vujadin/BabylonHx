package com.babylonhx.mesh;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Color4;

import com.babylonhx.utils.typedarray.UInt8Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.VertexData') class VertexData {
	
	public var positions:Array<Float>;
	public var normals:Array<Float>;
	public var uvs:Array<Float>;
	public var uv2s:Array<Float>;
	public var uv3s:Array<Float>;
	public var uv4s:Array<Float>;
	public var uv5s:Array<Float>;
	public var uv6s:Array<Float>;
	public var colors:Array<Float>;
	public var matricesIndices:Array<Float>;
	public var matricesWeights:Array<Float>;
	public var indices:Array<Int>;
	
	// for ribbon
	public var _idx:Array<Int>;
	
	
	public function new() {
		// nothing to do here ...
	}

	public function set(data:Array<Float>, kind:String) {
		switch (kind) {
			case VertexBuffer.PositionKind:
				this.positions = data;
				
			case VertexBuffer.NormalKind:
				this.normals = data;
				
			case VertexBuffer.UVKind:
				this.uvs = data;
				
			case VertexBuffer.UV2Kind:
				this.uv2s = data;
				
			case VertexBuffer.UV3Kind:
				this.uv3s = data;
				
			case VertexBuffer.UV4Kind:
				this.uv4s = data;
				
			case VertexBuffer.UV5Kind:
				this.uv5s = data;
				
			case VertexBuffer.UV6Kind:
				this.uv6s = data;				
				
			case VertexBuffer.ColorKind:
				this.colors = data;
				
			case VertexBuffer.MatricesIndicesKind:
				this.matricesIndices = data;
				
			case VertexBuffer.MatricesWeightsKind:
				this.matricesWeights = data;
				
			default:
				// nothing
				
		}
	}

	public function applyToMesh(mesh:Mesh, updatable:Bool = false) {
		this._applyTo(mesh, updatable);
	}

	public function applyToGeometry(geometry:Geometry, updatable:Bool = false) {
		this._applyTo(geometry, updatable);
	}

	public function updateMesh(mesh:Mesh, ?updateExtends:Bool, makeItUnique:Bool = false) {
		this._update(mesh);
	}

	public function updateGeometry(geometry:Geometry, ?updateExtends:Bool, makeItUnique:Bool = false) {
		this._update(geometry);
	}

	private function _applyTo(meshOrGeometry:IGetSetVerticesData, updatable:Bool = false) {
		if (this.positions != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.PositionKind, this.positions, updatable);
		}
		
		if (this.normals != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.NormalKind, this.normals, updatable);
		}
		
		if (this.uvs != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.UVKind, this.uvs, updatable);
		}
		
		if (this.uv2s != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.UV2Kind, this.uv2s, updatable);
		}
		
		if (this.uv3s != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.UV3Kind, this.uv3s, updatable);
		}
		
		if (this.uv4s != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.UV4Kind, this.uv4s, updatable);
		}
		
		if (this.uv5s != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.UV5Kind, this.uv5s, updatable);
		}
		
		if (this.uv6s != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.UV6Kind, this.uv6s, updatable);
		}
		
		if (this.colors != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.ColorKind, this.colors, updatable);
		}
		
		if (this.matricesIndices != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.MatricesIndicesKind, this.matricesIndices, updatable);
		}
		
		if (this.matricesWeights != null) {
			meshOrGeometry.setVerticesData(VertexBuffer.MatricesWeightsKind, this.matricesWeights, updatable);
		}
		
		if (this.indices != null) {
			meshOrGeometry.setIndices(this.indices);
		}
	}

	private function _update(meshOrGeometry:IGetSetVerticesData, ?updateExtends:Bool, makeItUnique:Bool = false) {
		if (this.positions != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.PositionKind, this.positions, updateExtends, makeItUnique);
		}
		
		if (this.normals != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.NormalKind, this.normals, updateExtends, makeItUnique);
		}
		
		if (this.uvs != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.UVKind, this.uvs, updateExtends, makeItUnique);
		}
		
		if (this.uv2s != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.UV2Kind, this.uv2s, updateExtends, makeItUnique);
		}
		
		if (this.uv3s != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.UV3Kind, this.uv3s, updateExtends, makeItUnique);
		}
		
		if (this.uv4s != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.UV4Kind, this.uv4s, updateExtends, makeItUnique);
		}
		
		if (this.uv5s != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.UV5Kind, this.uv5s, updateExtends, makeItUnique);
		}
		
		if (this.uv6s != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.UV6Kind, this.uv6s, updateExtends, makeItUnique);
		}
		
		if (this.colors != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.ColorKind, this.colors, updateExtends, makeItUnique);
		}
		
		if (this.matricesIndices != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.MatricesIndicesKind, this.matricesIndices, updateExtends, makeItUnique);
		}
		
		if (this.matricesWeights != null) {
			meshOrGeometry.updateVerticesData(VertexBuffer.MatricesWeightsKind, this.matricesWeights, updateExtends, makeItUnique);
		}
		
		if (this.indices != null) {
			meshOrGeometry.setIndices(this.indices);
		}
	}

	static var transformed:Vector3 = Vector3.Zero();
	inline public function transform(matrix:Matrix) {		
		if (this.positions != null) {
			var position = Vector3.Zero();
			
			var index:Int = 0;
			while(index < this.positions.length) {
				Vector3.FromArrayToRef(this.positions, index, position);
				
				Vector3.TransformCoordinatesToRef(position, matrix, transformed);
				this.positions[index] = transformed.x;
				this.positions[index + 1] = transformed.y;
				this.positions[index + 2] = transformed.z;
				
				index += 3;
			}
		}
		
		if (this.normals != null) {
			var normal = Vector3.Zero();
			
			var index:Int = 0;
			while(index < this.normals.length) {
				Vector3.FromArrayToRef(this.normals, index, normal);
				
				Vector3.TransformNormalToRef(normal, matrix, transformed);
				this.normals[index] = transformed.x;
				this.normals[index + 1] = transformed.y;
				this.normals[index + 2] = transformed.z;
				
				index += 3;
			}
		}
	}

	public function merge(other:VertexData) {
		if (other.indices != null) {
			if (this.indices == null) {
				this.indices = [];
			}
			
			var offset = Std.int(this.positions == null ? this.positions.length / 3 : 0);
			for (index in 0...other.indices.length) {
				this.indices.push(other.indices[index] + offset);
			}
		}
		
		if (other.positions != null) {
			if (this.positions == null) {
				this.positions = [];
			}
			
			for (index in 0...other.positions.length) {
				this.positions.push(other.positions[index]);
			}
		}
		
		if (other.normals != null) {
			if (this.normals == null) {
				this.normals = [];
			}
			for (index in 0...other.normals.length) {
				this.normals.push(other.normals[index]);
			}
		}
		
		if (other.uvs != null) {
			if (this.uvs == null) {
				this.uvs = [];
			}
			for (index in 0...other.uvs.length) {
				this.uvs.push(other.uvs[index]);
			}
		}
		
		if (other.uv2s != null) {
			if (this.uv2s == null) {
				this.uv2s = [];
			}
			for (index in 0...other.uv2s.length) {
				this.uv2s.push(other.uv2s[index]);
			}
		}
		
		if (other.uv3s != null) {
			if (this.uv3s == null) {
				this.uv3s = [];
			}
			for (index in 0...other.uv3s.length) {
				this.uv3s.push(other.uv3s[index]);
			}
		}
		
		if (other.uv4s != null) {
			if (this.uv4s == null) {
				this.uv4s = [];
			}
			for (index in 0...other.uv4s.length) {
				this.uv4s.push(other.uv4s[index]);
			}
		}
		
		if (other.uv5s != null) {
			if (this.uv5s == null) {
				this.uv5s = [];
			}
			for (index in 0...other.uv5s.length) {
				this.uv5s.push(other.uv5s[index]);
			}
		}
		
		if (other.uv6s != null) {
			if (this.uv6s == null) {
				this.uv6s = [];
			}
			for (index in 0...other.uv6s.length) {
				this.uv6s.push(other.uv6s[index]);
			}
		}
		
		if (other.matricesIndices != null) {
			if (this.matricesIndices == null) {
				this.matricesIndices = [];
			}
			for (index in 0...other.matricesIndices.length) {
				this.matricesIndices.push(other.matricesIndices[index]);
			}
		}
		
		if (other.matricesWeights != null) {
			if (this.matricesWeights == null) {
				this.matricesWeights = [];
			}
			for (index in 0...other.matricesWeights.length) {
				this.matricesWeights.push(other.matricesWeights[index]);
			}
		}
		
		if (other.colors != null) {
			if (this.colors == null) {
				this.colors = [];
			}
			for (index in 0...other.colors.length) {
				this.colors.push(other.colors[index]);
			}
		}
	}

	// Statics
	public static function ExtractFromMesh(mesh:Mesh, copyWhenShared:Bool = false):VertexData {
		return VertexData._ExtractFrom(mesh, copyWhenShared);
	}

	public static function ExtractFromGeometry(geometry:Geometry, copyWhenShared:Bool = false):VertexData {
		return VertexData._ExtractFrom(geometry, copyWhenShared);
	}

	private static function _ExtractFrom(meshOrGeometry:IGetSetVerticesData, copyWhenShared:Bool = false):VertexData {
		var result = new VertexData();
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.PositionKind)) {
			result.positions = meshOrGeometry.getVerticesData(VertexBuffer.PositionKind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.NormalKind)) {
			result.normals = meshOrGeometry.getVerticesData(VertexBuffer.NormalKind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.UVKind)) {
			result.uvs = meshOrGeometry.getVerticesData(VertexBuffer.UVKind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
			result.uv2s = meshOrGeometry.getVerticesData(VertexBuffer.UV2Kind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.UV3Kind)) {
			result.uv3s = meshOrGeometry.getVerticesData(VertexBuffer.UV3Kind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.UV4Kind)) {
			result.uv4s = meshOrGeometry.getVerticesData(VertexBuffer.UV4Kind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.UV5Kind)) {
			result.uv5s = meshOrGeometry.getVerticesData(VertexBuffer.UV5Kind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.UV6Kind)) {
			result.uv6s = meshOrGeometry.getVerticesData(VertexBuffer.UV6Kind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.ColorKind)) {
			result.colors = meshOrGeometry.getVerticesData(VertexBuffer.ColorKind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind)) {
			result.matricesIndices = meshOrGeometry.getVerticesData(VertexBuffer.MatricesIndicesKind, copyWhenShared);
		}
		
		if (meshOrGeometry.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
			result.matricesWeights = meshOrGeometry.getVerticesData(VertexBuffer.MatricesWeightsKind, copyWhenShared);
		}
		
		result.indices = meshOrGeometry.getIndices(copyWhenShared);
		
		return result;
	}
	
	public static function CreateRibbon(options:Dynamic, closeArray:Bool = false, closePath:Bool = false, ?offset:Int, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {
		var pathArray:Array<Array<Vector3>> = cast(options.pathArray != null ? options.pathArray : options);
		var defaultOffset = Math.floor(pathArray[0].length / 2);
		offset = options.offset != null ? options.offset : (offset != null ? offset : defaultOffset);
		offset = offset > defaultOffset ? defaultOffset : Math.floor(offset); // offset max allowed : defaultOffset
		
		if (options.sideOrientation != null) {
			sideOrientation = options.sideOrientation;
		}
		
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var us:Array<Array<Float>> = [];        		// us[path_id] = [uDist1, uDist2, uDist3 ... ] distances between points on path path_id
		var vs:Array<Array<Float>> = [];        		// vs[i] = [vDist1, vDist2, vDist3, ... ] distances between points i of consecutives paths from pathArray
		var uTotalDistance:Array<Float> = []; 			// uTotalDistance[p] : total distance of path p
		var vTotalDistance:Array<Float> = []; 			//  vTotalDistance[i] : total distance between points i of first and last path from pathArray
		var minlg:Int = 0;          	        		// minimal length among all paths from pathArray
		var vectlg:Float = 0;
		var dist:Float = 0;
		var lg:Array<Int> = [];        		    		// array of path lengths : nb of vertex per path
		var idx:Array<Int> = [];       		    		// array of path indexes : index of each path (first vertex) in the total vertex number
		
		var p:Int = 0;									// path iterator
		var i:Int = 0;									// point iterator
		var j:Int = 0;									// point iterator
		
		// if single path in pathArray
		if (pathArray.length < 2) {
			var ar1:Array<Vector3> = [];
			var ar2:Array<Vector3> = [];
			for (i in 0...pathArray[0].length - offset) {
				ar1.push(pathArray[0][i]);
				ar2.push(pathArray[0][i + offset]);
			}
			pathArray = [ar1, ar2];
		}
		
		// positions and horizontal distances (u)
		var idc:Int = 0;
		var closePathCorr:Int = closePath ? 1 : 0;
		var path:Array<Vector3> = [];
		var l:Int = 0;
		minlg = pathArray[0].length;
		for (p in 0...pathArray.length) {
			uTotalDistance[p] = 0;
			us[p] = [0];
			path = pathArray[p];
			l = path.length;
			minlg = (minlg < l) ? minlg : l;
			
			j = 0;
			while (j < l) {
				positions.push(path[j].x);
				positions.push(path[j].y);
				positions.push(path[j].z);
				if (j > 0) {
					var vectlg = path[j].subtract(path[j - 1]).length();
					var dist = vectlg + uTotalDistance[p];
					us[p].push(dist);
					uTotalDistance[p] = dist;
				}
				j++;
			}
			
			if (closePath) {
				j--;
				positions.push(path[0].x);
				positions.push(path[0].y);
				positions.push(path[0].z);
				vectlg = path[j].subtract(path[0]).length();
				dist = vectlg + uTotalDistance[p];
				us[p].push(dist);
				uTotalDistance[p] = dist;
			}
			
			lg[p] = l + closePathCorr;
			idx[p] = idc;
			idc += (l + closePathCorr);
		}
		
		// vertical distances (v)
		var path1:Array<Vector3> = [];
		var path2:Array<Vector3> = [];
		var vertex1:Vector3;
		var vertex2:Vector3;
		for (i in 0...minlg + closePathCorr) {
			vTotalDistance[i] = 0;
			vs[i] = [0];
			for (p in 0...pathArray.length - 1) {
				path1 = pathArray[p];
				path2 = pathArray[p + 1];
				if (i == minlg) {   // closePath
					vertex1 = path1[0];
					vertex2 = path2[0];
				}
				else {
					vertex1 = path1[i];
					vertex2 = path2[i];
				}
				vectlg = vertex2.subtract(vertex1).length();
				dist = vectlg + vTotalDistance[i];
				vs[i].push(dist);
				vTotalDistance[i] = dist;
			}
			if (closeArray) {
				path1 = pathArray[p];
				path2 = pathArray[0];
				vectlg = path2[i].subtract(path1[i]).length();
				dist = vectlg + vTotalDistance[i];
				vTotalDistance[i] = dist;
			}
		}
		
		// uvs            
		var u:Float = 0;
		var v:Float = 0;
		for (p in 0...pathArray.length) {
			for (i in 0...minlg + closePathCorr) {
				u = us[p][i] / uTotalDistance[p];
				v = vs[i][p] / vTotalDistance[i];
				uvs.push(u);
				uvs.push(v);
			}
		}
		
		// indices
		p = 0;                    									  // path index
		var pi:Int = 0;                    							  // positions array index
		var l1:Int = lg[p] - 1;           							  // path1 length
		var l2:Int = lg[p + 1] - 1;         						  // path2 length
		var min:Int = (l1 < l2) ? l1 : l2;   						  // current path stop index
		var shft:Int = idx[1] - idx[0];         					  // shift 
		var path1nb:Int = closeArray ? lg.length : lg.length - 1;     // number of path1 to iterate	on
		
		while (pi <= min && p < path1nb) {       	//  stay under min and don't go over next to last path
			// draw two triangles between path1 (p1) and path2 (p2) : (p1.pi, p2.pi, p1.pi+1) and (p2.pi+1, p1.pi+1, p2.pi) clockwise
			indices.push(pi);
			indices.push(pi + shft);
			indices.push(pi + 1);
			indices.push(pi + shft + 1);
			indices.push(pi + 1);
			indices.push(pi + shft);
			pi += 1;
			if (pi == min) {             			// if end of one of two consecutive paths reached, go to next existing path
				p++;
				if (p == lg.length - 1) {          // last path of pathArray reached <=> closeArray == true
					shft = idx[0] - idx[p];
					l1 = lg[p] - 1;
					l2 = lg[0] - 1;
				}
				else {
					shft = idx[p + 1] - idx[p];
					l1 = lg[p] - 1;
					l2 = lg[p + 1] - 1;
				}
				pi = idx[p];
				min = (l1 < l2) ? l1 + pi : l2 + pi;
			}
		}
		
		// normals
		VertexData.ComputeNormals(positions, indices, normals);
		
		if (closePath) {
			var indexFirst:Int = 0;
			var indexLast:Int = 0;
			for (p in 0...pathArray.length) {
				indexFirst = idx[p] * 3;
				if (p + 1 < pathArray.length) {
					indexLast = (idx[p + 1] - 1) * 3;
				}
				else {
					indexLast = normals.length - 3;
				}
				normals[indexFirst] = (normals[indexFirst] + normals[indexLast]) * 0.5;
				normals[indexFirst + 1] = (normals[indexFirst + 1] + normals[indexLast + 1]) * 0.5;
				normals[indexFirst + 2] = (normals[indexFirst + 2] + normals[indexLast + 2]) * 0.5;
				normals[indexLast] = normals[indexFirst];
				normals[indexLast + 1] = normals[indexFirst + 1];
				normals[indexLast + 2] = normals[indexFirst + 2];
			}
		}
		
		// sides
		VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
						
		if (closePath) {
			vertexData._idx = idx;
		}
		
		return vertexData;
	}
	
	public static function CreateBox(options:Dynamic, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {
		var normalsSource = [
			new Vector3(0, 0, 1),
			new Vector3(0, 0, -1),
			new Vector3(1, 0, 0),
			new Vector3(-1, 0, 0),
			new Vector3(0, 1, 0),
			new Vector3(0, -1, 0)
		];
		
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var width:Float = 1;
		var height:Float = 1;
		var depth:Float = 1;
		var faceUV:Array<Vector4> = options.faceUV != null ? options.faceUV : new Array<Vector4>();
		var faceColors:Array<Color4> = [];
		var colors:Array<Float> = [];
		
		if (options.faceColors != null) {
			faceColors = options.faceColors;
		}
		
		if (options.width != null) {
			width = options.width != null ? options.width : 1;
			height = options.height != null ? options.height : 1;
			depth = options.depth != null ? options.depth : 1;
		} 
		else { // back-compat with size parameter
			width = options != null ? options : 1;
			height = width;
			depth = height;
		}
		
		if (options.sideOrientation != null) {
			sideOrientation = options.sideOrientation;
		}
		
		for (f in 0...6) {
			if (faceUV[f] == null) {
				faceUV[f] = new Vector4(0, 0, 1, 1);
			}
			if (faceColors != null && faceColors[f] == null) {
				faceColors[f] = new Color4(1, 1, 1, 1);
			}
		}
		
		var scaleVector = new Vector3(width / 2, height / 2, depth / 2);
		
		// Create each face in turn.
		for (index in 0...normalsSource.length) {
			var normal:Vector3 = normalsSource[index];
			
			// Get two vectors perpendicular to the face normal and to each other.
			var side1 = new Vector3(normal.y, normal.z, normal.x);
			var side2 = Vector3.Cross(normal, side1);
			
			// Six indices (two triangles) per face.
			var verticesLength = Std.int(positions.length / 3);
			indices.push(verticesLength);
			indices.push(verticesLength + 1);
			indices.push(verticesLength + 2);
			
			indices.push(verticesLength);
			indices.push(verticesLength + 2);
			indices.push(verticesLength + 3);
			
			// Four vertices per face.
			var vertex = normal.subtract(side1).subtract(side2).multiply(scaleVector);
			positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);			
			normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
			uvs.push(1.0);
			uvs.push(1.0);			
			if (faceColors != null) {
				colors.push(faceColors[index].r);
				colors.push(faceColors[index].g);
				colors.push(faceColors[index].b);
				colors.push(faceColors[index].a);
			}
			
			vertex = normal.subtract(side1).add(side2).multiply(scaleVector);
			positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);
			normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
			uvs.push(0.0);
			uvs.push(1.0);
			if (faceColors != null) {
				colors.push(faceColors[index].r);
				colors.push(faceColors[index].g);
				colors.push(faceColors[index].b);
				colors.push(faceColors[index].a);
			}
			
			vertex = normal.add(side1).add(side2).multiply(scaleVector);
			positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);
			normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
			uvs.push(0.0);
			uvs.push(0.0);
			if (faceColors != null) {
				colors.push(faceColors[index].r);
				colors.push(faceColors[index].g);
				colors.push(faceColors[index].b);
				colors.push(faceColors[index].a);
			}
			
			vertex = normal.add(side1).subtract(side2).multiply(scaleVector);
			positions.push(vertex.x);
			positions.push(vertex.y);
			positions.push(vertex.z);
			normals.push(normal.x);
			normals.push(normal.y);
			normals.push(normal.z);
			uvs.push(1.0);
			uvs.push(0.0);
			if (faceColors != null) {
				colors.push(faceColors[index].r);
				colors.push(faceColors[index].g);
				colors.push(faceColors[index].b);
				colors.push(faceColors[index].a);
			}
		}
		
		// sides
		VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		if (faceColors != null && faceColors.length > 0) {
			var totalColors = (sideOrientation == Mesh.DOUBLESIDE) ? colors.concat(colors) : colors;
			vertexData.colors = totalColors;
		}
		
		return vertexData;
	}

	public static function CreateSphere(options:Dynamic, diameter:Float = 1, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {
				
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var segments:Int = 32;
		var diameterX:Float = 1;
		var diameterY:Float = 1;
		var diameterZ:Float = 1;
		if (options.segments != null) {
			segments = options.segments != null ? options.segments : 32;
			diameterX = options.diameterX != null ? options.diameterX : 1;
			diameterY = options.diameterY != null ? options.diameterY : 1;
			diameterZ = options.diameterZ != null ? options.diameterZ : 1;
		}
		else {
			segments = options != null ? options : 32;
			diameterX = diameter;
			diameterY = diameterX;
			diameterZ = diameterX;
		}
		//sideOrientation = sideOrientation || options.sideOrientation;
		var radius = new Vector3(diameterX / 2, diameterY / 2, diameterZ / 2);
		var totalZRotationSteps = 2 + segments;
		var totalYRotationSteps = 2 * totalZRotationSteps;
		
		for (zRotationStep in 0...totalZRotationSteps + 1) {
			var normalizedZ = zRotationStep / totalZRotationSteps;
			var angleZ = (normalizedZ * Math.PI);
			for (yRotationStep in 0...totalYRotationSteps + 1) {
				var normalizedY = yRotationStep / totalYRotationSteps;
				var angleY = normalizedY * Math.PI * 2;
				var rotationZ = Matrix.RotationZ(-angleZ);
				var rotationY = Matrix.RotationY(angleY);
				var afterRotZ = Vector3.TransformCoordinates(Vector3.Up(), rotationZ);
				var complete = Vector3.TransformCoordinates(afterRotZ, rotationY);
				var vertex = complete.multiply(radius);
				var normal = Vector3.Normalize(vertex);
				positions.push(vertex.x);
				positions.push(vertex.y);
				positions.push(vertex.z);
				normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
				uvs.push(normalizedY);
				uvs.push(normalizedZ);
			}
			if (zRotationStep > 0) {
				var verticesCount = positions.length / 3;
				var firstIndex = Std.int(verticesCount - 2 * (totalYRotationSteps + 1));
				while ((firstIndex + totalYRotationSteps + 2) < verticesCount) {
					indices.push(firstIndex);
					indices.push(firstIndex + 1);
					indices.push(firstIndex + totalYRotationSteps + 1);
					indices.push(firstIndex + totalYRotationSteps + 1);
					indices.push(firstIndex + 1);
					indices.push(firstIndex + totalYRotationSteps + 2);
					
					++firstIndex;
				}
			}
		}
		
		// Sides
		VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		// Result
		var vertexData = new VertexData();
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	// Cylinder and cone (made using ribbons)
	public static function CreateCylinder(options:Dynamic, diameterTop:Float = 0.5, diameterBottom:Float = 1, tessellation:Int = 16, subdivisions:Int = 1, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {		
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var height:Float = options.height != null ? options.height : 3;
		
		if (options.diameterTop != null) {
			diameterTop = options.diameterTop;
		}
		
		if (options.diameterBottom != null) {
			diameterBottom = options.diameterBottom;
		}
		
		if (options.tessellation != null) {
			tessellation = options.tessellation;
		}
		
		if (options.subdivisions != null) {
			subdivisions = options.subdivisions;
		}
		
		if (options.sideOrientation != null) {
			sideOrientation = options.sideOrientation;
		}
		
		var angle_step:Float = Math.PI * 2 / tessellation;
		var angle:Float = 0;
		var h:Float = 0;
		var radius:Float = 0;
		var tan:Float = (diameterBottom - diameterTop) / 2 / height;
		var ringVertex:Vector3 = Vector3.Zero();
		var ringNormal:Vector3 = Vector3.Zero();
		
		// positions, normals, uvs
		for (i in 0...subdivisions + 1) {
			h = i / subdivisions;
			radius = (h * (diameterTop - diameterBottom) + diameterBottom) / 2;
			for (j in 0...tessellation + 1) {
				angle = j * angle_step;
				ringVertex.x = Math.cos(-angle) * radius;
				ringVertex.y = -height / 2 + h * height;
				ringVertex.z = Math.sin(-angle) * radius;
				if (diameterTop == 0 && i == subdivisions) {
					// if no top cap, reuse former normals
					ringNormal.x = normals[normals.length - (tessellation + 1) * 3];
					ringNormal.y = normals[normals.length - (tessellation + 1) * 3 + 1];
					ringNormal.z = normals[normals.length - (tessellation + 1) * 3 + 2];
				}
				else {
					ringNormal.x = ringVertex.x;
					ringNormal.z = ringVertex.z;
					ringNormal.y = Math.sqrt(ringNormal.x * ringNormal.x + ringNormal.z * ringNormal.z) * tan;
					ringNormal.normalize();
				}
				positions.push(ringVertex.x);
				positions.push(ringVertex.y);
				positions.push(ringVertex.z);
				
				normals.push(ringNormal.x);
				normals.push(ringNormal.y);
				normals.push(ringNormal.z);
				
				uvs.push(j / tessellation);
				uvs.push(1 - h);
			}
		}
		
		// indices
		for (i in 0...subdivisions) {
			for (j in 0...tessellation) {
				var i0 = i * (tessellation + 1) + j;
				var i1 = (i + 1) * (tessellation + 1) + j;
				var i2 = i * (tessellation + 1) + (j + 1);
				var i3 = (i + 1) * (tessellation + 1) + (j + 1);
				indices.push(i0);
				indices.push(i1);
				indices.push(i2);
				indices.push(i3);
				indices.push(i2);
				indices.push(i1);
			}
		}
		
		// Caps
		var createCylinderCap = function(isTop:Bool) {
			var radius = isTop ? diameterTop / 2 : diameterBottom / 2;
			if (radius == 0) {
				return;
			}
			var vbase = Std.int(positions.length / 3);
			var offset = new Vector3(0, isTop ? height / 2 : -height / 2, 0);
			var textureScale = new Vector2(0.5, 0.5);
			// Cap positions, normals & uvs
			var angle:Float = 0;
			var circleVector:Vector3 = null;
			
			for (i in 0...tessellation) {
				angle = Math.PI * 2 * i / tessellation;
				circleVector = new Vector3(Math.cos(-angle), 0, Math.sin(-angle));
				var position = circleVector.scale(radius).add(offset);
				var textureCoordinate = new Vector2(circleVector.x * textureScale.x + 0.5, circleVector.z * textureScale.y + 0.5);
				positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
				
				normals.push(0);
				normals.push(isTop ? 1 : -1);
				normals.push(0);
				
				uvs.push(textureCoordinate.x);
				uvs.push(textureCoordinate.y);
			}
			// Cap indices
			for (i in 0...tessellation - 2) {
				if (!isTop) {
					indices.push(vbase);
					indices.push(vbase + (i + 1) % tessellation);
					indices.push(vbase + (i + 2) % tessellation);
				}
				else {
					indices.push(vbase);
					indices.push(vbase + (i + 2) % tessellation);
					indices.push(vbase + (i + 1) % tessellation);
				}
			}
		};
		
		// add caps to geometry
		createCylinderCap(true);
		createCylinderCap(false);
		
		// Sides
		VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	public static function CreateTorus(diameter:Float = 1, thickness:Float = 0.5, tessellation:Int = 16, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var stride = tessellation + 1;
		
		for (i in 0...tessellation + 1) {
			var u = i / tessellation;			
			var outerAngle = i * Math.PI * 2.0 / tessellation - Math.PI / 2.0;			
			var transform = Matrix.Translation(diameter / 2.0, 0, 0).multiply(Matrix.RotationY(outerAngle));
			
			for (j in 0...tessellation + 1) {
				var v = 1 - j / tessellation;
				
				var innerAngle = j * Math.PI * 2.0 / tessellation + Math.PI;
				var dx = Math.cos(innerAngle);
				var dy = Math.sin(innerAngle);
				
				// Create a vertex.
				var normal = new Vector3(dx, dy, 0);
				var position = normal.scale(thickness / 2);
				var textureCoordinate = new Vector2(u, v);
				
				position = Vector3.TransformCoordinates(position, transform);
				normal = Vector3.TransformNormal(normal, transform);
				
				positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
				normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
				uvs.push(textureCoordinate.x);
				uvs.push(textureCoordinate.y);
				
				// And create indices for two triangles.
				var nextI = (i + 1) % stride;
				var nextJ = (j + 1) % stride;
				
				indices.push(i * stride + j);
				indices.push(i * stride + nextJ);
				indices.push(nextI * stride + j);
				
				indices.push(i * stride + nextJ);
				indices.push(nextI * stride + nextJ);
				indices.push(nextI * stride + j);
			}
		}
		
		// Sides
        VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	public static function CreateLines(points:Array<Vector3>):VertexData {
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		
		for (index in 0...points.length) {
			positions.push(points[index].x);
			positions.push(points[index].y);
			positions.push(points[index].z);
			
			if (index > 0) {
				indices.push(index - 1);
				indices.push(index);
			}
		}
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		
		return vertexData;
	}
	
	public static function CreateDashedLines(points:Array<Vector3>, dashSize:Float = 3, gapSize:Float = 1, dashNb:Float = 100):VertexData {
		var positions:Array<Float> = [];
		var indices:Array<Int> = [];
		
		var curvect:Vector3 = Vector3.Zero();
		var lg:Float = 0;
		var nb:Int = 0;
		var shft:Float = 0;
		var dashshft:Float = 0;
		var curshft:Float = 0;
		var idx:Int = 0;
		for (i in 0...points.length - 1) {
			points[i + 1].subtractToRef(points[i], curvect);
			lg += curvect.length();
		}
		shft = lg / dashNb;
		dashshft = dashSize * shft / (dashSize + gapSize);
		for (i in 0...points.length - 1) {
			points[i + 1].subtractToRef(points[i], curvect);
			nb = Math.floor(curvect.length() / shft);
			curvect.normalize();
			for (j in 0...nb) {
				curshft = shft * j;
				positions.push(points[i].x + curshft * curvect.x);
				positions.push(points[i].y + curshft * curvect.y);
				positions.push(points[i].z + curshft * curvect.z);
				positions.push(points[i].x + (curshft + dashshft) * curvect.x);
				positions.push(points[i].y + (curshft + dashshft) * curvect.y);
				positions.push(points[i].z + (curshft + dashshft) * curvect.z);
				indices.push(idx);
				indices.push(idx + 1);
				idx += 2;
			}
		}
		
		// Result
		var vertexData = new VertexData();
		vertexData.positions = positions;
		vertexData.indices = indices;
		
		return vertexData;
	}

	public static function CreateGround(options:Dynamic, height:Float = 1, subdivisions:Int = 1):VertexData {
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var width:Float = 0;
		
		if (options.width != null) {
			width = options.width != null ? options.width : 1;
			height = options.height != null ? options.height : 1;
			subdivisions = options.subdivisions != null ? options.subdivisions : 1;
		} 
		else {
			width = options != null ? options : 1;
			height = options != null ? options : 1;
		}
		
		for (row in 0...subdivisions + 1) {
			for (col in 0...subdivisions + 1) {
				var position = new Vector3((col * width) / subdivisions - (width / 2.0), 0, ((subdivisions - row) * height) / subdivisions - (height / 2.0));
				var normal = new Vector3(0, 1.0, 0);
				
				positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
				normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
				uvs.push(col / subdivisions);
				uvs.push(1.0 - row / subdivisions);
			}
		}
		
		for (row in 0...subdivisions) {
			for (col in 0...subdivisions) {
				indices.push(col + 1 + (row + 1) * (subdivisions + 1));
				indices.push(col + 1 + row * (subdivisions + 1));
				indices.push(col + row * (subdivisions + 1));
				
				indices.push(col + (row + 1) * (subdivisions + 1));
				indices.push(col + 1 + (row + 1) * (subdivisions + 1));
				indices.push(col + row * (subdivisions + 1));
			}
		}
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	public static function CreateTiledGround(xmin:Float, zmin:Float, xmax:Float, zmax:Float, ?subdivisions:Dynamic, ?precision:Dynamic):VertexData {
		if (subdivisions == null) {
			subdivisions = { w: 1, h: 1 };
		}
		if (precision == null) {
			precision = { w: 1, h: 1 };
		}
		
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		subdivisions.h = (subdivisions.w < 1) ? 1 : subdivisions.h;
		subdivisions.w = (subdivisions.w < 1) ? 1 : subdivisions.w;
		precision.w = (precision.w < 1) ? 1 : precision.w;
		precision.h = (precision.h < 1) ? 1 : precision.h;
		
		var tileSize = {
			w: (xmax - xmin) / subdivisions.w,
			h: (zmax - zmin) / subdivisions.h
		};
		
		function applyTile(xTileMin:Float, zTileMin:Float, xTileMax:Float, zTileMax:Float) {
			// Indices
			var base = positions.length / 3;
			var rowLength = precision.w + 1;
			for (row in 0...precision.h) {
				for (col in 0...precision.w) {
					var square:Array<Int> = [
						Std.int(base + col + row * rowLength),
						Std.int(base + (col + 1) + row * rowLength),
						Std.int(base + (col + 1) + (row + 1) * rowLength),
						Std.int(base + col + (row + 1) * rowLength)
					];
					
					indices.push(square[1]);
					indices.push(square[2]);
					indices.push(square[3]);
					indices.push(square[0]);
					indices.push(square[1]);
					indices.push(square[3]);
				}
			}
			
			// Position, normals and uvs
			var position = Vector3.Zero();
			var normal = new Vector3(0, 1.0, 0);
			for (row in 0...precision.h + 1) {
				position.z = (row * (zTileMax - zTileMin)) / precision.h + zTileMin;
				for (col in 0...precision.w + 1) {
					position.x = (col * (xTileMax - xTileMin)) / precision.w + xTileMin;
					position.y = 0;
					
					positions.push(position.x);
					positions.push(position.y);
					positions.push(position.z);
					normals.push(normal.x);
					normals.push(normal.y);
					normals.push(normal.z);
					uvs.push(col / precision.w);
					uvs.push(row / precision.h);
				}
			}
		}
		
		for (tileRow in 0...subdivisions.h) {
			for (tileCol in 0...subdivisions.w) {
				applyTile(
					xmin + tileCol * tileSize.w,
					zmin + tileRow * tileSize.h,
					xmin + (tileCol + 1) * tileSize.w,
					zmin + (tileRow + 1) * tileSize.h
					);
			}
		}	
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	public static function CreateGroundFromHeightMap(width:Float, height:Float, subdivisions:Int, minHeight:Float, maxHeight:Float, buffer:UInt8Array, bufferWidth:Float, bufferHeight:Float):VertexData {
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		// Vertices
		for (row in 0...subdivisions + 1) {
			for (col in 0...subdivisions + 1) {
				var position = new Vector3((col * width) / subdivisions - (width / 2.0), 0, ((subdivisions - row) * height) / subdivisions - (height / 2.0));
				
				// Compute height
				var heightMapX = Std.int(((position.x + width / 2) / width) * (bufferWidth - 1));
				var heightMapY = Std.int((1.0 - (position.z + height / 2) / height) * (bufferHeight - 1));
				
				var pos = Std.int((heightMapX + heightMapY * bufferWidth) * 4);
				#if !js
				var r = buffer.buffer.get(pos) / 255.0;
				var g = buffer.buffer.get(pos + 1) / 255.0;
				var b = buffer.buffer.get(pos + 2) / 255.0;  // buffer.getUInt8(...
				#else
				var r = buffer[pos] / 255.0;
				var g = buffer[pos + 1] / 255.0;
				var b = buffer[pos + 2] / 255.0;
				#end
				
				var gradient = r * 0.3 + g * 0.59 + b * 0.11;
				position.y = minHeight + (maxHeight - minHeight) * gradient;
				
				// Add  vertex
				positions.push(position.x);
				positions.push(position.y);
				positions.push(position.z);
				normals.push(0);
				normals.push(0);
				normals.push(0);
				uvs.push(col / subdivisions);
				uvs.push(1.0 - row / subdivisions);
			}
		}
		
		// Indices
		for (row in 0...subdivisions) {
			for (col in 0...subdivisions) {
				indices.push(col + 1 + (row + 1) * (subdivisions + 1));
				indices.push(col + 1 + row * (subdivisions + 1));
				indices.push(col + row * (subdivisions + 1));
				
				indices.push(col + (row + 1) * (subdivisions + 1));
				indices.push(col + 1 + (row + 1) * (subdivisions + 1));
				indices.push(col + row * (subdivisions + 1));
			}
		}
		
		// Normals
		VertexData.ComputeNormals(positions, indices, normals);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	public static function CreatePlane(options:Dynamic, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		var width:Float = 1;
		var height:Float = 1;
		
		if (options.width != null) {
			width = options.width != null ? options.width : 1;
			height = options.height != null ? options.height : 1;
			if (options.sideOrientation != null) {
				sideOrientation = options.sideOrientation;
			}
		} 
		else {
			if (options != null) {
				width = height = options;
			}
		}
		
		// Vertices
		var halfWidth = width / 2;
		var halfHeight = height / 2;
		
		// Vertices
		positions.push( -halfWidth);
		positions.push( -halfHeight);
		positions.push(0);
		normals.push(0);
		normals.push(0);
		normals.push(-1.0);
		uvs.push(0.0);
		uvs.push(0.0);
		
		positions.push(halfWidth);
		positions.push( -halfHeight);
		positions.push(0);
		normals.push(0);
		normals.push(0);
		normals.push(-1.0);
		uvs.push(1.0);
		uvs.push(0.0);
		
		positions.push(halfWidth);
		positions.push(halfHeight);
		positions.push(0);
		normals.push(0);
		normals.push(0);
		normals.push(-1.0);
		uvs.push(1.0);
		uvs.push(1.0);
		
		positions.push( -halfWidth);
		positions.push(halfHeight);
		positions.push(0);
		normals.push(0);
		normals.push(0);
		normals.push(-1.0);
		uvs.push(0.0);
		uvs.push(1.0);
		
		// Indices
		indices.push(0);
		indices.push(1);
		indices.push(2);
		
		indices.push(0);
		indices.push(2);
		indices.push(3);
		
		// Sides
        VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}
	
	public static function CreateDisc(radius:Float, tessellation:Int, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		// positions and uvs
		positions.push(0);
		positions.push(0);
		positions.push(0);    // disc center first
		uvs.push(0.5);
		uvs.push(0.5);
		
		var step = Math.PI * 2 / tessellation;
		var a:Float = 0.0;
		while(a < Math.PI * 2) {
			var x = Math.cos(a);
			var y = Math.sin(a);
			var u = (x + 1) / 2;
			var v = (1 - y) / 2;
			positions.push(radius * x);
			positions.push(radius * y);
			positions.push(0);
			uvs.push(u);
			uvs.push(v);
			
			a += step;
		}
		positions.push(positions[3]);
		positions.push(positions[4]);
		positions.push(positions[5]); // close the circle
		uvs.push(uvs[2]);
		uvs.push(uvs[3]);
		
		//indices
		var vertexNb = Std.int(positions.length / 3);
		for (i in 1...vertexNb-1) {
			indices.push(i + 1);
			indices.push(0);
			indices.push(i);
		}
		
		// result
		VertexData.ComputeNormals(positions, indices, normals);
		VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	// based on http://code.google.com/p/away3d/source/browse/trunk/fp10/Away3D/src/away3d/primitives/TorusKnot.as?spec=svn2473&r=2473
	public static function CreateTorusKnot(radius:Float = 2, tube:Float = 0.5, radialSegments:Int = 32, tubularSegments:Int = 32, p:Float = 2, q:Float = 3, sideOrientation:Int = Mesh.DEFAULTSIDE):VertexData {
		var indices:Array<Int> = [];
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		// Helper
		var getPos = function(angle:Float):Vector3 {
			
			var cu = Math.cos(angle);
			var su = Math.sin(angle);
			var quOverP = q / p * angle;
			var cs = Math.cos(quOverP);
			
			var tx = radius * (2 + cs) * 0.5 * cu;
			var ty = radius * (2 + cs) * su * 0.5;
			var tz = radius * Math.sin(quOverP) * 0.5;
			
			return new Vector3(tx, ty, tz);
		};
		
		// Vertices
		for (i in 0...radialSegments + 1) {
			var modI = i % radialSegments;
			var u = modI / radialSegments * 2 * p * Math.PI;
			var p1 = getPos(u);
			var p2 = getPos(u + 0.01);
			var tang = p2.subtract(p1);
			var n = p2.add(p1);
			
			var bitan = Vector3.Cross(tang, n);
			n = Vector3.Cross(bitan, tang);
			
			bitan.normalize();
			n.normalize();
			
			for (j in 0...tubularSegments) {
				var modJ = j % tubularSegments;
				var v = modJ / tubularSegments * 2 * Math.PI;
				var cx = -tube * Math.cos(v);
				var cy = tube * Math.sin(v);
				
				positions.push(p1.x + cx * n.x + cy * bitan.x);
				positions.push(p1.y + cx * n.y + cy * bitan.y);
				positions.push(p1.z + cx * n.z + cy * bitan.z);
				
				uvs.push(i / radialSegments);
				uvs.push(j / tubularSegments);
			}
		}
		
		for (i in 0...radialSegments) {
			for (j in 0...tubularSegments) {
				var jNext = (j + 1) % tubularSegments;
				var a = i * tubularSegments + j;
				var b = (i + 1) * tubularSegments + j;
				var c = (i + 1) * tubularSegments + jNext;
				var d = i * tubularSegments + jNext;
				
				indices.push(d); indices.push(b); indices.push(a);
				indices.push(d); indices.push(c); indices.push(b);
			}
		}
		
		// Normals
		VertexData.ComputeNormals(positions, indices, normals);
		
		// Sides
        VertexData._ComputeSides(sideOrientation, positions, indices, normals, uvs);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = indices;
		vertexData.positions = positions;
		vertexData.normals = normals;
		vertexData.uvs = uvs;
		
		return vertexData;
	}

	// Tools
	/**
	 * @param {any} - positions (number[] or Float32Array)
	 * @param {any} - indices   (number[] or Uint16Array)
	 * @param {any} - normals   (number[] or Float32Array)
	 */
	public static function ComputeNormals(positions:Array<Float>, indices:Array<Int>, normals:Array<Float>) {
		// temp Vector3
		var p1p2 = Vector3.Zero();
		var p3p2 = Vector3.Zero();
		var faceNormal = Vector3.Zero();
		
		var vertexNormali1 = Vector3.Zero();
		
		for (index in 0...positions.length) {
			normals[index] = 0.0;
		}
		
		// indice triplet = 1 face
		var nbFaces = Std.int(indices.length / 3);
		for (index in 0...nbFaces) {
			var i1 = indices[index * 3];
			var i2 = indices[index * 3 + 1];
			var i3 = indices[index * 3 + 2];
			
			p1p2.x = positions[i1 * 3] - positions[i2 * 3];
			p1p2.y = positions[i1 * 3 + 1] - positions[i2 * 3 + 1];
			p1p2.z = positions[i1 * 3 + 2] - positions[i2 * 3 + 2];
			
			p3p2.x = positions[i3 * 3] - positions[i2 * 3];
			p3p2.y = positions[i3 * 3 + 1] - positions[i2 * 3 + 1];
			p3p2.z = positions[i3 * 3 + 2] - positions[i2 * 3 + 2];
			
			Vector3.CrossToRef(p1p2, p3p2, faceNormal);
			faceNormal.normalize();
			
			normals[i1 * 3] += faceNormal.x;
			normals[i1 * 3 + 1] += faceNormal.y;
			normals[i1 * 3 + 2] += faceNormal.z;
			normals[i2 * 3] += faceNormal.x;
			normals[i2 * 3 + 1] += faceNormal.y;
			normals[i2 * 3 + 2] += faceNormal.z;
			normals[i3 * 3] += faceNormal.x;
			normals[i3 * 3 + 1] += faceNormal.y;
			normals[i3 * 3 + 2] += faceNormal.z;
		}
		
		// last normalization
		var normLength = Std.int(normals.length / 3);
		for (index in 0...normLength) {
			Vector3.FromFloatsToRef(normals[index * 3], normals[index * 3 + 1], normals[index * 3 + 2], vertexNormali1);
			vertexNormali1.normalize();
			normals[index * 3] = vertexNormali1.x;
			normals[index * 3 + 1] = vertexNormali1.y;
			normals[index * 3 + 2] = vertexNormali1.z;
		}
	}
	
	public static function _ComputeSides(sideOrientation:Int = Mesh.DEFAULTSIDE, positions:Array<Float>, indices:Array<Int>, normals:Array<Float>, uvs:Array<Float>) {
		var li:Int = indices.length;
		var ln:Int = normals.length;
		
		switch (sideOrientation) {			
			case Mesh.FRONTSIDE:
				// nothing changed
				
			case Mesh.BACKSIDE:
				var tmp:Int = 0;
				// indices
				var i:Int = 0;
				while(i < li) {
					tmp = indices[i];
					indices[i] = indices[i + 2];
					indices[i + 2] = tmp;
					i += 3;
				}
				// normals
				for (n in 0...ln) {
					normals[n] = -normals[n];
				}
				
			case Mesh.DOUBLESIDE:
				// positions 
				var lp:Int = positions.length;
				var l:Int = Std.int(lp / 3);
				for (p in 0...lp) {
					positions[lp + p] = positions[p];
				}
				// indices
				var i:Int = 0;
				while (i < li) {
					indices[i + li] = indices[i + 2] + l;
					indices[i + 1 + li] = indices[i + 1] + l;
					indices[i + 2 + li] = indices[i] + l;
					i += 3;
				}
				// normals
				for (n in 0...ln) {
					normals[ln + n] = -normals[n];
				}
				
				// uvs
				var lu:Int = uvs.length;
				for (u in 0...lu) {
					uvs[u + lu] = uvs[u];
				}
		}
	}
	
}
