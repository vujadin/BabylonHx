package com.babylonhx.bones;

import com.babylonhx.math.Axis;
import com.babylonhx.math.Space;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.mesh.AbstractMesh;


/**
 * ...
 * @author Krtolica Vujadin
 */
class BoneLookController {

	private static var _tmpVecs:Array<Vector3> = [Vector3.Zero(), Vector3.Zero(), Vector3.Zero(),Vector3.Zero(), Vector3.Zero(), Vector3.Zero(), Vector3.Zero(), Vector3.Zero(), Vector3.Zero(), Vector3.Zero()];
	private static var _tmpQuat:Quaternion = Quaternion.Identity();
	private static var _tmpMats:Array<Matrix> = [Matrix.Identity(), Matrix.Identity(), Matrix.Identity(), Matrix.Identity(), Matrix.Identity()];
	
	/**
	 * The target Vector3 that the bone will look at.
	 */
	public var target:Vector3;

	/**
	 * The mesh that the bone is attached to.
	 */
	public var mesh:AbstractMesh;

	/**
	 * The bone that will be looking to the target.
	 */
	public var bone:Bone;

	/**
	 * The up axis of the coordinate system that is used when the bone is rotated.
	 */
	public var upAxis:Vector3 = Vector3.Up();

	/**
	 * The space that the up axis is in - BABYLON.Space.BONE, BABYLON.Space.LOCAL (default), or BABYLON.Space.WORLD.
	 */
	public var upAxisSpace:Int = Space.LOCAL;

	/**
	 * Used to make an adjustment to the yaw of the bone.
	 */
	public var adjustYaw:Float = 0;

	/**
	 * Used to make an adjustment to the pitch of the bone.
	 */
	public var adjustPitch:Float = 0;

	/**
	 * Used to make an adjustment to the roll of the bone.
	 */
	public var adjustRoll:Float = 0;

	/**
	 * The amount to slerp (spherical linear interpolation) to the target.  Set this to a value between 0 and 1 (a value of 1 disables slerp).
	 */
	public var slerpAmount:Float = 1;

	private var _minYaw:Float;
	private var _maxYaw:Float;
	private var _minPitch:Float;
	private var _maxPitch:Float;
	private var _minYawSin:Float;
	private var _minYawCos:Float;
	private var _maxYawSin:Float;
	private var _maxYawCos:Float;
	private var _midYawConstraint:Float;
	private var _minPitchTan:Float;
	private var _maxPitchTan:Float;
	
	private var _boneQuat:Quaternion = Quaternion.Identity();
	private var _slerping:Bool = false;
	private var _transformYawPitch:Matrix;
	private var _transformYawPitchInv:Matrix;
	private var _firstFrameSkipped:Bool = false;
	private var _yawRange:Float;
	private var _fowardAxis:Vector3 = Vector3.Forward();

	/**
	 * Get/set the minimum yaw angle that the bone can look to.
	 */
	public var minYaw(get, set):Float;
	inline function get_minYaw():Float {
		return this._minYaw;
	}
	function set_minYaw(value:Float):Float {
		this._minYaw = value;
		this._minYawSin = Math.sin(value);
		this._minYawCos = Math.cos(value);
		if (this._maxYaw != null){
			this._midYawConstraint = this._getAngleDiff(this._minYaw, this._maxYaw) * .5 + this._minYaw;
			this._yawRange = this._maxYaw - this._minYaw;
		}
		return value;
	}

	/**
	 * Get/set the maximum yaw angle that the bone can look to.
	 */
	public var maxYaw(get, set):Float;
	inline function get_maxYaw():Float {
		return this._maxYaw;
	}
	function set_maxYaw(value:Float):Float {
		this._maxYaw = value;
		this._maxYawSin = Math.sin(value);
		this._maxYawCos = Math.cos(value);
		if(this._minYaw != null){
			this._midYawConstraint = this._getAngleDiff(this._minYaw, this._maxYaw) * .5 + this._minYaw;
			this._yawRange = this._maxYaw - this._minYaw;
		}
		return value;
	}

