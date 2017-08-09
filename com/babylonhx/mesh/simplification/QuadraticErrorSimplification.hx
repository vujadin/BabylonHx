package com.babylonhx.mesh.simplification;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.AsyncLoop;
import com.babylonhx.tools.Tools;
import haxe.Timer;
import lime.utils.Float32Array;
import lime.utils.Int32Array;

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
		this.boundingBoxEpsilon = com.babylonhx.math.Tools.Epsilon;
	}

	public function simplify(settings:ISimplificationSettings, successCallback:Mesh->Void, ?errorCallback:Void->Void) {
		this.initDecimatedMesh();
		//iterating through the submeshes array, one after the other.
		AsyncLoop.Run(this._mesh.subMeshes.length, function(loop:AsyncLoop) {
			this.initWithMesh(loop.index, function() {
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
		for(vertex in triangle.vertices) {
			var count = 0;
			var vPos = vertex.position;
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
							
							var v0 = t.vertices[j];
							var v1 = t.vertices[(j + 1) % 3];
							
							if (v0.isBorder != v1.isBorder) {
								continue;
							}
							
							var p = Vector3.Zero();
							var n = Vector3.Zero();
							var uv = Vector2.Zero();
							var color = new Color4(0, 0, 0, 1);
							
							this.calculateError(v0, v1, p, n, uv, color);
							
							var delTr:Array<DecimationTriangle> = [];
							
							if (this.isFlipped(v0, v1, p, deleted0, t.borderFactor, delTr)) {
								continue;
							}
							if (this.isFlipped(v1, v0, p, deleted1, t.borderFactor, delTr)) {
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
							
							v0.q = v1.q.add(v0.q);
							
							v0.updatePosition(p);
							
							var tStart = this.references.length;
							
							deletedTriangles = this.updateTriangles(v0, v0, deleted0, deletedTriangles);
							deletedTriangles = this.updateTriangles(v0, v1, deleted1, deletedTriangles);
							
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

	private function initWithMesh(submeshIndex:Int, callbackFn:Dynamic, optimizeMesh:Bool = false) {
		
		this.vertices = [];
		this.triangles = [];
		
		var positionData = this._mesh.getVerticesData(VertexBuffer.PositionKind);
		
		var indices = this._mesh.getIndices();
		var submesh = this._mesh.subMeshes[submeshIndex];
		
		var findInVertices = function(positionToSearch:Vector3):DecimationVertex {
			if (optimizeMesh) {
				for (ii in 0...this.vertices.length) {
					if (this.vertices[ii].position.equals(positionToSearch)) {
						return this.vertices[ii];
					}
				}
			}
			return null;
		};
		
		var vertexReferences:Array<Int> = [];
		
		var vertexInit = function(i:Int) {
			var offset = i + submesh.verticesStart;
			var position = Vector3.FromFloat32Array(positionData, offset * 3);
			
			var vertex = findInVertices(position);
			if (vertex == null) {
				vertex = new DecimationVertex(position, this.vertices.length);
			}
			vertex.originalOffsets.push(offset);
			if (vertex.id == this.vertices.length) {
				this.vertices.push(vertex);
			}
			vertexReferences.push(vertex.id);
		};
		
		var totalVertices = submesh.verticesCount;
		AsyncLoop.SyncAsyncForLoop(totalVertices, Std.int(this.syncIterations / 4), vertexInit, function() {
			
			var indicesInit = function(i:Int) {
				var offset = (submesh.indexStart / 3) + i;
				var pos = Std.int(offset * 3);
				var i0 = indices[pos + 0];
				var i1 = indices[pos + 1];
				var i2 = indices[pos + 2];
				var v0:DecimationVertex = this.vertices[vertexReferences[i0 - submesh.verticesStart]];
				var v1:DecimationVertex = this.vertices[vertexReferences[i1 - submesh.verticesStart]];
				var v2:DecimationVertex = this.vertices[vertexReferences[i2 - submesh.verticesStart]];
				var triangle = new DecimationTriangle([v0, v1, v2]);
				triangle.originalOffset = pos;
				this.triangles.push(triangle);
			};
			
			AsyncLoop.SyncAsyncForLoop(Std.int(indices.length / 3), this.syncIterations, indicesInit, function() {
				this.init(callbackFn);
			});
		});
	}

	private function init(callbackFn:Dynamic) {
		var triangleInit1 = function(i:Int) {
			var t = this.triangles[i];
			t.normal = Vector3.Cross(t.vertices[1].position.subtract(t.vertices[0].position), t.vertices[2].position.subtract(t.vertices[0].position)).normalize();
			for (j in 0...3) {
				t.vertices[j].q.addArrayInPlace(QuadraticMatrix.DataFromNumbers(t.normal.x, t.normal.y, t.normal.z, -(Vector3.Dot(t.normal, t.vertices[0].position))));
			}
		};
		
		AsyncLoop.SyncAsyncForLoop(this.triangles.length, this.syncIterations, triangleInit1, function() {
			var triangleInit2 = function(i:Int) {
				var t = this.triangles[i];
				for (j in 0...3) {
					t.error[j] = this.calculateError(t.vertices[j], t.vertices[(j + 1) % 3]);
				}
				t.error[3] = Math.min(t.error[0], t.error[1]);
				t.error[3] = Math.min(t.error[3], t.error[2]);
			};
			AsyncLoop.SyncAsyncForLoop(this.triangles.length, this.syncIterations, triangleInit2, function() {
				this.initialised = true;
				callbackFn();
			});
		});
	}

	private function reconstructMesh(submeshIndex:Int) {		
		var newTriangles:Array<DecimationTriangle> = [];
		for (i in 0...this.vertices.length) {
			this.vertices[i].triangleCount = 0;
		}
		var t:DecimationTriangle = null;
		for (i in 0...this.triangles.length) {
			if (!this.triangles[i].deleted) {
				t = this.triangles[i];
				for (j in 0...3) {
					t.vertices[j].triangleCount = 1;
				}
				newTriangles.push(t);
			}
		}
		
		var newPositionData:Array<Float> = [];
		var tmpPD = this._reconstructedMesh.getVerticesData(VertexBuffer.PositionKind);
		if (tmpPD != null) {
			for (i in 0...tmpPD.length) {
				newPositionData[i] = tmpPD[i];
			}
		}
		var newNormalData:Array<Float> = [];
		var tmpND = this._reconstructedMesh.getVerticesData(VertexBuffer.NormalKind);
		if (tmpND != null) {
			for (i in 0...tmpND.length) {
				newNormalData[i] = tmpND[i];
			}
		}
		var newUVsData:Array<Float> = [];
		var tmpUVD = this._reconstructedMesh.getVerticesData(VertexBuffer.UVKind);
		if (tmpUVD != null) {
			for (i in 0...tmpUVD.length) {
				newUVsData[i] = tmpUVD[i];
			}
		}
		var newColorsData:Array<Float> = [];
		var tmpCD = this._reconstructedMesh.getVerticesData(VertexBuffer.ColorKind);
		if (tmpCD != null) {
			for (i in 0...tmpCD.length) {
				newColorsData[i] = tmpCD[i];
			}
		}
		
		var normalData = this._mesh.getVerticesData(VertexBuffer.NormalKind);
		var uvs = this._mesh.getVerticesData(VertexBuffer.UVKind);
		var colorsData = this._mesh.getVerticesData(VertexBuffer.ColorKind);
		
		var vertexCount:Int = 0;
		for (i in 0...this.vertices.length) {
			var vertex = this.vertices[i];
			vertex.id = vertexCount;
			if (vertex.triangleCount > 0) {
				for(originalOffset in vertex.originalOffsets) {
					newPositionData.push(vertex.position.x);
					newPositionData.push(vertex.position.y);
					newPositionData.push(vertex.position.z);
					newNormalData.push(normalData[originalOffset * 3]);
					newNormalData.push(normalData[(originalOffset * 3) + 1]);
					newNormalData.push(normalData[(originalOffset * 3) + 2]);
					if (uvs != null && uvs.length > 0) {
						newUVsData.push(uvs[(originalOffset * 2)]);
						newUVsData.push(uvs[(originalOffset * 2) + 1]);
					} 
					else if (colorsData != null && colorsData.length > 0) {
						newColorsData.push(colorsData[(originalOffset * 4)]);
						newColorsData.push(colorsData[(originalOffset * 4) + 1]);
						newColorsData.push(colorsData[(originalOffset * 4) + 2]);
						newColorsData.push(colorsData[(originalOffset * 4) + 3]);
					}
					++vertexCount;
				}
			}
		}
		
		var startingIndex = this._reconstructedMesh.getTotalIndices();
		var startingVertex = this._reconstructedMesh.getTotalVertices();
		
		var submeshesArray = this._reconstructedMesh.subMeshes;
		this._reconstructedMesh.subMeshes = [];
		
		var newIndicesArray:Array<Int> = [];
		var tmpIA = this._reconstructedMesh.getIndices(); 
		if (tmpIA != null) {
			for (i in 0...tmpIA.length) {
				newIndicesArray[i] = tmpIA[i];
			}
		}
		var originalIndices = this._mesh.getIndices();
		for (i in 0...newTriangles.length) {
			var t = newTriangles[i];
			//now get the new referencing point for each vertex
			for(idx in [0, 1, 2]) {
				var id = originalIndices[t.originalOffset + idx];
				var offset = t.vertices[idx].originalOffsets.indexOf(id);
				if (offset < 0) {
					offset = 0;
				}
				newIndicesArray.push(t.vertices[idx].id + offset + startingVertex);
			}
		}
		
		//overwriting the old vertex buffers and indices.
		this._reconstructedMesh.setIndices(new Int32Array(newIndicesArray));
		this._reconstructedMesh.setVerticesData(VertexBuffer.PositionKind, new Float32Array(newPositionData));
		this._reconstructedMesh.setVerticesData(VertexBuffer.NormalKind, new Float32Array(newNormalData));
		if (newUVsData.length > 0) {
			this._reconstructedMesh.setVerticesData(VertexBuffer.UVKind, new Float32Array(newUVsData));
		}
		if (newColorsData.length > 0) {
			this._reconstructedMesh.setVerticesData(VertexBuffer.ColorKind, new Float32Array(newColorsData));
		}
		
		//create submesh
		var originalSubmesh = this._mesh.subMeshes[submeshIndex];
		if (submeshIndex > 0) {
			this._reconstructedMesh.subMeshes = [];
			for(submesh in submeshesArray) {
				new SubMesh(submesh.materialIndex, submesh.verticesStart, submesh.verticesCount,/* 0, newPositionData.length/3, */submesh.indexStart, submesh.indexCount, submesh.getMesh());
			}
			var newSubmesh = new SubMesh(originalSubmesh.materialIndex, startingVertex, vertexCount,/* 0, newPositionData.length / 3, */startingIndex, newTriangles.length * 3, this._reconstructedMesh);
		}
	}
	
	private function initDecimatedMesh() {
		this._reconstructedMesh = new Mesh(this._mesh.name + "Decimated", this._mesh.getScene());
		this._reconstructedMesh.material = this._mesh.material;
		this._reconstructedMesh.parent = this._mesh.parent;
		this._reconstructedMesh.isVisible = false;
		this._reconstructedMesh.renderingGroupId = this._mesh.renderingGroupId;
	}

	private function isFlipped(vertex1:DecimationVertex, vertex2:DecimationVertex, point:Vector3, deletedArray:Array<Bool>, borderFactor:Float, delTr:Array<DecimationTriangle>):Bool {
		
		for (i in 0...vertex1.triangleCount) {
			var t:DecimationTriangle = this.triangles[this.references[vertex1.triangleStart + i].triangleId];
			if (t.deleted) {
				continue;
			}
			
			var s = this.references[vertex1.triangleStart + i].vertexId;
			
			var v1 = t.vertices[(s + 1) % 3];
			var v2 = t.vertices[(s + 2) % 3];
			
			if ((v1 == vertex2 || v2 == vertex2)/* && !this.isTriangleOnBoundingBox(t)*/) {
				deletedArray[i] = true;
				delTr.push(t);
				continue;
			}
			
			var d1 = v1.position.subtract(point);
			d1 = d1.normalize();
			var d2 = v2.position.subtract(point);
			d2 = d2.normalize();
			if (Math.abs(Vector3.Dot(d1, d2)) > 0.999) return true;
			var normal = Vector3.Cross(d1, d2).normalize();
			deletedArray[i] = false;
			if (Vector3.Dot(normal, t.normal) < 0.2) return true;
		}
		
		return false;
	}

	private function updateTriangles(origVertex:DecimationVertex, vertex:DecimationVertex, deletedArray:Array<Bool>, deletedTriangles:Int):Int {
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
			
			t.vertices[ref.vertexId] = origVertex;
			t.isDirty = true;
			t.error[0] = this.calculateError(t.vertices[0], t.vertices[1]) + (t.borderFactor / 2);
			t.error[1] = this.calculateError(t.vertices[1], t.vertices[2]) + (t.borderFactor / 2);
			t.error[2] = this.calculateError(t.vertices[2], t.vertices[0]) + (t.borderFactor / 2);
			t.error[3] = Math.min(t.error[0], t.error[1]);
			t.error[3] = Math.min(t.error[3], t.error[2]);
			this.references.push(ref);
		}
		return newDeleted;
	}

	private function identifyBorder() {
		
		for (i in 0...this.vertices.length) {
			var vCount:Array<Int> = [];
			var vId:Array<Int> = [];
			var v = this.vertices[i];
			for (j in 0...v.triangleCount) {
				var triangle = this.triangles[this.references[v.triangleStart + j].triangleId];
				for (ii in 0...3) {
					var ofs:Int = 0;
					var vv = triangle.vertices[ii];
					while (ofs < vCount.length) {
						if (vId[ofs] == vv.id) {
							break;
						}
						++ofs;
					}
					if (ofs == vCount.length) {
						vCount.push(1);
						vId.push(vv.id);
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
				v = t.vertices[j];
				v.triangleCount++;
			}
		}
		
		var tStart:Int = 0;
		
		for (i in 0...this.vertices.length) {
			this.vertices[i].triangleStart = tStart;
			tStart += this.vertices[i].triangleCount;
			this.vertices[i].triangleCount = 0;
		}
		
		var newReferences:Array<Reference> = [];
		for (i in 0...this.triangles.length) {
			t = this.triangles[i];
			for (j in 0...3) {
				v = t.vertices[j];
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

	private function calculateError(vertex1:DecimationVertex, vertex2:DecimationVertex, ?pointResult:Vector3, ?normalResult:Vector3, ?uvResult:Vector2, ?colorResult:Color4):Float {
		var q = vertex1.q.add(vertex2.q);
		var border = vertex1.isBorder && vertex2.isBorder;
		var error:Float = 0.0;
		var qDet = q.det(0, 1, 2, 1, 4, 5, 2, 5, 7);

		if (qDet != 0 && !border) {
			if (pointResult == null) {
				pointResult = Vector3.Zero();
			}
			pointResult.x = -1 / qDet * (q.det(1, 2, 3, 4, 5, 6, 5, 7, 8));
			pointResult.y = 1 / qDet * (q.det(0, 2, 3, 1, 5, 6, 2, 7, 8));
			pointResult.z = -1 / qDet * (q.det(0, 1, 3, 1, 4, 6, 2, 5, 8));
			error = this.vertexError(q, pointResult);
		} 
		else {
			var p3 = (vertex1.position.add(vertex2.position)).divide(new Vector3(2, 2, 2));
			//var norm3 = (vertex1.normal.add(vertex2.normal)).divide(new Vector3(2, 2, 2)).normalize();
			var error1 = this.vertexError(q, vertex1.position);
			var error2 = this.vertexError(q, vertex2.position);
			var error3 = this.vertexError(q, p3);
			error = Math.min(error1, error2);
			error = Math.min(error, error3);
			if (error == error1) {
				if (pointResult != null) {
					pointResult.copyFrom(vertex1.position);
				}
			} else if (error == error2) {
				if (pointResult != null) {
					pointResult.copyFrom(vertex2.position);
				}
			} else {
				if (pointResult != null) {
					pointResult.copyFrom(p3);
				}
			}
		}
		return error;
	}
	
}
