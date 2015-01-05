package com.babylonhx.mesh.csg;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.SubMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

class CSG {
	
	private static var currentCSGMeshId:Int = 0;
	
	private var polygons:Array<Polygon> = [];
	public var matrix:Matrix;
	public var position:Vector3;
	public var rotation:Vector3;
	public var scaling:Vector3;
	

	// Convert Mesh to CSG
	public static function FromMesh(mesh:Mesh) {
		var vertex:Vertex;
		var normal:Vector3;
		var uv:Vector2;
		var position:Vector3;
		var polygon:Polygon;
		var	polygons:Array<Polygon> = [];
		var vertices:Array<Vertex>;

		if (Std.is(mesh, Mesh)) {
			mesh.computeWorldMatrix(true);
			var matrix = mesh.getWorldMatrix();
			var meshPosition = mesh.position.clone();
			var meshRotation = mesh.rotation.clone();
			var meshScaling = mesh.scaling.clone();
		} else {
			throw 'CSG:Wrong Mesh type, must be Mesh';
		}

		var indices = mesh.getIndices();
		var positions = mesh.getVerticesData(VertexBuffer.PositionKind);
		var	normals = mesh.getVerticesData(VertexBuffer.NormalKind);
		var uvs = mesh.getVerticesData(VertexBuffer.UVKind);

		var subMeshes = mesh.subMeshes;

		for (sm in 0...subMeshes.length) {
			var i = subMeshes[sm].indexStart;
			var il = subMeshes[sm].indexCount + subMeshes[sm].indexStart;
			while(i < il) {
				vertices = [];
				for (j in 0...3) {
					normal = new Vector3(normals[indices[i + j] * 3], normals[indices[i + j] * 3 + 1], normals[indices[i + j] * 3 + 2]);
					uv = new Vector2(uvs[indices[i + j] * 2], uvs[indices[i + j] * 2 + 1]);
					position = new Vector3(positions[indices[i + j] * 3], positions[indices[i + j] * 3 + 1], positions[indices[i + j] * 3 + 2]);
					Vector3.TransformCoordinatesToRef(position, matrix, position);
					Vector3.TransformNormalToRef(normal, matrix, normal);

					vertex = new Vertex(position, normal, uv);
					vertices.push(vertex);
				}

				polygon = new Polygon(vertices, { subMeshId:sm, meshId:currentCSGMeshId, materialIndex:subMeshes[sm].materialIndex });

				// To handle the case of degenerated triangle
				// polygon.plane == null <=> the polygon does not represent 1 single plane <=> the triangle is degenerated
				if (polygon.plane) {
					polygons.push(polygon);
				}
					
				i += 3;
			}
		}

		var csg = CSG.FromPolygons(polygons);
		csg.matrix = matrix;
		csg.position = meshPosition;
		csg.rotation = meshRotation;
		csg.scaling = meshScaling;
		currentCSGMeshId++;

		return csg;
	}


	// Construct a CSG solid from a list of `CSG.Polygon` instances.
	private static function FromPolygons(polygons:Array<Polygon>):CSG {
		var csg = new CSG();
		csg.polygons = polygons;
		return csg;
	}

	public function clone():CSG {
		var csg = new CSG();
		csg.polygons = this.polygons.map(function(p) { p.clone(); });
		csg.copyTransformAttributes(this);
		return csg;
	}

	private function toPolygons():Array<Polygon> {
		return this.polygons;
	}

	public function union(csg:CSG):CSG {
		var a = new Node(this.clone().polygons);
		var b = new Node(csg.clone().polygons);
		a.clipTo(b);
		b.clipTo(a);
		b.invert();
		b.clipTo(a);
		b.invert();
		a.build(b.allPolygons());
		return CSG.FromPolygons(a.allPolygons()).copyTransformAttributes(this);
	}

