package com.gamestudiohx.babylonhx.mesh;

import com.gamestudiohx.babylonhx.collisions.Collider;
import com.gamestudiohx.babylonhx.culling.BoundingInfo;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.mesh.Mesh.BabylonGLBuffer;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Plane;
import com.gamestudiohx.babylonhx.tools.math.Ray;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.Tools;
import com.gamestudiohx.babylonhx.materials.Material;
import com.gamestudiohx.babylonhx.materials.MultiMaterial;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class SubMesh {
		
	public var materialIndex:Int;
	public var verticesStart:Int;
	public var verticesCount:Int;
	public var indexStart:Int;
	public var indexCount:Int;
	
	private var _mesh:Mesh;
	public var _trianglePlanes:Array<Plane>;
	private var _boundingInfo:BoundingInfo;
	private var _linesIndexBuffer:BabylonGLBuffer;
	public var _distanceToCamera:Float;
	public var linesIndexCount:Int;
	public var _lastColliderWorldVertices:Array<Vector3>;
	public var _lastColliderTransformMatrix:Matrix;
	
	public var _renderId:Int;
	

	public function new(materialIndex:Int, verticesStart:Int, verticesCount:Int, indexStart:Int, indexCount:Int, mesh:Mesh) {
		this._mesh = mesh;
        mesh.subMeshes.push(this);
        this.materialIndex = materialIndex;
        this.verticesStart = verticesStart;
        this.verticesCount = verticesCount;
        this.indexStart = indexStart;
        this.indexCount = indexCount;

        this.refreshBoundingInfo();
	}
	
	public function getBoundingInfo():BoundingInfo {
        return this._boundingInfo;
    }
	
	public function getMesh():Mesh {
        return this._mesh;
    }
	
	public function getMaterial():Dynamic {
        var rootMaterial = this._mesh.material;

        if (rootMaterial != null && Std.is(rootMaterial, MultiMaterial)) {
            return rootMaterial.getSubMaterial(this.materialIndex);
        }

        if (rootMaterial == null) {
            return this._mesh._scene.defaultMaterial;
        }

        return rootMaterial;
    }
	
	inline public function refreshBoundingInfo() {
        var data = this._mesh.getVerticesData(VertexBuffer.PositionKind);

        if (data != null) {
            var extend = Tools.ExtractMinAndMax(data, this.verticesStart, this.verticesCount);
			this._boundingInfo = new BoundingInfo(extend.minimum, extend.maximum);
        }
    }
	
	inline public function _checkCollision(collider:Collider):Bool {
        return this._boundingInfo._checkCollision(collider);
    }
	
	inline public function updateBoundingInfo(world:Matrix, scale:Float) {
        this._boundingInfo._update(world, scale);
    }
	
	inline public function isInFrustrum(frustumPlanes:Array<Plane>):Bool {
        return this._boundingInfo.isInFrustrum(frustumPlanes);
    }
	
	public function render() {
        this._mesh.render(this);
    }
	
	inline public function getLinesIndexBuffer(indices:Array<Int>, engine:Engine):BabylonGLBuffer {
        if (this._linesIndexBuffer == null) {
            var linesIndices:Array<Int> = [];

			var index:Int = this.indexStart;
			while(index < this.indexStart + this.indexCount) {
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
        return ray.intersectsBox(this._boundingInfo.boundingBox);
    }
	
	inline public function intersects(ray:Ray, positions:Array<Vector3>, indices:Array<Int>, fastCheck:Bool = false) {
        var distance = Math.POSITIVE_INFINITY;

        // Triangles test
		var index:Int = this.indexStart;
		while(index < this.indexStart + this.indexCount) {
            var p0 = positions[indices[index]];
            var p1 = positions[indices[index + 1]];
            var p2 = positions[indices[index + 2]];

            var currentDistance = ray.intersectsTriangle(p0, p1, p2);

            if (currentDistance > 0) {
                if (fastCheck || currentDistance < distance) {
                    distance = currentDistance;

                    if (fastCheck) {
                        break;
                    }
                }
            }
			
			index += 3;
        }

        if (!(distance > 0 && distance < Math.POSITIVE_INFINITY)) {
            distance = 0;
		}

        return distance;
    }
	
	public function clone(newMesh:Mesh):SubMesh {
        return new SubMesh(this.materialIndex, this.verticesStart, this.verticesCount, this.indexStart, this.indexCount, newMesh);
    }
	
	public static function CreateFromIndices(materialIndex:Int, startIndex:Int, indexCount:Int, mesh: Mesh):SubMesh {
        var minVertexIndex = Math.POSITIVE_INFINITY;
        var maxVertexIndex = Math.NEGATIVE_INFINITY;

        var indices:Array<Int> = mesh.getIndices();

        for (index in startIndex...startIndex + indexCount) {
            var vertexIndex = indices[index];

            if (vertexIndex < minVertexIndex)
                minVertexIndex = vertexIndex;
            else if (vertexIndex > maxVertexIndex)
                maxVertexIndex = vertexIndex;
        }

        return new SubMesh(materialIndex, cast minVertexIndex, cast(maxVertexIndex - minVertexIndex), startIndex, indexCount, mesh);
    }
	
}
