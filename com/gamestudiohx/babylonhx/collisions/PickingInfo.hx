package com.gamestudiohx.babylonhx.collisions;

import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.tools.math.Vector3;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class PickingInfo {
	
	public var hit:Bool = false;
    public var distance:Float;
    public var pickedPoint:Vector3;
    public var pickedMesh:Mesh;

	public function new() {
		this.hit = false;
		this.distance = 0;
		this.pickedPoint = null;
		this.pickedMesh = null;
	}
	
}
