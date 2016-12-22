package com.babylonhx.bones;

import com.babylonhx.math.Space;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
/**
 * ...
 * @author Krtolica Vujadin
 */
class BoneLookController {

	public var target:Vector3;
	public var mesh:AbstractMesh;
	public var bone:Bone;
	public var upAxis:Vector3 = Vector3.Up();

	public var adjustYaw:Float = 0;
	public var adjustPitch:Float = 0;
	public var adjustRoll:Float = 0;
	
	private var _tmpVec1:Vector3 = Vector3.Zero();
	private var _tmpVec2:Vector3 = Vector3.Zero();
	private var _tmpVec3:Vector3 = Vector3.Zero();
	private var _tmpVec4:Vector3 = Vector3.Zero();
	
	private var _tmpMat1:Matrix = Matrix.Identity();
	private var _tmpMat2:Matrix = Matrix.Identity();
	

	// options:  {adjustYaw?: number, adjustPitch?: number, adjustRoll?: number} 
	public function new(mesh:AbstractMesh, bone:Bone, target:Vector3, ?options:Dynamic) {
		this.mesh = mesh;
		this.bone = bone;
		this.target = target;
		
		if (options != null) {
			if (options.adjustYaw != null) {
				this.adjustYaw = options.adjustYaw;
			}
			
			if (options.adjustPitch != null) {
				this.adjustPitch = options.adjustPitch;
			}
			
			if (options.adjustRoll != null) {
				this.adjustRoll = options.adjustRoll;
			}
		}
	}

	public function update() {			
		var bone = this.bone;
		var target = this.target;
		
		var bonePos = this._tmpVec1;
		var zaxis = this._tmpVec2;
		var xaxis = this._tmpVec3;
		var yaxis = this._tmpVec4;
		var mat1 = this._tmpMat1;
		var mat2 = this._tmpMat2;
		
		bone.getAbsolutePositionToRef(this.mesh, bonePos);
		
		target.subtractToRef(bonePos, zaxis);
		zaxis.normalize();
		
		Vector3.CrossToRef(this.upAxis, zaxis, xaxis);
		xaxis.normalize();
		
		Vector3.CrossToRef(zaxis, xaxis, yaxis);
		yaxis.normalize();
		
		Matrix.FromXYZAxesToRef(xaxis, yaxis, zaxis, mat1);
		
		if (this.adjustYaw != 0 || this.adjustPitch != 0 || this.adjustRoll != 0) {
			Matrix.RotationYawPitchRollToRef(this.adjustYaw, this.adjustPitch, this.adjustRoll, mat2);
			mat2.multiplyToRef(mat1, mat1);
		}
		
		this.bone.setRotationMatrix(mat1, Space.WORLD, this.mesh);		
	}
	
}