	/**
	 * Get/set the minimum pitch angle that the bone can look to.
	 */
	public var minPitch(get, set):Float;
	inline function get_minPitch():Float {
		return this._minPitch;
	}
	inline function set_minPitch(value:Float):Float {
		this._minPitch = value;
		this._minPitchTan = Math.tan(value);
	}

	/**
	 * Get/set the maximum pitch angle that the bone can look to.
	 */
	public var maxPitch(get, set):Float;
	inline function get_maxPitch():Float {
		return this._maxPitch;
	}
	inline function set_maxPitch(value:Float):Float {
		this._maxPitch = value;
		this._maxPitchTan = Math.tan(value);
	}

	/**
	 * Create a BoneLookController
	 * @param mesh the mesh that the bone belongs to
	 * @param bone the bone that will be looking to the target
	 * @param target the target Vector3 to look at
	 * @param settings optional settings:
	 * - maxYaw:Float - the maximum angle the bone will yaw to
	 * - minYaw:Float - the minimum angle the bone will yaw to
	 * - maxPitch:Float - the maximum angle the bone will pitch to
	 * - minPitch:Float - the minimum angle the bone will yaw to
	 * - slerpAmount:Float - set the between 0 and 1 to make the bone slerp to the target.
	 * - upAxis:Vector3 - the up axis of the coordinate system
	 * - upAxisSpace:Int - the space that the up axis is in - BABYLON.Space.BONE, BABYLON.Space.LOCAL (default), or BABYLON.Space.WORLD.
	 * - yawAxis:Vector3 - set yawAxis if the bone does not yaw on the y axis
	 * - pitchAxis:Vector3 - set pitchAxis if the bone does not pitch on the x axis
	 * - adjustYaw:Float - used to make an adjustment to the yaw of the bone
	 * - adjustPitch:Float - used to make an adjustment to the pitch of the bone
	 * - adjustRoll:Float - used to make an adjustment to the roll of the bone
	 **/
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
			
			if (options.maxYaw != null) {
				this.maxYaw = options.maxYaw;
			}
			else {
				this.maxYaw = Math.PI;
			}
			
			if (options.minYaw != null) {
				this.minYaw = options.minYaw;
			} 
			else {
				this.minYaw = -Math.PI;
			}
			
			if (options.maxPitch != null) {
				this.maxPitch = options.maxPitch;
			}
			else {
				this.maxPitch = Math.PI;
			}
			
			if (options.minPitch != null) {
				this.minPitch = options.minPitch;
			} 
			else {
				this.minPitch = -Math.PI;
			}
			
			if (options.slerpAmount != null) {
				this.slerpAmount = options.slerpAmount;
			}
			
			if (options.upAxis != null) {
				this.upAxis = options.upAxis;
			}
			
			if (options.upAxisSpace != null) {
				this.upAxisSpace = options.upAxisSpace;
			}
			
