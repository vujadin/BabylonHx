package com.babylonhx.mesh;

import com.babylonhx.materials.Material;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.MaterialDefines;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Plane;
import com.babylonhx.culling.Ray;
import com.babylonhx.collisions.Collider;
import com.babylonhx.collisions.IntersectionInfo;
import com.babylonhx.culling.BoundingInfo;
import com.babylonhx.culling.ICullable;
import com.babylonhx.math.Tools as MathTools;

import lime.utils.Int32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SubMesh') class SubMesh extends BaseSubMesh implements ICullable implements ISmartArrayCompatible implements IHasBoundingInfo {
	
	public var linesIndexCount:Int;

	private var _mesh:AbstractMesh;
	private var _renderingMesh:Mesh;
	public var _boundingInfo:BoundingInfo;
	private var _linesIndexBuffer:WebGLBuffer;
	public var _lastColliderWorldVertices:Array<Vector3>;
	public var _trianglePlanes:Array<Plane>;
	public var _lastColliderTransformMatrix:Matrix;

	public var _renderId:Int = 0;
	public var _alphaIndex:Float;
	public var _distanceToCamera:Float;
	public var _id:Int;
	
	private var _currentMaterial:Material;
	
	public var materialIndex:Int;
	public var verticesStart:Int;
	public var verticesCount:Int;
	public var indexStart:Int;
	public var indexCount:Int;
	
	public var __smartArrayFlags:Array<Int> = [];	// BHX
	

	public function new(materialIndex:Int, verticesStart:Int, verticesCount:Int, indexStart:Int, indexCount:Int, mesh:AbstractMesh, ?renderingMesh:Mesh, createBoundingBox:Bool = true) {
		super();
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
	
	public var IsGlobal(get, never):Bool;
	private function get_IsGlobal():Bool {
		return (this.verticesStart == 0 && this.verticesCount == this._mesh.getTotalVertices());
	}

	/**
	 * Returns the submesh BoudingInfo object.  
	 */
	inline public function getBoundingInfo():BoundingInfo {
		if (this.IsGlobal) {
			return this._mesh.getBoundingInfo();
		}
		
		return this._boundingInfo;
	}
	
	inline public function setBoundingInfo(boundingInfo:BoundingInfo):SubMesh {
        this._boundingInfo = boundingInfo;
		return this;
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
			var effectiveMaterial = multiMaterial.getSubMaterial(this.materialIndex);
			
			if (this._currentMaterial != effectiveMaterial) {
				this._currentMaterial = effectiveMaterial;
				this._materialDefines = null;
			}
			
			return effectiveMaterial;
		}
		
		if (rootMaterial == null) {
			return this._mesh.getScene().defaultMaterial;
		}
		
		return rootMaterial;
	}

	// Methods
	
	/**
	 * Sets a new updated BoundingInfo object to the submesh.  
	 * Returns the SubMesh.  
	 */
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
			extend = MathTools.ExtractMinAndMaxIndexed(data, indices, this.indexStart, this.indexCount);
		}
		
		this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);
	}

	inline public function _checkCollision(collider:Collider):Bool {
		return this.getBoundingInfo()._checkCollision(collider);
	}

	/**
	 * Updates the submesh BoundingInfo.  
	 * Returns the Submesh.  
	 */
	inline public function updateBoundingInfo(world:Matrix):SubMesh {
		if (this.getBoundingInfo() == null) {
			this.refreshBoundingInfo();
		}		
		this.getBoundingInfo().update(world);
		return this;
	}

	/**
	 * True is the submesh bounding box intersects the frustum defined by the passed array of planes.  
	 * Boolean returned.  
	 */
	inline public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		return this.getBoundingInfo().isInFrustum(frustumPlanes);
	}
	
	/**
	 * True is the submesh bounding box is completely inside the frustum defined by the passed array of planes.  
	 * Boolean returned.  
	 */        
	inline public function isCompletelyInFrustum(frustumPlanes:Array<Plane>):Bool {
		return this.getBoundingInfo().isCompletelyInFrustum(frustumPlanes);
	}

	public function render(enableAlphaMode:Bool):SubMesh {
		this._renderingMesh.render(this, enableAlphaMode);
		return this;
	}

	/**
	 * Returns a new Index Buffer.  
	 * Type returned : WebGLBuffer.  
	 */
	inline public function getLinesIndexBuffer(indices:Int32Array, engine:Engine):WebGLBuffer {
		if (this._linesIndexBuffer == null) {
			var linesIndices:Int32Array = new Int32Array(this.indexCount);
			
			var index:Int = this.indexStart;
			var i:Int = 0;
			while (index < this.indexStart + this.indexCount) {
				linesIndices[i++] = indices[index];
				linesIndices[i++] = indices[index + 1];
				linesIndices[i++] = indices[index + 1];
				linesIndices[i++] = indices[index + 2];
				linesIndices[i++] = indices[index + 2];
				linesIndices[i++] = indices[index];
				index += 3;
			}
			
			this._linesIndexBuffer = engine.createIndexBuffer(linesIndices);
			this.linesIndexCount = linesIndices.length;
		}
		
		return this._linesIndexBuffer;
	}

	/**
	 * True is the passed Ray intersects the submesh bounding box.  
	 * Boolean returned.  
	 */
	inline public function canIntersects(ray:Ray):Bool {
		return ray.intersectsBox(this.getBoundingInfo().boundingBox);
	}

	/**
	 * Returns an object IntersectionInfo.  
	 */
	public function intersects(ray:Ray, positions:Array<Vector3>, indices:Int32Array, fastCheck:Bool = false):IntersectionInfo {
		var intersectInfo:IntersectionInfo = null;
		
		// fix for picking instances: https://github.com/vujadin/BabylonHx/issues/122
		if (positions == null) {
			positions = this._mesh._positions;
		}
		
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
	/**
	 * Creates a new Submesh from the passed parameters : 
	 * - materialIndex (integer) : the index of the main mesh material.  
	 * - startIndex (integer) : the index where to start the copy in the mesh indices array.  
	 * - indexCount (integer) : the number of indices to copy then from the startIndex.  
	 * - mesh (Mesh) : the main mesh to create the submesh from.  
	 * - renderingMesh (optional Mesh) : rendering mesh.  
	 */
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
