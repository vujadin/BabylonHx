package com.gamestudiohx.babylonhx.culling.octrees;

import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.mesh.SubMesh;
import com.gamestudiohx.babylonhx.tools.math.Plane;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.culling.BoundingBox;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class OctreeBlock {
	
	public var meshes:Array<Mesh>;
	public var subMeshes:Array<Array<SubMesh>>; // SubMesh;
	public var _capacity:Int;
	
	public var _minPoint:Vector3;
	public var _maxPoint:Vector3;
	
	public var _boundingVectors:Array<Vector3>;
	
	public var blocks:Array<OctreeBlock>;	
	

	public function new(minPoint:Vector3, maxPoint:Vector3, capacity:Int) {
		this.subMeshes = [];
        this.meshes = [];
        this._capacity = capacity;

        this._minPoint = minPoint;
        this._maxPoint = maxPoint;
        
        this._boundingVectors = [];

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors.push(maxPoint.clone());

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors[2].x = maxPoint.x;

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors[3].y = maxPoint.y;

        this._boundingVectors.push(minPoint.clone());
        this._boundingVectors[4].z = maxPoint.z;

        this._boundingVectors.push(maxPoint.clone());
        this._boundingVectors[5].z = minPoint.z;

        this._boundingVectors.push(maxPoint.clone());
        this._boundingVectors[6].x = minPoint.x;

        this._boundingVectors.push(maxPoint.clone());
        this._boundingVectors[7].y = minPoint.y;
	}
	
	public function addMesh(mesh:Mesh) {
        if (this.blocks != null) {
            for (index in 0...this.blocks.length) {
                var block:OctreeBlock = this.blocks[index];
                block.addMesh(mesh);
            }
        } else {
			if (mesh.getBoundingInfo().boundingBox.intersectsMinMax(this._minPoint, this._maxPoint)) {
				var localMeshIndex:Int = this.meshes.length;
				this.meshes.push(mesh);

				this.subMeshes[localMeshIndex] = [];
				for (subIndex in 0...mesh.subMeshes.length) {
					var subMesh = mesh.subMeshes[subIndex];
					if (mesh.subMeshes.length == 1 || subMesh.getBoundingInfo().boundingBox.intersectsMinMax(this._minPoint, this._maxPoint)) {
						this.subMeshes[localMeshIndex].push(subMesh);
					}
				}
			}
			
			if (this.subMeshes.length > this._capacity) {
				Octree._CreateBlocks(this._minPoint, this._maxPoint, this.meshes, this._capacity, this);
			}
		}
    }
	
	public function addEntries(meshes:Array<Mesh>) {
        for (index in 0...meshes.length) {
            var mesh = meshes[index];
            this.addMesh(mesh);
        }       
    }
	
	public function select(frustumPlanes:Array<Plane>, selection:Array<OctreeBlock>) {
        if (this.blocks != null && this.blocks.length > 0) {
            for (index in 0...this.blocks.length) {
                var block:OctreeBlock = this.blocks[index];
                block.select(frustumPlanes, selection);
            }
        } else if (BoundingBox.IsInFrustum(this._boundingVectors, frustumPlanes)) {
            selection.push(this);
        }
    }
	
}