			if (options.yawAxis != null || options.pitchAxis != null) {
				var newYawAxis = Axis.Y;
				var newPitchAxis = Axis.X;
				
				if (options.yawAxis != null) {
					newYawAxis = options.yawAxis.clone();
					newYawAxis.normalize();
				}
				
				if (options.pitchAxis != null) {
					newPitchAxis = options.pitchAxis.clone();
					newPitchAxis.normalize();
				}
				
				var newRollAxis = Vector3.Cross(newPitchAxis, newYawAxis);
				
				this._transformYawPitch = Matrix.Identity();
				Matrix.FromXYZAxesToRef(newPitchAxis, newYawAxis, newRollAxis, this._transformYawPitch);
				
				this._transformYawPitchInv = this._transformYawPitch.clone();
				this._transformYawPitch.invert();				
			}
		}
		
		if (bone.getParent() == null && this.upAxisSpace == Space.BONE) {
			this.upAxisSpace = Space.LOCAL;
		}
	}

	/**
	 * Update the bone to look at the target.  This should be called before the scene is rendered (use scene.registerBeforeRender()).
	 */
	public function update() {
		//skip the first frame when slerping so that the mesh rotation is correct
		if (this.slerpAmount < 1 && !this._firstFrameSkipped) {
			this._firstFrameSkipped = true;
			return;
		}
		
		var bone = this.bone;
		var bonePos = BoneLookController._tmpVecs[0];
		bone.getAbsolutePositionToRef(this.mesh, bonePos);
		
		var target = this.target;
		var _tmpMat1 = BoneLookController._tmpMats[0];
		var _tmpMat2 = BoneLookController._tmpMats[1];
		
		var mesh = this.mesh;
		var parentBone = bone.getParent();
		
		var upAxis = BoneLookController._tmpVecs[1];
		upAxis.copyFrom(this.upAxis);
		
		if(this.upAxisSpace == Space.BONE && parentBone != null) {
			if (this._transformYawPitch != null) {
				Vector3.TransformCoordinatesToRef(upAxis, this._transformYawPitchInv, upAxis);
			}
			parentBone.getDirectionToRef(upAxis, this.mesh, upAxis);
		}
		else if (this.upAxisSpace == Space.LOCAL) {
			mesh.getDirectionToRef(upAxis, upAxis);
			if (mesh.scaling.x != 1 || mesh.scaling.y != 1 || mesh.scaling.z != 1) {
				upAxis.normalize();
			}
		}
		
		var checkYaw:Bool = false;
		var checkPitch:Bool = false;
		
		if (this._maxYaw != Math.PI || this._minYaw != -Math.PI) {
			checkYaw = true;
		}
		if (this._maxPitch != Math.PI || this._minPitch != -Math.PI) {
			checkPitch = true;
		}
		
		if (checkYaw || checkPitch) {
			var spaceMat = BoneLookController._tmpMats[2];
			var spaceMatInv = BoneLookController._tmpMats[3];
			
			if (this.upAxisSpace == Space.BONE && upAxis.y == 1 && parentBone) {
				parentBone.getRotationMatrixToRef(Space.WORLD, this.mesh, spaceMat);				
			}
			else if (this.upAxisSpace == Space.LOCAL && upAxis.y == 1 && !parentBone) {
				spaceMat.copyFrom(mesh.getWorldMatrix());
			}
			else {
				var forwardAxis = BoneLookController._tmpVecs[2];
				forwardAxis.copyFrom(this._fowardAxis);
				
				if (this._transformYawPitch != null) {
					Vector3.TransformCoordinatesToRef(forwardAxis, this._transformYawPitchInv, forwardAxis);
				}
				
				if (parentBone != null) {
					parentBone.getDirectionToRef(forwardAxis, this.mesh, forwardAxis);
				}
				else {
					mesh.getDirectionToRef(forwardAxis, forwardAxis);
				}
				
				var rightAxis = Vector3.Cross(upAxis, forwardAxis);
				rightAxis.normalize();
				var forwardAxis = Vector3.Cross(rightAxis, upAxis);
				
				Matrix.FromXYZAxesToRef(rightAxis, upAxis, forwardAxis, spaceMat);				
			}
			
			spaceMat.invertToRef(spaceMatInv);
			
			var xzlenSet:Bool = false;	// BHX
			var xzlen:Float = 0;
			
			if (checkPitch) {
				var localTarget = BoneLookController._tmpVecs[3];
				target.subtractToRef(bonePos, localTarget);
				Vector3.TransformCoordinatesToRef(localTarget, spaceMatInv, localTarget);
				
				xzlenSet = true;
				xzlen = Math.sqrt(localTarget.x * localTarget.x + localTarget.z * localTarget.z);
				var pitch = Math.atan2(localTarget.y, xzlen);
				var newPitch = pitch;
				
				if (pitch > this._maxPitch) {
					localTarget.y = this._maxPitchTan * xzlen;
					newPitch = this._maxPitch;
				}
				else if (pitch < this._minPitch) {
					localTarget.y = this._minPitchTan * xzlen;
					newPitch = this._minPitch;
				}
				
				if (pitch != newPitch) {
					Vector3.TransformCoordinatesToRef(localTarget, spaceMat, localTarget);
					localTarget.addInPlace(bonePos);
					target = localTarget;
				}
			}
			
			if (checkYaw) {
				var localTarget = BoneLookController._tmpVecs[4];
				target.subtractToRef(bonePos, localTarget);
				Vector3.TransformCoordinatesToRef(localTarget, spaceMatInv, localTarget);
				
				var yaw = Math.atan2(localTarget.x, localTarget.z);
				var newYaw = yaw;
				
				if (yaw > this._maxYaw || yaw < this._minYaw) {					
					if (xzlenSet == false) {
						xzlen = Math.sqrt(localTarget.x * localTarget.x + localTarget.z * localTarget.z);
					}
					
					if (this._yawRange > Math.PI) {
						if (this._isAngleBetween(yaw, this._maxYaw, this._midYawConstraint)) {
							localTarget.z = this._maxYawCos * xzlen;
							localTarget.x = this._maxYawSin * xzlen;
							newYaw = this._maxYaw;
						}
						else if (this._isAngleBetween(yaw, this._midYawConstraint, this._minYaw)) {
							localTarget.z = this._minYawCos * xzlen;
							localTarget.x = this._minYawSin * xzlen;
							newYaw = this._minYaw;
						}
					}
					else {
						if (yaw > this._maxYaw) {
							localTarget.z = this._maxYawCos * xzlen;
							localTarget.x = this._maxYawSin * xzlen;
							newYaw = this._maxYaw;
						}
						else if (yaw < this._minYaw) {
							localTarget.z = this._minYawCos * xzlen;
							localTarget.x = this._minYawSin * xzlen;
							newYaw = this._minYaw;
						}
					}
				}
				
				if (this._slerping && this._yawRange > Math.PI){
					//are we going to be crossing into the min/max region?
					var boneFwd = BoneLookController._tmpVecs[8];
					boneFwd.copyFrom(Axis.Z);
					if (this._transformYawPitch != null) {
						Vector3.TransformCoordinatesToRef(boneFwd, this._transformYawPitchInv, boneFwd);
					}
					
					var boneRotMat = BoneLookController._tmpMats[4];
					this._boneQuat.toRotationMatrix(boneRotMat);
					this.mesh.getWorldMatrix().multiplyToRef(boneRotMat, boneRotMat);
					Vector3.TransformCoordinatesToRef(boneFwd, boneRotMat, boneFwd);
					Vector3.TransformCoordinatesToRef(boneFwd, spaceMatInv, boneFwd);
					
					var boneYaw = Math.atan2(boneFwd.x, boneFwd.z);
					var angBtwTar = this._getAngleBetween(boneYaw, yaw);
					var angBtwMidYaw = this._getAngleBetween(boneYaw, this._midYawConstraint);
					
					if (angBtwTar > angBtwMidYaw) {
						if (xzlen == false) {
							xzlen = Math.sqrt(localTarget.x * localTarget.x + localTarget.z * localTarget.z);
						}
						
						var angBtwMax = this._getAngleBetween(boneYaw, this._maxYaw);
						var angBtwMin = this._getAngleBetween(boneYaw, this._minYaw);
						
						if (angBtwMin < angBtwMax) {
							newYaw = boneYaw + Math.PI * .75;
							localTarget.z = Math.cos(newYaw) * xzlen;
							localTarget.x = Math.sin(newYaw) * xzlen;
						}
						else {
							newYaw = boneYaw-Math.PI*.75;
							localTarget.z = Math.cos(newYaw) * xzlen;
							localTarget.x = Math.sin(newYaw) * xzlen;
						}
					}
				}
				
				if (yaw != newYaw) {
					Vector3.TransformCoordinatesToRef(localTarget, spaceMat, localTarget);
					localTarget.addInPlace(bonePos);
					target = localTarget;
				}
			}
		}
		
		var zaxis = BoneLookController._tmpVecs[5];
		var xaxis = BoneLookController._tmpVecs[6];
		var yaxis = BoneLookController._tmpVecs[7];
		var _tmpQuat = BoneLookController._tmpQuat;
		
		target.subtractToRef(bonePos, zaxis);
		zaxis.normalize();
		Vector3.CrossToRef(upAxis, zaxis, xaxis);
		xaxis.normalize();
		Vector3.CrossToRef(zaxis, xaxis, yaxis);
		yaxis.normalize();
		Matrix.FromXYZAxesToRef(xaxis, yaxis, zaxis, _tmpMat1);
		
		if (xaxis.x == 0 && xaxis.y == 0 && xaxis.z == 0) {
			return;
		}
		
		if (yaxis.x == 0 && yaxis.y == 0 && yaxis.z == 0) {
			return;
		}
		
		if (zaxis.x == 0 && zaxis.y == 0 && zaxis.z == 0) {
			return;
		}
		
		if (this.adjustYaw != 0 || this.adjustPitch != 0 || this.adjustRoll != 0) {
			Matrix.RotationYawPitchRollToRef(this.adjustYaw, this.adjustPitch, this.adjustRoll, _tmpMat2);
			_tmpMat2.multiplyToRef(_tmpMat1, _tmpMat1);
		}
		
		if (this.slerpAmount < 1) {
			if (!this._slerping) {
				this.bone.getRotationQuaternionToRef(Space.WORLD, this.mesh, this._boneQuat);
			}
			if(this._transformYawPitch){
				this._transformYawPitch.multiplyToRef(_tmpMat1, _tmpMat1);
			}
			Quaternion.FromRotationMatrixToRef(_tmpMat1, _tmpQuat);
			Quaternion.SlerpToRef(this._boneQuat, _tmpQuat, this.slerpAmount, this._boneQuat);
			
			this.bone.setRotationQuaternion(this._boneQuat, Space.WORLD, this.mesh);
			this._slerping = true;
		} 
		else {
			if (this._transformYawPitch) {
				this._transformYawPitch.multiplyToRef(_tmpMat1, _tmpMat1);
			}
			this.bone.setRotationMatrix(_tmpMat1, Space.WORLD, this.mesh);
			this._slerping = false;
		}
	}

	private function _getAngleDiff(ang1:Float, ang2:Float):Float {
		var angDiff = ang2 - ang1;
		angDiff %= Math.PI * 2;
		
		if (angDiff > Math.PI) {
			angDiff -= Math.PI * 2;
		}
		else if (angDiff < -Math.PI) {
			angDiff += Math.PI * 2;
		}
		
		return angDiff;
	}

	private function _getAngleBetween(ang1:Float, ang2:Float):Float {
		ang1 %= (2 * Math.PI);
		ang1 = (ang1 < 0) ? ang1 + (2 * Math.PI) : ang1;
		
		ang2 %= (2 * Math.PI);
		ang2 = (ang2 < 0) ? ang2 + (2 * Math.PI) : ang2;
		
		var ab:Float = 0;
		
		if (ang1 < ang2) {
			ab = ang2 - ang1;
		}
		else {
			ab = ang1 - ang2;
		}
		
		if (ab > Math.PI) {
			ab = Math.PI * 2 - ab;
		}
		
		return ab;
	}

	private function _isAngleBetween(ang:Float, ang1:Float, ang2:Float):Bool {
		ang %= (2 * Math.PI);
		ang = (ang < 0) ? ang + (2 * Math.PI) : ang;
		ang1 %= (2 * Math.PI);
		ang1 = (ang1 < 0) ? ang1 + (2 * Math.PI) : ang1;
		ang2 %= (2 * Math.PI);
		ang2 = (ang2 < 0) ? ang2 + (2 * Math.PI) : ang2;
		
		if (ang1 < ang2) {
			if (ang > ang1 && ang < ang2) {
				return true;
			}
		}
		else {
			if (ang > ang2 && ang < ang1) {
				return true;
			}
		}
		return false;
	}
	
}
