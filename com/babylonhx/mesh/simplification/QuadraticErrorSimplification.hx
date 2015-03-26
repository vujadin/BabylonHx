package com.babylonhx.mesh.simplification;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.AsyncLoop;
import com.babylonhx.tools.Tools;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.QuadraticErrorSimplification') class QuadraticErrorSimplification implements ISimplifier {

	private var triangles:Array<DecimationTriangle>;
	private var vertices:Array<DecimationVertex>;
	private var references:Array<Reference>;

	private var initialised:Bool = false;
	
	private var _reconstructedMesh:Mesh;

	public var syncIterations:Int = 5000;

	public var aggressiveness:Int;
	public var decimationIterations:Int;
	
	public var boundingBoxEpsilon:Float;
	
	private var _mesh:Mesh;
	

	public function new(mesh:Mesh) {
		this.aggressiveness = 7;
		this.decimationIterations = 100;
		this.boundingBoxEpsilon = Engine.Epsilon;
	}

	public function simplify(settings:ISimplificationSettings, successCallback:Mesh->Void, ?errorCallback:Void->Void) {
		this.initDecimatedMesh();
		//iterating through the submeshes array, one after the other.
		AsyncLoop.Run(this._mesh.subMeshes.length, function(loop:AsyncLoop) {
			this.initWithMesh(this._mesh, loop.index, function() {
				this.runDecimation(settings, loop.index, function() {
					loop.executeNext();
				});
			});
		},function() {
			Tools.delay(function() {
				successCallback(this._reconstructedMesh);
			}, 0);
		});
	}
	
	private function isTriangleOnBoundingBox(triangle:DecimationTriangle):Bool {
		var gCount = 0;
		for(vId in triangle.vertices) {
			var count = 0;
			var vPos = this.vertices[vId].position;
			var bbox = this._mesh.getBoundingInfo().boundingBox;
			
			if (bbox.maximum.x - vPos.x < this.boundingBoxEpsilon || vPos.x - bbox.minimum.x > this.boundingBoxEpsilon) {
				++count;
			}
			
			if (bbox.maximum.y == vPos.y || vPos.y == bbox.minimum.y) {
				++count;
			}
			
			if (bbox.maximum.z == vPos.z || vPos.z == bbox.minimum.z) {
				++count;
			}
			
			if (count > 1) {
				++gCount;
			}
		}
		
		if (gCount > 1) {
			trace(triangle);
			trace(gCount);
		}
		
		return gCount > 1;		
	}

	private function runDecimation(settings:ISimplificationSettings, submeshIndex:Int, successCallback:Void->Void) {
		var targetCount = Std.int(this.triangles.length * settings.quality);
		var deletedTriangles:Int = 0;
		
		var triangleCount = this.triangles.length;
		
		var iterationFunction = function(iteration:Int, cback:Void->Void) {
			Tools.delay(function() {
				if (iteration % 5 == 0) {
					this.updateMesh(iteration == 0);
				}
				
				for (i in 0...this.triangles.length) {
					this.triangles[i].isDirty = false;
				}
				
				var threshold = 0.000000001 * Math.pow((iteration + 3), this.aggressiveness);
				
				var trianglesIterator = function(i:Int) {
					var tIdx = Std.int(((this.triangles.length / 2) + i) % this.triangles.length);
					var t = this.triangles[tIdx];
					
					if (t == null) {
						return;
					}
					
					if (t.error[3] > threshold || t.deleted || t.isDirty) { 
						return;				
					}
					
					for (j in 0...3) {
						if (t.error[j] < threshold) {
							var deleted0:Array<Bool> = [];
							var deleted1:Array<Bool> = [];
							
							var i0 = t.vertices[j];
							var i1 = t.vertices[(j + 1) % 3];
							var v0 = this.vertices[i0];
							var v1 = this.vertices[i1];
							
							if (v0.isBorder != v1.isBorder) {
								continue;
							}
							
							var p = Vector3.Zero();
							var n = Vector3.Zero();
							var uv = Vector2.Zero();
							var color = new Color4(0, 0, 0, 1);
							
							this.calculateError(v0, v1, p, n, uv, color);
							
							var delTr:Array<DecimationTriangle> = [];
							
							if (this.isFlipped(v0, i1, p, deleted0, t.borderFactor, delTr)) {
								continue;
							}
							if (this.isFlipped(v1, i0, p, deleted1, t.borderFactor, delTr)) {
								continue;
							}
							
							if (deleted0.indexOf(true) < 0 || deleted1.indexOf(true) < 0) {
                                continue;
							}
								
                            var uniqueArray:Array<DecimationTriangle> = [];
							for(deletedT in delTr) {
                                if (uniqueArray.indexOf(deletedT) == -1) {
                                    deletedT.deletePending = true;
                                    uniqueArray.push(deletedT);
                                }
                            }
							
                            if (uniqueArray.length % 2 != 0) {
								continue;
							}
							
							v0.normal = n;
							if (v0.uv != null) {
								v0.uv = uv;
							}
							else if (v0.color != null) {
								v0.color = color;
							}
							v0.q = v1.q.add(v0.q);
							
							v0.position = p;
							
							var tStart = this.references.length;
							
							deletedTriangles = this.updateTriangles(v0.id, v0, deleted0, deletedTriangles);
							deletedTriangles = this.updateTriangles(v0.id, v1, deleted1, deletedTriangles);
							
							var tCount:Int = this.references.length - tStart;
							
							if (tCount <= v0.triangleCount) {
								if (tCount > 0) {
									for (c in 0...tCount) {
										this.references[v0.triangleStart + c] = this.references[tStart + c];
									}
								}
							} 
							else {
								v0.triangleStart = tStart;
							}
							
							v0.triangleCount = tCount;
							break;
						}
					}
				};
				
				AsyncLoop.SyncAsyncForLoop(this.triangles.length, this.syncIterations, trianglesIterator, cback, function():Bool { return (triangleCount - deletedTriangles <= targetCount); } );
			}, 0);
		};
		
		AsyncLoop.Run(this.decimationIterations, function(loop:AsyncLoop) {
			if (triangleCount - deletedTriangles <= targetCount) {
				loop.breakLoop();
			}
			else {
				iterationFunction(loop.index, loop.executeNext);
			}
		}, function() {
			Tools.delay(function() {
				//reconstruct this part of the mesh
				this.reconstructMesh(submeshIndex);
				successCallback();
			}, 0);
		});
	}

	private function initWithMesh(mesh:Mesh, submeshIndex:Int, cback:Dynamic) {
		if (mesh == null) {
			return;
		}
		
		this.vertices = [];
		this.triangles = [];
		
		this._mesh = mesh;
		//It is assumed that a mesh has positions, normals and either uvs or colors.
		var positionData = this._mesh.getVerticesData(VertexBuffer.PositionKind);
		var normalData = this._mesh.getVerticesData(VertexBuffer.NormalKind);
		var uvs = this._mesh.getVerticesData(VertexBuffer.UVKind);
		var colorsData = this._mesh.getVerticesData(VertexBuffer.ColorKind);
		var indices = mesh.getIndices();
		var submesh = mesh.subMeshes[submeshIndex];
		
		var vertexInit = function(i:Int) {
			var offset = i + submesh.verticesStart;
			var vertex = new DecimationVertex(Vector3.FromArray(positionData, i * 3), Vector3.FromArray(normalData, i * 3), null, i);
			if (this._mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
				vertex.uv = Vector2.FromArray(uvs, i * 2);				
			} 
			else if (this._mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				vertex.color = Color4.FromArray(colorsData, i * 4);
			}
			this.vertices.push(vertex);
		};
		
		//var totalVertices = mesh.getTotalVertices();
		var totalVertices = submesh.verticesCount;
		AsyncLoop.SyncAsyncForLoop(totalVertices, this.syncIterations, vertexInit, function() {
			
			var indicesInit = function(i:Int) {
				var pos = i * 3;
				var i0 = indices[pos + 0];
				var i1 = indices[pos + 1];
				var i2 = indices[pos + 2];
				var triangle = new DecimationTriangle([this.vertices[i0].id, this.vertices[i1].id, this.vertices[i2].id]);
				this.triangles.push(triangle);
			};
			
			AsyncLoop.SyncAsyncForLoop(Std.int(indices.length / 3), this.syncIterations, indicesInit, function() {
				this.init(cback);
			});
		});
	}

	private function init(cback:Dynamic) {
		var triangleInit1 = function(i:Int) {
			var t = this.triangles[i];
			t.normal = Vector3.Cross(this.vertices[t.vertices[1]].position.subtract(this.vertices[t.vertices[0]].position), this.vertices[t.vertices[2]].position.subtract(this.vertices[t.vertices[0]].position)).normalize();
			
			for (j in 0...3) {
				this.vertices[t.vertices[j]].q.addArrayInPlace(QuadraticMatrix.DataFromNumbers(t.normal.x, t.normal.y, t.normal.z, -(Vector3.Dot(t.normal, this.vertices[t.vertices[0]].position))));
			}
		};
		
		AsyncLoop.SyncAsyncForLoop(this.triangles.length, this.syncIterations, triangleInit1, function() {			
			var triangleInit2 = function(i:Int) {
				var t = this.triangles[i];
				for (j in 0...3) {
					t.error[j] = this.calculateError(this.vertices[t.vertices[j]], this.vertices[t.vertices[(j + 1) % 3]]);
				}
				t.error[3] = Math.min(Math.min(t.error[0], t.error[1]), t.error[2]);
			};
			
			AsyncLoop.SyncAsyncForLoop(this.triangles.length, this.syncIterations, triangleInit2, function() {
				this.initialised = true;
				cback();
			});
		});
	}

	private function reconstructMesh(submeshIndex:Int) {		
		var newTriangles:Array<DecimationTriangle> = [];
		for (i in 0...this.vertices.length) {
			this.vertices[i].triangleCount = 0;
		}
		
		var t:DecimationTriangle;
		for (i in 0...this.triangles.length) {
			if (!this.triangles[i].deleted) {
				t = this.triangles[i];
				for (j in 0...3) {
					this.vertices[t.vertices[j]].triangleCount = 1;
				}
				newTriangles.push(t);
			}
		}
		
		var newVerticesOrder:Array<Int> = [];
		
		//compact vertices, get the IDs of the vertices used.
		var dst:Int = 0;
		for (i in 0...this.vertices.length) {
			if (this.vertices[i].triangleCount > 0) {
				this.vertices[i].triangleStart = dst;
				this.vertices[dst].position = this.vertices[i].position;
				this.vertices[dst].normal = this.vertices[i].normal;
				this.vertices[dst].uv = this.vertices[i].uv;
				this.vertices[dst].color = this.vertices[i].color;
				newVerticesOrder.push(dst);
				dst++;
			}
		}

		for (i in 0...newTriangles.length) {
			t = newTriangles[i];
			for (j in 0...3) {
				t.vertices[j] = this.vertices[t.vertices[j]].triangleStart;
			}
		}
		this.vertices = this.vertices.slice(0, dst);

		var newPositionData:Array<Float> = [];
		var newNormalData:Array<Float> = [];
		var newUVsData:Array<Float> = [];
		var newColorsData:Array<Float> = [];
		
		for (i in 0...newVerticesOrder.length) {
			newPositionData.push(this.vertices[i].position.x);
			newPositionData.push(this.vertices[i].position.y);
			newPositionData.push(this.vertices[i].position.z);
			
			newNormalData.push(this.vertices[i].normal.x);
			newNormalData.push(this.vertices[i].normal.y);
			newNormalData.push(this.vertices[i].normal.z);
			
			if (this.vertices[i].uv != null) {
				newUVsData.push(this.vertices[i].uv.x);
				newUVsData.push(this.vertices[i].uv.y);
			} 
			else if (this.vertices[i].color != null) {
				newColorsData.push(this.vertices[i].color.r);
				newColorsData.push(this.vertices[i].color.g);
				newColorsData.push(this.vertices[i].color.b);
				newColorsData.push(this.vertices[i].color.a);
			}
		}
		
		var startingIndex = this._reconstructedMesh.getTotalIndices();
		var startingVertex = this._reconstructedMesh.getTotalVertices();
		
		var submeshesArray:Array<SubMesh> = this._reconstructedMesh.subMeshes;
		this._reconstructedMesh.subMeshes = [];
		
		var newIndicesArray:Array<Int> = this._reconstructedMesh.getIndices();
		for (i in 0...newTriangles.length) {
			newIndicesArray.push(newTriangles[i].vertices[0] + startingVertex);
			newIndicesArray.push(newTriangles[i].vertices[1] + startingVertex);
			newIndicesArray.push(newTriangles[i].vertices[2] + startingVertex);
		}
		
		//overwriting the old vertex buffers and indices.
		this._reconstructedMesh.setIndices(newIndicesArray);
		this._reconstructedMesh.setVerticesData(VertexBuffer.PositionKind, newPositionData);
		this._reconstructedMesh.setVerticesData(VertexBuffer.NormalKind, newNormalData);
		if (newUVsData.length > 0) {
			this._reconstructedMesh.setVerticesData(VertexBuffer.UVKind, newUVsData);
		}
		if (newColorsData.length > 0) {
			this._reconstructedMesh.setVerticesData(VertexBuffer.ColorKind, newColorsData);
		}
		
		//create submesh
		var originalSubmesh = this._mesh.subMeshes[submeshIndex];
		if (submeshIndex > 0) {
			this._reconstructedMesh.subMeshes = [];
			for(submesh in submeshesArray) {
				new SubMesh(submesh.materialIndex, submesh.verticesStart, submesh.verticesCount,/* 0, newPositionData.length/3, */submesh.indexStart, submesh.indexCount, submesh.getMesh());
			}
			var newSubmesh = new SubMesh(originalSubmesh.materialIndex, startingVertex, newVerticesOrder.length,/* 0, newPositionData.length / 3, */startingIndex, newTriangles.length * 3, this._reconstructedMesh);
		}
	}
	
	private function initDecimatedMesh() {
		this._reconstructedMesh = new Mesh(this._mesh.name + "Decimated", this._mesh.getScene());
		this._reconstructedMesh.material = this._mesh.material;
		this._reconstructedMesh.parent = this._mesh.parent;
		this._reconstructedMesh.isVisible = false;
	}

	private function isFlipped(vertex1:DecimationVertex, index2:Int, point:Vector3, deletedArray:Array<Bool>, borderFactor:Float, delTr:Array<DecimationTriangle>):Bool {
		
		for (i in 0...vertex1.triangleCount) {
			var t = this.triangles[this.references[vertex1.triangleStart + i].triangleId];
			if (t.deleted) {
				continue;
			}
			
			var s = this.references[vertex1.triangleStart + i].vertexId;
			
			var id1 = t.vertices[(s + 1) % 3];
			var id2 = t.vertices[(s + 2) % 3];
			
			if ((id1 == index2 || id2 == index2) && borderFactor < 2) {
				deletedArray[i] = true;
				delTr.push(t);
				continue;
			}
			
			var d1 = this.vertices[id1].position.subtract(point);
			d1 = d1.normalize();
			
			var d2 = this.vertices[id2].position.subtract(point);
			d2 = d2.normalize();
			
			if (Math.abs(Vector3.Dot(d1, d2)) > 0.999) {
				return true;
			}
			
			var normal = Vector3.Cross(d1, d2).normalize();
			deletedArray[i] = false;
			if (Vector3.Dot(normal, t.normal) < 0.2) {
				return true;
			}
		}
		
		return false;
	}

	private function updateTriangles(vertexId:Int, vertex:DecimationVertex, deletedArray:Array<Bool>, deletedTriangles:Int):Int {
		var newDeleted = deletedTriangles;
		for (i in 0...vertex.triangleCount) {
			var ref = this.references[vertex.triangleStart + i];
			var t = this.triangles[ref.triangleId];
			
			if (t.deleted) {
				continue;
			}
			
			if (deletedArray[i] && t.deletePending) {
				t.deleted = true;
				newDeleted++;
				continue;
			}
			
			t.vertices[ref.vertexId] = vertexId;
			t.isDirty = true;
			t.error[0] = this.calculateError(this.vertices[t.vertices[0]], this.vertices[t.vertices[1]]) + (t.borderFactor / 2);
			t.error[1] = this.calculateError(this.vertices[t.vertices[1]], this.vertices[t.vertices[2]]) + (t.borderFactor / 2);
			t.error[2] = this.calculateError(this.vertices[t.vertices[2]], this.vertices[t.vertices[0]]) + (t.borderFactor / 2);
			t.error[3] = Math.min(Math.min(t.error[0], t.error[1]), t.error[2]);
			this.references.push(ref);
		}
		return newDeleted;
	}

	private function identifyBorder() {
		
		for (i in 0...this.vertices.length) {
			var vCount:Array<Int> = [];
			var vId:Array<Int> = [];
			var v:DecimationVertex = this.vertices[i];
			
			for (j in 0...v.triangleCount) {
				var triangle = this.triangles[this.references[v.triangleStart + j].triangleId];
				for (ii in 0...3) {
					var ofs = 0;
					var id = triangle.vertices[ii];
					while (ofs < vCount.length) {
						if (vId[ofs] == id) {
							break;
						}
						++ofs;
					}
					if (ofs == vCount.length) {
						vCount.push(1);
						vId.push(id);
					} else {
						vCount[ofs]++;
					}
				}
			}
			
			for (j in 0...vCount.length) {
				if (vCount[j] == 1) {
					this.vertices[vId[j]].isBorder = true;
				} else {
					this.vertices[vId[j]].isBorder = false;
				}
			}
		}
	}

	private function updateMesh(identifyBorders:Bool = false) {
		if (!identifyBorders) {
			var newTrianglesVector:Array<DecimationTriangle> = [];
			for (i in 0...this.triangles.length) {
				if (!this.triangles[i].deleted) {
					newTrianglesVector.push(this.triangles[i]);
				}
			}
			this.triangles = newTrianglesVector;
		}
		
		for (i in 0...this.vertices.length) {
			this.vertices[i].triangleCount = 0;
			this.vertices[i].triangleStart = 0;
		}
		
		var t:DecimationTriangle = null;
		var v:DecimationVertex = null;
		
		for (i in 0...this.triangles.length) {
			t = this.triangles[i];
			for (j in 0...3) {
				v = this.vertices[t.vertices[j]];
				v.triangleCount++;
			}
		}
		
		var tStart = 0;
		
		for (i in 0...this.vertices.length) {
			this.vertices[i].triangleStart = tStart;
			tStart += this.vertices[i].triangleCount;
			this.vertices[i].triangleCount = 0;
		}
		
		var newReferences:Array<Reference> = [];
		for (i in 0...this.triangles.length) {
			t = this.triangles[i];
			for (j in 0...3) {
				v = this.vertices[t.vertices[j]];
				newReferences[v.triangleStart + v.triangleCount] = new Reference(j, i);
				v.triangleCount++;
			}
		}
		this.references = newReferences;
		
		if (identifyBorders) {
			this.identifyBorder();
		}
	}
	
	private function vertexError(q:QuadraticMatrix, point:Vector3):Float {
		var x = point.x;
		var y = point.y;
		var z = point.z;
		return q.data[0] * x * x + 2 * q.data[1] * x * y + 2 * q.data[2] * x * z + 2 * q.data[3] * x + q.data[4] * y * y
			+ 2 * q.data[5] * y * z + 2 * q.data[6] * y + q.data[7] * z * z + 2 * q.data[8] * z + q.data[9];
	}

	private function calculateError(vertex1:DecimationVertex, vertex2:DecimationVertex, ?pointResult:Vector3, ?normalResult:Vector3, ?uvResult: Vector2, ?colorResult:Color4):Float {
		
		var q:QuadraticMatrix = vertex1.q.add(vertex2.q);
		var border:Bool = vertex1.isBorder && vertex2.isBorder;
		var error:Float = 0;
		var qDet = q.det(0, 1, 2, 1, 4, 5, 2, 5, 7);

		if (qDet != 0 && !border) {
			if (pointResult == null) {
				pointResult = Vector3.Zero();
			}
			pointResult.x = -1 / qDet * (q.det(1, 2, 3, 4, 5, 6, 5, 7, 8));
			pointResult.y = 1 / qDet * (q.det(0, 2, 3, 1, 5, 6, 2, 7, 8));
			pointResult.z = -1 / qDet * (q.det(0, 1, 3, 1, 4, 6, 2, 5, 8));
			error = this.vertexError(q, pointResult);
			//TODO this should be correctly calculated
			if (normalResult != null) {
				normalResult.copyFrom(vertex1.normal);
				if (vertex1.uv != null)
					uvResult.copyFrom(vertex1.uv);
				else if (vertex1.color != null)
					colorResult.copyFrom(vertex1.color);
			}
		} else {
			var p3 = (vertex1.position.add(vertex2.position)).divide(new Vector3(2, 2, 2));
			//var norm3 = (vertex1.normal.add(vertex2.normal)).divide(new Vector3(2, 2, 2)).normalize();
			var error1 = this.vertexError(q, vertex1.position);
			var error2 = this.vertexError(q, vertex2.position);
			var error3 = this.vertexError(q, p3);
			error = Math.min(Math.min(error1, error2), error3);
			if (error == error1) {
				if (pointResult != null) {
					pointResult.copyFrom(vertex1.position);
					normalResult.copyFrom(vertex1.normal);
					if (vertex1.uv != null)
						uvResult.copyFrom(vertex1.uv);
					else if (vertex1.color != null)
						colorResult.copyFrom(vertex1.color);
				}
			} else if (error == error2) {
				if (pointResult != null) {
					pointResult.copyFrom(vertex2.position);
					normalResult.copyFrom(vertex2.normal);
					if (vertex2.uv != null)
						uvResult.copyFrom(vertex2.uv);
					else if (vertex2.color != null)
						colorResult.copyFrom(vertex2.color);
				}
			} else {
				if (pointResult != null) {
					pointResult.copyFrom(p3);
					normalResult.copyFrom(vertex1.normal);
					if (vertex1.uv != null)
						uvResult.copyFrom(vertex1.uv);
					else if (vertex1.color != null)
						colorResult.copyFrom(vertex1.color);
				}
			}
		}
		
		return error;
	}
	
}
