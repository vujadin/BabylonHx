package com.babylonhx.bones;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Space;
import com.babylonhx.math.Quaternion;
import com.babylonhx.mesh.AbstractMesh;


/**
 * ...
 * @author Krtolica Vujadin
 */
class BoneIKController {

	public var targetMesh:AbstractMesh;
	public var poleTargetMesh:AbstractMesh;
	public var poleTargetBone:Bone;	
	public var targetPosition:Vector3 = Vector3.Zero();
    public var poleTargetPosition:Vector3 = Vector3.Zero();   
    public var poleTargetLocalOffset:Vector3 = Vector3.Zero();
	public var poleAngle:Float = 0;	
	public var mesh:AbstractMesh;
	public var slerpAmount:Float = 1;

    private var _bone1Quat:Quaternion = Quaternion.Identity();
    private var _bone1Mat:Matrix = Matrix.Identity();
    private var _bone2Ang:Float = Math.PI;

	private var _bone1:Bone;
	private var _bone2:Bone;
	private var _bone1Length:Float;
	private var _bone2Length:Float;
	private var _maxAngle:Float = Math.PI;
	private var _maxReach:Float;

	private var _tmpVec1:Vector3 = Vector3.Zero();
	private var _tmpVec2:Vector3 = Vector3.Zero();
	private var _tmpVec3:Vector3 = Vector3.Zero();
	private var _tmpVec4:Vector3 = Vector3.Zero();
	private var _tmpVec5:Vector3 = Vector3.Zero();

	private var _tmpMat1:Matrix = Matrix.Identity();
	private var _tmpMat2:Matrix = Matrix.Identity();
	private var _tmpQuat1:Quaternion = Quaternion.Identity();

	private var _rightHandedSystem:Bool = false;
	
	private var _bendAxis:Vector3 = Vector3.Right();
	private var _slerping:Bool = false;

	public var maxAngle(get, set):Float;
	private function get_maxAngle():Float {
		return this._maxAngle;
	}
	private function set_maxAngle(value:Float):Float {		
		this._setMaxAngle(value);
		
		return value;
	}
	

	// options: { targetMesh?: AbstractMesh, poleTargetMesh?: AbstractMesh, poleTargetBone?: Bone, poleTargetLocalOffset?:Vector3, poleAngle?: number, bendAxis?: Vector3, maxAngle?:number, slerpAmount?:number }
	public function new(mesh:AbstractMesh, bone:Bone, ?options:Dynamic) {		
		this._bone2 = bone;
		this._bone1 = bone.getParent();
		
		this.mesh = mesh;
		
		if (bone.getAbsoluteTransform().determinant() > 0) {
			this._rightHandedSystem = true;
			this._bendAxis.x = 0;
            this._bendAxis.y = 0;
            this._bendAxis.z = 1;
		}
		
		if (this._bone1.length != 0) {
			var boneScale1 = this._bone1.getScale();
			var boneScale2 = this._bone2.getScale();
			
			this._bone1Length = this._bone1.length * boneScale1.y * this.mesh.scaling.y;
			this._bone2Length = this._bone2.length * boneScale2.y * this.mesh.scaling.y;
		} 
		else if (this._bone1.children[0] != null) {		
			mesh.computeWorldMatrix(true);
			
			var pos1 = this._bone2.children[0].getPosition(Space.WORLD, mesh);
            var pos2 = this._bone2.getPosition(Space.WORLD, mesh);
            var pos3 = this._bone1.getPosition(Space.WORLD, mesh);
			
			this._bone1Length = Vector3.Distance(pos1, pos2);
			this._bone2Length = Vector3.Distance(pos2, pos3);
		}
		
		this._bone1.getRotationMatrixToRef(Space.WORLD, mesh, this._bone1Mat);
		this.maxAngle = Math.PI;
		
		if (options != null) {
			if (options.targetMesh != null) {
				this.targetMesh = options.targetMesh;
				this.targetMesh.computeWorldMatrix(true);
			}
			
			if (options.poleTargetMesh != null) {
				this.poleTargetMesh = options.poleTargetMesh;
				this.poleTargetMesh.computeWorldMatrix(true);
			}
			else if (options.poleTargetBone != null) {
				this.poleTargetBone = options.poleTargetBone;
			}
			else if (this._bone1.getParent() != null) {
				this.poleTargetBone = this._bone1.getParent();
			}
			
			if (options.poleTargetLocalOffset != null) {
				this.poleTargetLocalOffset.copyFrom(options.poleTargetLocalOffset);
			}
			
			if (options.poleAngle != null) {
				this.poleAngle = options.poleAngle;
			}
			
			if (options.bendAxis != null) {
				this._bendAxis.copyFrom(options.bendAxis);
			}
			
			if (options.maxAngle != null) {
				this.maxAngle = options.maxAngle;
			}
			
			if (options.slerpAmount != null) {
                this.slerpAmount = options.slerpAmount;
            }
		}
	}

