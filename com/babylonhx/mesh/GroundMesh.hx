package com.babylonhx.mesh;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Ray;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.GroundMesh') class GroundMesh extends Mesh {
	
	public var generateOctree = false;

	private var _worldInverse = new Matrix();
	public var _subdivisions:Int;

	
	public function new(name:String, scene:Scene) {
		super(name, scene);
	}

	public function optimize(chunksCount:Float):Void {
		this.subdivide(this._subdivisions);
		this.createOrUpdateSubmeshesOctree(32);
	}

	public function getHeightAtCoordinates(x:Float, z:Float):Float {
		var ray = new Ray(new Vector3(x, this.getBoundingInfo().boundingBox.maximumWorld.y + 1, z), new Vector3(0, -1, 0));

		this.getWorldMatrix().invertToRef(this._worldInverse);

		ray = Ray.Transform(ray, this._worldInverse);

		var pickInfo = this.intersects(ray);

		if (pickInfo.hit) {
			return pickInfo.pickedPoint.y;
		}

		return 0;
	}
	
}