	public function unionInPlace(csg:CSG) {
		var a = new Node(this.polygons);
		var b = new Node(csg.polygons);

		a.clipTo(b);
		b.clipTo(a);
		b.invert();
		b.clipTo(a);
		b.invert();
		a.build(b.allPolygons());

		this.polygons = a.allPolygons();
	}

	public function subtract(csg:CSG):CSG {
		var a = new Node(this.clone().polygons);
		var b = new Node(csg.clone().polygons);
		a.invert();
		a.clipTo(b);
		b.clipTo(a);
		b.invert();
		b.clipTo(a);
		b.invert();
		a.build(b.allPolygons());
		a.invert();
		return CSG.FromPolygons(a.allPolygons()).copyTransformAttributes(this);
	}

	public function subtractInPlace(csg:CSG) {
		var a = new Node(this.polygons);
		var b = new Node(csg.polygons);

		a.invert();
		a.clipTo(b);
		b.clipTo(a);
		b.invert();
		b.clipTo(a);
		b.invert();
		a.build(b.allPolygons());
		a.invert();

		this.polygons = a.allPolygons();
	}

	public function intersect(csg:CSG):CSG {
		var a = new Node(this.clone().polygons);
		var b = new Node(csg.clone().polygons);
		a.invert();
		b.clipTo(a);
		b.invert();
		a.clipTo(b);
		b.clipTo(a);
		a.build(b.allPolygons());
		a.invert();
		return CSG.FromPolygons(a.allPolygons()).copyTransformAttributes(this);
	}

	public function intersectInPlace(csg:CSG) {
		var a = new Node(this.polygons);
		var b = new Node(csg.polygons);

		a.invert();
		b.clipTo(a);
		b.invert();
		a.clipTo(b);
		b.clipTo(a);
		a.build(b.allPolygons());
		a.invert();

		this.polygons = a.allPolygons();
	}

	// Return a new CSG solid with solid and empty space switched. This solid is
	// not modified.
	public function inverse():CSG {
		var csg = this.clone();
		csg.inverseInPlace();
		return csg;
	}

	public function inverseInPlace() {
		this.polygons.map(function(p) { p.flip(); });
	}

	// This is used to keep meshes transformations so they can be restored
	// when we build back a Babylon Mesh
	// NB :All CSG operations are performed in world coordinates
	public function copyTransformAttributes(csg:CSG):CSG {
		this.matrix = csg.matrix;
		this.position = csg.position;
		this.rotation = csg.rotation;
		this.scaling = csg.scaling;

		return this;
	}

