package com.babylonhx.mesh;

import com.babylonhx.materials.Material;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Plane;
import com.babylonhx.culling.Ray;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.IntersectionInfo;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.tools.Tools;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SubMesh') class SubMesh {
	
	public var linesIndexCount:Int;

	private var _mesh:AbstractMesh;
	private var _renderingMesh:Mesh;
	private var _boundingInfo:BoundingInfo;
	private var _linesIndexBuffer:WebGLBuffer;
	public var _lastColliderWorldVertices:Array<Vector3>;
	public var _trianglePlanes:Array<Plane>;
	public var _lastColliderTransformMatrix:Matrix;
	
	public var __smartArrayFlags:Array<Int> = [];

	public var _renderId:Int = 0;
	public var _alphaIndex:Float;
	public var _distanceToCamera:Float;
	public var _id:Int;
	
	public var materialIndex:Int;
	public var verticesStart:Int;
	public var verticesCount:Int;
	public var indexStart:Int;
	public var indexCount:Int;
	
	public var IsGlobal(get, never):Bool;
	

	public function new(materialIndex:Int, verticesStart:Int, verticesCount:Int, indexStart:Int, indexCount:Int, mesh:AbstractMesh, ?renderingMesh:Mesh, createBoundingBox:Bool = true) {
		this.materialIndex = materialIndex;
		this.verticesStart = verticesStart;
		this.verticesCount = verticesCount;
		this.indexStart = indexStart;
		this.indexCount = indexCount;
		
		this._mesh = mesh;
		this._renderingMesh = renderingMesh != null ? renderingMesh : cast(mesh, Mesh);
		mesh.subMeshes.push(this);
		
		this._trianglePlanes = [];
		
		this._id = mesh.subMeshes.length - 1;
		
		if (createBoundingBox) {
			this.refreshBoundingInfo();
			mesh.computeWorldMatrix(true);
		}
	}
	
	private function get_IsGlobal():Bool {
		return (this.verticesStart == 0 && this.verticesCount == this._mesh.getTotalVertices());
	}

	inline public function getBoundingInfo():BoundingInfo {
		if (this.IsGlobal) {
			return this._mesh.getBoundingInfo();
		}
		
		return this._boundingInfo;
	}

	inline public function getMesh():AbstractMesh {
		return this._mesh;
	}

	inline public function getRenderingMesh():Mesh {
		return this._renderingMesh;
	}

	public function getMaterial():Material {
		var rootMaterial = this._renderingMesh.material;
		
		if (rootMaterial != null && Std.is(rootMaterial, MultiMaterial)) {
			var multiMaterial:MultiMaterial = cast rootMaterial;
			return multiMaterial.getSubMaterial(this.materialIndex);
		}
		
		if (rootMaterial == null) {
			return this._mesh.getScene().defaultMaterial;
		}
		
		return rootMaterial;
	}

	// Methods
	public function refreshBoundingInfo() {
		this._lastColliderWorldVertices = null;
		
		if (this.IsGlobal) {
			return;
		}
		
		var data = this._renderingMesh.getVerticesData(VertexBuffer.PositionKind);
		
		if (data == null) {
			this._boundingInfo = this._mesh._boundingInfo;
			return;
		}
		
		var indices = this._renderingMesh.getIndices();
		var extend:Dynamic = {
			minimum: Vector3.Zero(),
			maximum: Vector3.Zero()
		};
		
		//is this the only submesh?
		if (this.indexStart == 0 && this.indexCount == indices.length) {
			//the rendering mesh's bounding info can be used, it is the standard submesh for all indices.
			extend = { minimum: this._renderingMesh.getBoundingInfo().minimum.clone(), maximum: this._renderingMesh.getBoundingInfo().maximum.clone() };
		}
		else {
			extend = Tools.ExtractMinAndMaxIndexed(data, indices, this.indexStart, this.indexCount);
		}
		this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);
	}

	inline public function _checkCollision(collider:Collider):Bool {
		return this.getBoundingInfo()._checkCollision(collider);
	}

	inline public function updateBoundingInfo(world:Matrix) {
		if (this.getBoundingInfo() == null) {
			this.refreshBoundingInfo();
		}
		
		this.getBoundingInfo()._update(world);
	}

	inline public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		return this.getBoundingInfo().isInFrustum(frustumPlanes);
	}

	inline public function render(enableAlphaMode:Bool) {
		this._renderingMesh.render(this, enableAlphaMode);
	}

	inline public function getLinesIndexBuffer(indices:Array<Int>, engine:Engine):WebGLBuffer {
		if (this._linesIndexBuffer == null) {
			var linesIndices:Array<Int> = [];
			
			var index:Int = this.indexStart;
			while (index < this.indexStart + this.indexCount) {
				linesIndices.push(indices[index]);
				linesIndices.push(indices[index + 1]);
				linesIndices.push(indices[index + 1]);
				linesIndices.push(indices[index + 2]);
				linesIndices.push(indices[index + 2]);
				linesIndices.push(indices[index]);
				index += 3;
			}
			
			this._linesIndexBuffer = engine.createIndexBuffer(linesIndices);
			this.linesIndexCount = linesIndices.length;
		}
		
		return this._linesIndexBuffer;
	}

	inline public function canIntersects(ray:Ray):Bool {
		return ray.intersectsBox(this.getBoundingInfo().boundingBox);
	}

	inline public function intersects(ray:Ray, positions:Array<Vector3>, indices:Array<Int>, fastCheck:Bool = false):IntersectionInfo {
		var intersectInfo:IntersectionInfo = null;
		
		// LineMesh first as it's also a Mesh...
		if (Std.is(this._mesh, LinesMesh)) {
			var lineMesh:LinesMesh = cast this._mesh;
			
			// Line test
			var index:Int = this.indexStart;
			while (index < this.indexStart + this.indexCount) {			
				var p0 = positions[indices[index]];
				var p1 = positions[indices[index + 1]];
				
				var length = ray.intersectionSegment(p0, p1, lineMesh.intersectionThreshold);
				if (length < 0) {
					index += 2;
					continue;
				}
				
				if (fastCheck || intersectInfo == null || length < intersectInfo.distance) {
					intersectInfo = new IntersectionInfo(0, 0, length);
					
					if (fastCheck) {
						break;
					}
				}
				
				index += 2;
			}
		}
		else {
			// Triangles test
			var index:Int = this.indexStart;
			while (index < this.indexStart + this.indexCount) {
				var p0 = positions[indices[index]];
				var p1 = positions[indices[index + 1]];
				var p2 = positions[indices[index + 2]];
				
				var currentIntersectInfo = ray.intersectsTriangle(p0, p1, p2);
				
				if (currentIntersectInfo != null) {
                    if (currentIntersectInfo.distance < 0) {
						index += 3;
                        continue;
                    }
					
                    if (fastCheck || intersectInfo == null || currentIntersectInfo.distance < intersectInfo.distance) {
                        intersectInfo = currentIntersectInfo;
                        intersectInfo.faceId = Std.int(index / 3);
						
                        if (fastCheck) {
                            break;
                        }
                    }
                }
				
				index += 3;
			}
		}
		
		return intersectInfo;
	}

	// Clone    
	public function clone(newMesh:AbstractMesh, ?newRenderingMesh:Mesh):SubMesh {
		var result = new SubMesh(this.materialIndex, this.verticesStart, this.verticesCount, this.indexStart, this.indexCount, newMesh, newRenderingMesh, false);
		
		if (!this.IsGlobal) {
			result._boundingInfo = new BoundingInfo(this._boundingInfo.minimum, this._boundingInfo.maximum);
		}
		
		return result;
	}

	// Dispose
	public function dispose() {
		if (this._linesIndexBuffer != null) {
			this._mesh.getScene().getEngine()._releaseBuffer(this._linesIndexBuffer);
			this._linesIndexBuffer = null;
		}
		
		// Remove from mesh
		this._mesh.subMeshes.remove(this);
	}

	// Statics
	public static function CreateFromIndices(materialIndex:Int, startIndex:Int, indexCount:Int, mesh:AbstractMesh, ?renderingMesh:Mesh):SubMesh {
		var minVertexIndex = Math.POSITIVE_INFINITY;
		var maxVertexIndex = Math.NEGATIVE_INFINITY;
		
		renderingMesh = renderingMesh != null ? renderingMesh : cast(mesh, Mesh);
		var indices = renderingMesh.getIndices();
		
		for (index in startIndex...startIndex + indexCount) {
			var vertexIndex = indices[index];
			
			if (vertexIndex < minVertexIndex) {
				minVertexIndex = vertexIndex;
			}
			if (vertexIndex > maxVertexIndex) {
				maxVertexIndex = vertexIndex;
			}
		}
		
		return new SubMesh(materialIndex, Std.int(minVertexIndex), Std.int(maxVertexIndex - minVertexIndex + 1), startIndex, indexCount, mesh, renderingMesh);
	}
	
}
