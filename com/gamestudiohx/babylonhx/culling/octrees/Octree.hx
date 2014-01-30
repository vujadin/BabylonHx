package com.gamestudiohx.babylonhx.culling.octrees;

import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.tools.math.Plane;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.SmartArray;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Octree {
	
	public var blocks:Array<OctreeBlock>;
	public var _maxBlockCapacity:Int;
	public var _selection:Array<OctreeBlock>;// SmartArray;			// TODO: check what this could be ?? Array<OctreeBlock>
	

	public function new(maxBlockCapacity:Int = 64) {
		this.blocks = [];
        this._maxBlockCapacity = maxBlockCapacity;
        this._selection = [];// new SmartArray(); // (256);
	}
	
	public function update(worldMin:Vector3, worldMax:Vector3, meshes:Array<Mesh>) {
        _CreateBlocks(worldMin, worldMax, meshes, this._maxBlockCapacity, this);
    }
	
	public function addMesh(mesh:Mesh) {
        for (index in 0...this.blocks.length) {
            var block:OctreeBlock = this.blocks[index];
            block.addMesh(mesh);
        }
    }
	
	public function select(frustumPlanes:Array<Plane>):Array<OctreeBlock> { //SmartArray {
        // TODO - this should be SmartArray
		//this._selection.reset();

        for (index in 0...this.blocks.length) {
            var block:OctreeBlock = this.blocks[index];
            block.select(frustumPlanes, this._selection);
        }

        return this._selection;
    }
	
	public static function _CreateBlocks(worldMin:Vector3, worldMax:Vector3, meshes:Array<Mesh>, maxBlockCapacity:Int, target:Dynamic) {
        target.blocks = [];
        var blockSize = new Vector3((worldMax.x - worldMin.x) / 2, (worldMax.y - worldMin.y) / 2, (worldMax.z - worldMin.z) / 2);

        // Segmenting space
        for (x in 0...2) {
            for (y in 0...2) {
                for (z in 0...2) {
                    var localMin:Vector3 = worldMin.add(blockSize.multiplyByFloats(x, y, z));
                    var localMax:Vector3 = worldMin.add(blockSize.multiplyByFloats(x + 1, y + 1, z + 1));

                    var block:OctreeBlock = new OctreeBlock(localMin, localMax, maxBlockCapacity);
                    block.addEntries(meshes);
                    target.blocks.push(block);
                }
            }
        }
    }
	
}