	private function _setMaxAngle(ang:Float) {
		if (ang < 0) {
			ang = 0;
		}
		
		if (ang > Math.PI) {
			ang = Math.PI;
		}
		
		this._maxAngle = ang;
		
		var a = this._bone1Length;
		var b = this._bone2Length;
		
		this._maxReach = Math.sqrt(a * a + b * b - 2 * a * b * Math.cos(ang));
	}

	public function update() {
		var bone1 = this._bone1;
		var target = this.targetPosition;
		var poleTarget = this.poleTargetPosition;
		
		var mat1 = this._tmpMat1;
        var mat2 = this._tmpMat2;
		
        if (this.targetMesh != null) {
            target.copyFrom(this.targetMesh.getAbsolutePosition());
        }
		
        if (this.poleTargetBone != null) {
            this.poleTargetBone.getAbsolutePositionFromLocalToRef(this.poleTargetLocalOffset, this.mesh, poleTarget);
        }
		else if (this.poleTargetMesh != null) {
            Vector3.TransformCoordinatesToRef(this.poleTargetLocalOffset, this.poleTargetMesh.getWorldMatrix(), poleTarget);
        }
		
		var bonePos = this._tmpVec1;
		var zaxis = this._tmpVec2;
		var xaxis = this._tmpVec3;
		var yaxis = this._tmpVec4;
		var upAxis = this._tmpVec5;
		
		bone1.getAbsolutePositionToRef(this.mesh, bonePos);
		
		poleTarget.subtractToRef(bonePos, upAxis);
		
		if (upAxis.x == 0 && upAxis.y == 0 && upAxis.z == 0) {
			upAxis.y = 1;
		} 
		else {
			upAxis.normalize();
		}
		
		target.subtractToRef(bonePos, yaxis);
		yaxis.normalize();
		
		Vector3.CrossToRef(yaxis, upAxis, zaxis);
		zaxis.normalize();
		
		Vector3.CrossToRef(yaxis, zaxis, xaxis);
		xaxis.normalize();
		
		Matrix.FromXYZAxesToRef(xaxis, yaxis, zaxis, mat1);
		
		var a = this._bone1Length;
		var b = this._bone2Length;
		
		var c = Vector3.Distance(bonePos, target);
		
		if (this._maxReach > 0) {
			c = Math.min(this._maxReach, c);
		}
		
		var acosa = (b * b + c * c - a * a) / (2 * b * c);
		var acosb = (c * c + a * a - b * b) / (2 * c * a);
		
		if (acosa > 1) {
			acosa = 1;
		}
		
		if (acosb > 1) {
			acosb = 1;
		}
		
		if (acosa < -1) {
			acosa = -1;
		}
		
		if (acosb < -1) {
			acosb = -1;
		}
		
		var angA = Math.acos(acosa);
		var angB = Math.acos(acosb);
		
		var angC = -angA - angB;
		
		if (this._rightHandedSystem) {
			Matrix.RotationYawPitchRollToRef(0, 0, Math.PI * .5, mat2);
            mat2.multiplyToRef(mat1, mat1);
			
			Matrix.RotationAxisToRef(this._bendAxis, angB, mat2);
			mat2.multiplyToRef(mat1, mat1);
		} 
		else {
			this._tmpVec1.copyFrom(this._bendAxis);
            this._tmpVec1.x *= -1;
			
			Matrix.RotationAxisToRef(this._tmpVec1, -angB, mat2);
			mat2.multiplyToRef(mat1, mat1);
		}
		
		if (this.poleAngle != 0) {
            Matrix.RotationAxisToRef(yaxis, this.poleAngle, mat2);
            mat1.multiplyToRef(mat2, mat1);
		}
		
		if (this.slerpAmount < 1) {
			if (!this._slerping) {
				Quaternion.FromRotationMatrixToRef(this._bone1Mat, this._bone1Quat);
			}
			
			Quaternion.FromRotationMatrixToRef(mat1, this._tmpQuat1);
			Quaternion.SlerpToRef(this._bone1Quat, this._tmpQuat1, this.slerpAmount, this._bone1Quat);
			angC = this._bone2Ang * (1.0 - this.slerpAmount) + angC * this.slerpAmount;
			this._bone1.setRotationQuaternion(this._bone1Quat, Space.WORLD, this.mesh);
			this._slerping = true;
		} 
		else {
			this._bone1.setRotationMatrix(mat1, Space.WORLD, this.mesh);
			this._bone1Mat.copyFrom(mat1);
			this._slerping = false;
		}
		
		this._bone2.setAxisAngle(this._bendAxis, angC, Space.LOCAL);
		this._bone2Ang = angC;
	}
	
}