	// Build Raw mesh from CSG
	// Coordinates here are in world space
	public function buildMeshGeometry(name:String, scene:Scene, keepSubMeshes:Bool):Mesh {
		var matrix = this.matrix.clone();
		matrix.invert();

		var mesh = new Mesh(name, scene),
		var	vertices:Array<Float> = [];
		var	indices:Array<Float> = [];
		var	normals:Array<Float> = [];
		var	uvs:Array<Float> = [];
		var	vertex = Vector3.Zero();
		var	normal = Vector3.Zero();
		var	uv = Vector2.Zero();
		var	polygons = this.polygons;
		var	polygonIndices:Array<Int> = [0, 0, 0];
		var	polygon:Polygon;
		var	vertice_dict:Map<String, Int> = new Map<String, Int>();
		var	vertex_idx:Int;
		var	currentIndex:Int = 0;
		var	subMesh_dict:Map<String, Dynamic> = new Map<String, Dynamic>();
		var	subMesh_obj:Dynamic;


		if (keepSubMeshes) {
			// Sort Polygons, since subMeshes are indices range
			polygons.sort(function(a:Polygon, b:Polygon) {
				if (a.shared.meshId == b.shared.meshId) {
					return a.shared.subMeshId - b.shared.subMeshId;
				} else {
					return a.shared.meshId - b.shared.meshId;
				}
			});
		}

		for (i in 0...polygons.length) {
			polygon = polygons[i];

			// Building SubMeshes
			if (subMesh_dict[polygon.shared.meshId] == null) {
				subMesh_dict[polygon.shared.meshId] = {};
			}
			if (subMesh_dict[polygon.shared.meshId][polygon.shared.subMeshId] == null) {
				subMesh_dict[polygon.shared.meshId][polygon.shared.subMeshId] = {
					indexStart: Math.POSITIVE_INFINITY,
					indexEnd: Math.NEGATIVE_INFINITY,
					materialIndex: polygon.shared.materialIndex
				};
			}
			subMesh_obj = subMesh_dict[polygon.shared.meshId][polygon.shared.subMeshId];

			for (j in 2...polygon.vertices.length) {
				polygonIndices[0] = 0;
				polygonIndices[1] = j - 1;
				polygonIndices[2] = j;

				for (k in 0...3) {
					vertex.copyFrom(polygon.vertices[polygonIndices[k]].pos);
					normal.copyFrom(polygon.vertices[polygonIndices[k]].normal);
					uv.copyFrom(polygon.vertices[polygonIndices[k]].uv);
					Vector3.TransformCoordinatesToRef(vertex, matrix, vertex);
					Vector3.TransformNormalToRef(normal, matrix, normal);

					vertex_idx = vertice_dict[vertex.x + ',' + vertex.y + ',' + vertex.z];

					// Check if 2 points can be merged
					if (!(vertex_idx != null &&
						normals[vertex_idx * 3] == normal.x &&
						normals[vertex_idx * 3 + 1] == normal.y &&
						normals[vertex_idx * 3 + 2] == normal.z &&
						uvs[vertex_idx * 2] == uv.x &&
						uvs[vertex_idx * 2 + 1] == uv.y)) {
							
							vertices.push(vertex.x, vertex.y, vertex.z);
							uvs.push(uv.x, uv.y);
							normals.push(normal.x, normal.y, normal.z);
							vertex_idx = (vertices.length / 3) - 1;
							vertice_dict.set(vertex.x + ',' + vertex.y + ',' + vertex.z, vertex_idx);
							
						}
					}

					indices.push(vertex_idx);

					subMesh_obj.indexStart = Math.min(currentIndex, subMesh_obj.indexStart);
					subMesh_obj.indexEnd = Math.max(currentIndex, subMesh_obj.indexEnd);
					currentIndex++;
				}

			}

		}

		mesh.setVerticesData(VertexBuffer.PositionKind, vertices);
		mesh.setVerticesData(VertexBuffer.NormalKind, normals);
		mesh.setVerticesData(VertexBuffer.UVKind, uvs);
		mesh.setIndices(indices);

		if (keepSubMeshes) {
			// We offset the materialIndex by the previous number of materials in the CSG mixed meshes
			var materialIndexOffset:Int = 0;
			var	materialMaxIndex:Int;

			mesh.subMeshes.length = 0;

			for (m in subMesh_dict) {
				materialMaxIndex = -1;
				for (sm in subMesh_dict[m]) {
					subMesh_obj = subMesh_dict[m][sm];
					SubMesh.CreateFromIndices(subMesh_obj.materialIndex + materialIndexOffset, subMesh_obj.indexStart, subMesh_obj.indexEnd - subMesh_obj.indexStart + 1, mesh);
					materialMaxIndex = Math.max(subMesh_obj.materialIndex, materialMaxIndex);
				}
				materialIndexOffset += ++materialMaxIndex;
			}
		}

		return mesh;
	}

	// Build Mesh from CSG taking material and transforms into account
	public function toMesh(name:String, material:Material, scene:Scene, keepSubMeshes:Bool):Mesh {
		var mesh = this.buildMeshGeometry(name, scene, keepSubMeshes);

		mesh.material = material;

		mesh.position.copyFrom(this.position);
		mesh.rotation.copyFrom(this.rotation);
		mesh.scaling.copyFrom(this.scaling);
		mesh.computeWorldMatrix(true);

		return mesh;
	}
	
}
