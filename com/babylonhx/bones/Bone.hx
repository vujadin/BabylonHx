package com.babylonhx.bones;

import com.babylonhx.animations.IAnimatable;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Tmp;
import com.babylonhx.math.Space;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.AnimationRange;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Bone') class Bone extends Node implements IAnimatable {
	
	private static var _tmpVecs:Array<Vector3> = [Vector3.Zero(), Vector3.Zero()];
    private static var _tmpQuat:Quaternion = Quaternion.Identity();
    private static var _tmpMats:Array<Matrix> = [Matrix.Identity(), Matrix.Identity(), Matrix.Identity(), Matrix.Identity(), Matrix.Identity()];
	
	public var children:Array<Bone> = [];
	public var length:Int = -1;
	
	// Set this value to map this bone to a different index in the transform matrices.
	// Set this value to -1 to exclude the bone from the transform matrices.
	public var _index:Null<Int> = null;

	private var _skeleton:Skeleton;
	private var _localMatrix:Matrix;
	private var _restPose:Matrix;
	private var _baseMatrix:Matrix;
	private var _worldTransform:Matrix = new Matrix();
	private var _absoluteTransform:Matrix = new Matrix();
	private var _invertedAbsoluteTransform:Matrix = new Matrix();
	private var _parent:Bone;
	
	private var _scaleMatrix:Matrix = Matrix.Identity();
	private var _scaleVector:Vector3 = Vector3.One();
	private var _negateScaleChildren:Vector3 = Vector3.One();
	private var _scalingDeterminant:Float = 1;
	
	public var _matrix(get, set):Matrix;
	inline public function get__matrix():Matrix {
		return this._localMatrix;
	}
	public function set__matrix(val:Matrix):Matrix {
		if (this._localMatrix != null) {
			this._localMatrix.copyFrom(val);
		} 
		else {
			this._localMatrix = val;
		}
		return val;
	}

	
	public function new(name:String, skeleton:Skeleton, parentBone:Bone = null, ?localMatrix:Matrix, ?restPose:Matrix, ?baseMatrix:Matrix, ?index:Int) {
		super(name, skeleton.getScene());
		
		this._skeleton = skeleton;
		this._localMatrix = localMatrix != null ? localMatrix : Matrix.Identity();
		this._restPose = restPose != null ? restPose : this._localMatrix.clone();
		this._baseMatrix = baseMatrix != null ? baseMatrix : this._localMatrix.clone();
		this._index = index;
		
		skeleton.bones.push(this);
		
		this.setParent(parentBone, false);
		
		this._updateDifferenceMatrix();
	}

	// Members
	inline public function getSkeleton():Skeleton {
        return this._skeleton;
    }
 
	inline public function getParent():Bone {
		return this._parent;
	}
	
	public function setParent(parent:Bone, updateDifferenceMatrix:Bool = true) {
		if (this._parent == parent) {
			return;
		}
		
		if (this._parent != null) {
			var index = this._parent.children.indexOf(this);
			if (index != -1) {
				this._parent.children.splice(index, 1);
			}
		}
		
		this._parent = parent;
		
		if (this._parent != null) {
			this._parent.children.push(this);
		}
		
		if (updateDifferenceMatrix) {
			this._updateDifferenceMatrix();
		}
	}
	
	override public function getClassName():String {
		return "Bone";
	}

	inline public function getLocalMatrix():Matrix {
		return this._localMatrix;
	}

	inline public function getBaseMatrix():Matrix {
		return this._baseMatrix;
	}
	
	inline public function getRestPose():Matrix {
		return this._restPose;
	}
	
	inline public function returnToRest() {
		this.updateMatrix(this._restPose.clone());
	}

	override public function getWorldMatrix():Matrix {
		return this._worldTransform;
	}	
	
	inline public function getInvertedAbsoluteTransform():Matrix {
		return this._invertedAbsoluteTransform;
	}
	
	inline public function getAbsoluteTransform():Matrix {
		return this._absoluteTransform;
	}
	
	// Properties (matches AbstractMesh properties)
	public var position(get, set):Vector3;
	inline private function get_position():Vector3 {
		return this.getPosition();
	}
	inline private function set_position(newPosition:Vector3):Vector3 {
		this.setPosition(newPosition);
		return newPosition;
	}

	public var rotation(get, set):Vector3;
	inline private function get_rotation():Vector3 {
		return this.getRotation();
	}
	inline private function set_rotation(newRotation:Vector3):Vector3 {
		this.setRotation(newRotation);
		return newRotation;
	}

	public var rotationQuaternion(get, set):Quaternion;
	inline private function get_rotationQuaternion():Quaternion {
		return this.getRotationQuaternion();
	}
	inline private function set_rotationQuaternion(newRotation:Quaternion):Quaternion {
		this.setRotationQuaternion(newRotation);
		return newRotation;
	}

	public var scaling(get, set):Vector3;
	inline private function get_scaling():Vector3 {
		return this.getScale();
	}
	inline private function set_scaling(newScaling:Vector3):Vector3 {
		this.setScale(newScaling.x, newScaling.y, newScaling.z);
		return newScaling;
	}

	// Methods
	public function updateMatrix(matrix:Matrix, updateDifferenceMatrix:Bool = true) {
		this._baseMatrix = matrix.clone();
		this._localMatrix = matrix.clone();
		
		this._skeleton._markAsDirty();
		
		if (updateDifferenceMatrix) {
			this._updateDifferenceMatrix();
		}
	}

	@:allow(com.babylonhx.bones.Skeleton)
	private function _updateDifferenceMatrix(?rootMatrix:Matrix) {
		if (rootMatrix == null) {
			rootMatrix = this._baseMatrix;
		}
		
		if (this._parent != null) {
			rootMatrix.multiplyToRef(this._parent._absoluteTransform, this._absoluteTransform);
		} 
		else {
			this._absoluteTransform.copyFrom(rootMatrix);
		}
		
		this._absoluteTransform.invertToRef(this._invertedAbsoluteTransform);
		
		for (index in 0...this.children.length) {
			this.children[index]._updateDifferenceMatrix();
		}
		
		this._scalingDeterminant = (this._absoluteTransform.determinant() < 0 ? -1 : 1);
	}

	inline public function markAsDirty() {
		this._currentRenderId++;
		this._skeleton._markAsDirty();
	}
	
	public function copyAnimationRange(source:Bone, rangeName:String, frameOffset:Int, rescaleAsRequired:Bool = false, skelDimensionsRatio:Vector3 = null):Bool {
		// all animation may be coming from a library skeleton, so may need to create animation
		if (this.animations.length == 0){
			this.animations.push(new Animation(this.name, "_matrix", source.animations[0].framePerSecond, Animation.ANIMATIONTYPE_MATRIX, 0)); 
			this.animations[0].setKeys([{ frame: 0, value: 0 }]);
		}
		
		// get animation info / verify there is such a range from the source bone
		var sourceRange:AnimationRange = source.animations[0].getRange(rangeName);
		if (sourceRange == null) {
			return false;
		}
		
		var from = sourceRange.from;
		var to = sourceRange.to;
		var sourceKeys = source.animations[0].getKeys();
		
		// rescaling prep
		var sourceBoneLength = source.length;
		var sourceParent = source.getParent();
		var parent = this.getParent();
		var parentScalingReqd = rescaleAsRequired && sourceParent != null && sourceBoneLength > 0 && this.length > 0 && sourceBoneLength != this.length;
		var parentRatio = parentScalingReqd ? parent.length / sourceParent.length : null;
		
		var dimensionsScalingReqd = rescaleAsRequired && parent == null && skelDimensionsRatio != null && (skelDimensionsRatio.x != 1 || skelDimensionsRatio.y != 1 || skelDimensionsRatio.z != 1);           
		
		var destKeys = this.animations[0].getKeys();
		
		// loop vars declaration
		var orig:BabylonFrame = null;
		var origTranslation:Vector3;
		var mat:Matrix = null;
		
		for (key in 0...sourceKeys.length) {
			orig = sourceKeys[key];
			if (orig.frame >= from  && orig.frame <= to) {
				if (rescaleAsRequired) {
					mat = orig.value.clone();
					
					// scale based on parent ratio, when bone has parent
					if (parentScalingReqd) {
						origTranslation = mat.getTranslation();
						mat.setTranslation(origTranslation.scaleInPlace(parentRatio));					
					} // scale based on skeleton dimension ratio when root bone, and value is passed
					else if (dimensionsScalingReqd) {
						origTranslation = mat.getTranslation();
						mat.setTranslation(origTranslation.multiplyInPlace(skelDimensionsRatio)); 
					} // use original when root bone, and no data for skelDimensionsRatio
					else {
						mat = orig.value;                            
					}
				}
				else {
					mat = orig.value;
				}
				
				destKeys.push( { frame: orig.frame + frameOffset, value: mat } );
			}
		}
		this.animations[0].createRange(rangeName, from + frameOffset, to + frameOffset);
		
		return true;
	}
	
	/**
	 * Translate the bone in local or world space.
	 * @param vec The amount to translate the bone.
	 * @param space The space that the translation is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	public function translate(vec:Vector3, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		var lm = this.getLocalMatrix();
		
		if (space == Space.LOCAL) {
			lm.m[12] += vec.x;
			lm.m[13] += vec.y;
			lm.m[14] += vec.z;
		}
		else {
			var wm:Matrix = null;
			
			//mesh.getWorldMatrix() needs to be called before skeleton.computeAbsoluteTransforms()
			if (mesh != null){
				wm = mesh.getWorldMatrix();
			}
			
			this._skeleton.computeAbsoluteTransforms();
			var tmat = Bone._tmpMats[0];
			var tvec = Bone._tmpVecs[0];
			
			if (mesh != null) {
				tmat.copyFrom(this._parent.getAbsoluteTransform());
				tmat.multiplyToRef(wm, tmat);
			}
			else {
				tmat.copyFrom(this._parent.getAbsoluteTransform());
			}
			
			tmat.m[12] = 0;
			tmat.m[13] = 0;
			tmat.m[14] = 0;
			
			tmat.invert();
			Vector3.TransformCoordinatesToRef(vec, tmat, tvec);
			
			lm.m[12] += tvec.x;
			lm.m[13] += tvec.y;
			lm.m[14] += tvec.z;
		}
		
		this.markAsDirty();		
	}

	/**
	 * Set the postion of the bone in local or world space.
	 * @param position The position to set the bone.
	 * @param space The space that the position is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	public function setPosition(position:Vector3, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		var lm = this.getLocalMatrix();
		
		if (space == Space.LOCAL) {
			lm.m[12] = position.x;
			lm.m[13] = position.y;
			lm.m[14] = position.z;
		} 
		else {
			var wm:Matrix = null;
			
			//mesh.getWorldMatrix() needs to be called before skeleton.computeAbsoluteTransforms()
			if (mesh != null) {
				wm = mesh.getWorldMatrix();
			}
			
			this._skeleton.computeAbsoluteTransforms();
			
			var tmat = Bone._tmpMats[0];
			var vec = Bone._tmpVecs[0];
			
			if (mesh != null) {
				tmat.copyFrom(this._parent.getAbsoluteTransform());
				tmat.multiplyToRef(wm, tmat);
			}
			else {
				tmat.copyFrom(this._parent.getAbsoluteTransform());
			}
			
			tmat.invert();
			Vector3.TransformCoordinatesToRef(position, tmat, vec);
			
			lm.m[12] = vec.x;
			lm.m[13] = vec.y;
			lm.m[14] = vec.z;
		}
		
		this.markAsDirty();
	}

	/**
	 * Set the absolute postion of the bone (world space).
	 * @param position The position to set the bone.
	 * @param mesh The mesh that this bone is attached to.
	 */
	public function setAbsolutePosition(position:Vector3, ?mesh:AbstractMesh) {
		this.setPosition(position, Space.WORLD, mesh);	
	}
	
	/**
	 * Set the scale of the bone on the x, y and z axes.
	 * @param x The scale of the bone on the x axis.
	 * @param x The scale of the bone on the y axis.
	 * @param z The scale of the bone on the z axis.
	 * @param scaleChildren Set this to true if children of the bone should be scaled.
	 */
	public function setScale(x:Float, y:Float, z:Float, scaleChildren:Bool = false) {
		if (this.animations[0] != null && !this.animations[0].hasRunningRuntimeAnimations) {
            if (!scaleChildren) {
                this._negateScaleChildren.x = 1 / x;
                this._negateScaleChildren.y = 1 / y;
                this._negateScaleChildren.z = 1 / z;
            }
			
            this._syncScaleVector();
        }
		
		this.scale(x / this._scaleVector.x, y / this._scaleVector.y, z / this._scaleVector.z, scaleChildren);
	}

	/**
	 * Scale the bone on the x, y and z axes. 
	 * @param x The amount to scale the bone on the x axis.
	 * @param x The amount to scale the bone on the y axis.
	 * @param z The amount to scale the bone on the z axis.
	 * @param scaleChildren Set this to true if children of the bone should be scaled.
	 */
	public function scale(x:Float, y:Float, z:Float, scaleChildren:Bool = false) {
		var locMat = this.getLocalMatrix();
		var origLocMat = Bone._tmpMats[0];
		origLocMat.copyFrom(locMat);
		
		var origLocMatInv = Bone._tmpMats[1];
		origLocMatInv.copyFrom(origLocMat);
		origLocMatInv.invert();
		
		var scaleMat = Bone._tmpMats[2];
		Matrix.FromValuesToRef(x, 0, 0, 0, 0, y, 0, 0, 0, 0, z, 0, 0, 0, 0, 1, scaleMat);
		this._scaleMatrix.multiplyToRef(scaleMat, this._scaleMatrix);
		this._scaleVector.x *= x;
		this._scaleVector.y *= y;
		this._scaleVector.z *= z;
		
		locMat.multiplyToRef(origLocMatInv, locMat);
		locMat.multiplyToRef(scaleMat, locMat);
		locMat.multiplyToRef(origLocMat, locMat);
		
		var parent = this.getParent();
		
		if (parent != null) {
			locMat.multiplyToRef(parent.getAbsoluteTransform(), this.getAbsoluteTransform());
		}
		else {
			this.getAbsoluteTransform().copyFrom(locMat);
		}
		
		var len = this.children.length;
		
		scaleMat.invert();
		
		for (i in 0...len) {
			var child = this.children[i];
			var cm = child.getLocalMatrix();
			cm.multiplyToRef(scaleMat, cm);
			var lm = child.getLocalMatrix();
			lm.m[12] *= x;
			lm.m[13] *= y;
			lm.m[14] *= z;
		}
		
		this.computeAbsoluteTransforms();
		
		if (scaleChildren) {
			for (i in 0...len) {
				this.children[i].scale(x, y, z, scaleChildren);				
			}
		} 
		
		this.markAsDirty();
	}

	/**
	 * Set the yaw, pitch, and roll of the bone in local or world space.
	 * @param yaw The rotation of the bone on the y axis.
	 * @param pitch The rotation of the bone on the x axis.
	 * @param roll The rotation of the bone on the z axis.
	 * @param space The space that the axes of rotation are in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	public function setYawPitchRoll(yaw:Float, pitch:Float, roll:Float, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		var rotMat = Bone._tmpMats[0];
		Matrix.RotationYawPitchRollToRef(yaw, pitch, roll, rotMat);
		
		var rotMatInv = Bone._tmpMats[1];
		
		this._getNegativeRotationToRef(rotMatInv, space, mesh);
		
		rotMatInv.multiplyToRef(rotMat, rotMat);
		
		this._rotateWithMatrix(rotMat, space, mesh);		
	}

	/**
	 * Rotate the bone on an axis in local or world space.
	 * @param axis The axis to rotate the bone on.
	 * @param amount The amount to rotate the bone.
	 * @param space The space that the axis is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	public function rotate(axis:Vector3, amount:Float, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {		
		var rmat = Bone._tmpMats[0];
		rmat.m[12] = 0;
		rmat.m[13] = 0;
		rmat.m[14] = 0;
		
		Matrix.RotationAxisToRef(axis, amount, rmat);
		
		this._rotateWithMatrix(rmat, space, mesh);		
	}

	/**
	 * Set the rotation of the bone to a particular axis angle in local or world space.
	 * @param axis The axis to rotate the bone on.
	 * @param angle The angle that the bone should be rotated to.
	 * @param space The space that the axis is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	public function setAxisAngle(axis:Vector3, angle:Float, space:Int, ?mesh:AbstractMesh) {
		var rotMat = Bone._tmpMats[0];
		Matrix.RotationAxisToRef(axis, angle, rotMat);
		var rotMatInv = Bone._tmpMats[1];
		
		this._getNegativeRotationToRef(rotMatInv, space, mesh);
		
		rotMatInv.multiplyToRef(rotMat, rotMat);
		this._rotateWithMatrix(rotMat, space, mesh);
	}
	
	/**
	 * Set the euler rotation of the bone in local of world space.
	 * @param rotation The euler rotation that the bone should be set to.
	 * @param space The space that the rotation is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	inline public function setRotation(rotation:Vector3, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		this.setYawPitchRoll(rotation.y, rotation.x, rotation.z, space, mesh);
	}
	
	/**
	 * Set the quaternion rotation of the bone in local of world space.
	 * @param quat The quaternion rotation that the bone should be set to.
	 * @param space The space that the rotation is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	public function setRotationQuaternion(quat:Quaternion, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		var rotMatInv = Bone._tmpMats[0];
		
		this._getNegativeRotationToRef(rotMatInv, space, mesh);
		
		var rotMat = Bone._tmpMats[1];
		Matrix.FromQuaternionToRef(quat, rotMat);
		
		rotMatInv.multiplyToRef(rotMat, rotMat);
		
		this._rotateWithMatrix(rotMat, space, mesh);
	}
	
	/**
	 * Set the rotation matrix of the bone in local of world space.
	 * @param rotMat The rotation matrix that the bone should be set to.
	 * @param space The space that the rotation is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 */
	public function setRotationMatrix(rotMat:Matrix, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		var rotMatInv = Bone._tmpMats[0];
		
		this._getNegativeRotationToRef(rotMatInv, space, mesh);
		
		var rotMat2 = Bone._tmpMats[1];
		rotMat2.copyFrom(rotMat);
		
		rotMatInv.multiplyToRef(rotMat, rotMat2);
		
		this._rotateWithMatrix(rotMat2, space, mesh);
	}

	private function _rotateWithMatrix(rmat:Matrix, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		var lmat = this.getLocalMatrix();
		var lx = lmat.m[12];
		var ly = lmat.m[13];
		var lz = lmat.m[14];
		var parent = this.getParent();
		var parentScale = Bone._tmpMats[3];
		var parentScaleInv = Bone._tmpMats[4];
		
		if (parent != null) {
			if (space == Space.WORLD) {
				if (mesh != null) {
					parentScale.copyFrom(mesh.getWorldMatrix());
					parent.getAbsoluteTransform().multiplyToRef(parentScale, parentScale);
				}
				else {
					parentScale.copyFrom(parent.getAbsoluteTransform());
				}
			}
			else {
				parentScale = parent._scaleMatrix;
			}
			parentScaleInv.copyFrom(parentScale);
			parentScaleInv.invert();
			lmat.multiplyToRef(parentScale, lmat);
			lmat.multiplyToRef(rmat, lmat);
			lmat.multiplyToRef(parentScaleInv, lmat);
		}
		else {
			if (space == Space.WORLD && mesh != null) {
				parentScale.copyFrom(mesh.getWorldMatrix());
				parentScaleInv.copyFrom(parentScale);
				parentScaleInv.invert();
				lmat.multiplyToRef(parentScale, lmat);
				lmat.multiplyToRef(rmat, lmat);
				lmat.multiplyToRef(parentScaleInv, lmat);
			}
			else {
				lmat.multiplyToRef(rmat, lmat);
			}
		}
		
		lmat.m[12] = lx;
		lmat.m[13] = ly;
		lmat.m[14] = lz;
		
		this.computeAbsoluteTransforms();
		
		this.markAsDirty();		
	}

	private function _getNegativeRotationToRef(rotMatInv:Matrix, space:Int = Space.LOCAL, ?mesh:AbstractMesh) {
		if (space == Space.WORLD) {
			var scaleMatrix = Bone._tmpMats[2];
			scaleMatrix.copyFrom(this._scaleMatrix);
			rotMatInv.copyFrom(this.getAbsoluteTransform());
			if (mesh != null) {
				rotMatInv.multiplyToRef(mesh.getWorldMatrix(), rotMatInv);
				var meshScale = Bone._tmpMats[3];
				Matrix.ScalingToRef(mesh.scaling.x, mesh.scaling.y, mesh.scaling.z, meshScale);
				scaleMatrix.multiplyToRef(meshScale, scaleMatrix);
			}
			
			rotMatInv.invert();
			scaleMatrix.m[0] *= this._scalingDeterminant;
			rotMatInv.multiplyToRef(scaleMatrix, rotMatInv);
		} 
		else {
			rotMatInv.copyFrom(this.getLocalMatrix());
			rotMatInv.invert();
			var scaleMatrix = Bone._tmpMats[2];
			scaleMatrix.copyFrom(this._scaleMatrix);
			if (this._parent != null) {
				var pscaleMatrix = Bone._tmpMats[3];
				pscaleMatrix.copyFrom(this._parent._scaleMatrix);
				pscaleMatrix.invert();
				pscaleMatrix.multiplyToRef(rotMatInv, rotMatInv);
			} 
			else {
				scaleMatrix.m[0] *= this._scalingDeterminant;
			}
			
			rotMatInv.multiplyToRef(scaleMatrix, rotMatInv);
		}
	}

	/**
	 * Get the scale of the bone
	 * @returns the scale of the bone
	 */
	inline public function getScale():Vector3 {		
		return this._scaleVector.clone();		
	}

	/**
	 * Copy the scale of the bone to a vector3.
	 * @param result The vector3 to copy the scale to
	 */
	inline public function getScaleToRef(result:Vector3) {
		result.copyFrom(this._scaleVector);		
	}
	
	/**
	 * Get the position of the bone in local or world space.
	 * @param space The space that the returned position is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @returns The position of the bone
	 */
	public function getPosition(space:Int = Space.LOCAL, ?mesh:AbstractMesh):Vector3 {
		var pos = Vector3.Zero();
		
		this.getPositionToRef(space, mesh, pos);
		
		return pos;
	}

	/**
	 * Copy the position of the bone to a vector3 in local or world space.
	 * @param space The space that the returned position is in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @param result The vector3 to copy the position to.
	 */
	public function getPositionToRef(space:Int = Space.LOCAL, mesh:AbstractMesh, result:Vector3) {
		if (space == Space.LOCAL) {
			var lm = this.getLocalMatrix();
			
			result.x = lm.m[12];
			result.y = lm.m[13];
			result.z = lm.m[14];
		} 
		else {			
			var wm:Matrix = null;
            
			//mesh.getWorldMatrix() needs to be called before skeleton.computeAbsoluteTransforms()
			if (mesh != null) {
				wm = mesh.getWorldMatrix();
			}
			
			this._skeleton.computeAbsoluteTransforms();
			
			var tmat = Bone._tmpMats[0];
			
			if (mesh != null) {
				tmat.copyFrom(this.getAbsoluteTransform());
				tmat.multiplyToRef(wm, tmat);
			}
			else {
				tmat = this.getAbsoluteTransform();
			}
			
			result.x = tmat.m[12];
			result.y = tmat.m[13];
			result.z = tmat.m[14];
		}
	}

	/**
	 * Get the absolute position of the bone (world space).
	 * @param mesh The mesh that this bone is attached to.
	 * @returns The absolute position of the bone
	 */
	public function getAbsolutePosition(?mesh:AbstractMesh):Vector3 {
		var pos = Vector3.Zero();
		
		this.getPositionToRef(Space.WORLD, mesh, pos);
		
		return pos;
	}

	/**
	 * Copy the absolute position of the bone (world space) to the result param.
	 * @param mesh The mesh that this bone is attached to.
	 * @param result The vector3 to copy the absolute position to.
	 */
	inline public function getAbsolutePositionToRef(mesh:AbstractMesh, result:Vector3) {
		this.getPositionToRef(Space.WORLD, mesh, result);
	}

	/**
	 * Compute the absolute transforms of this bone and its children.
	 */
	public function computeAbsoluteTransforms() {
		if (this._parent != null) {
			this._localMatrix.multiplyToRef(this._parent._absoluteTransform, this._absoluteTransform);
		} 
		else {
			this._absoluteTransform.copyFrom(this._localMatrix);
			
			var poseMatrix = this._skeleton.getPoseMatrix();
			
			if (poseMatrix != null) {
				this._absoluteTransform.multiplyToRef(poseMatrix, this._absoluteTransform);					
			}
		}
		
		var children = this.children;
		var len = children.length;
		
		for (i in 0...len) {
			children[i].computeAbsoluteTransforms();
		}
	}
	
	private function _syncScaleVector() {		
		var lm = this.getLocalMatrix();
		
		var xsq = (lm.m[0] * lm.m[0] + lm.m[1] * lm.m[1] + lm.m[2] * lm.m[2]);
		var ysq = (lm.m[4] * lm.m[4] + lm.m[5] * lm.m[5] + lm.m[6] * lm.m[6]);
		var zsq = (lm.m[8] * lm.m[8] + lm.m[9] * lm.m[9] + lm.m[10] * lm.m[10]);
		
		var xs = lm.m[0] * lm.m[1] * lm.m[2] * lm.m[3] < 0 ? -1 : 1;
		var ys = lm.m[4] * lm.m[5] * lm.m[6] * lm.m[7] < 0 ? -1 : 1;
		var zs = lm.m[8] * lm.m[9] * lm.m[10] * lm.m[11] < 0 ? -1 : 1;
		
		this._scaleVector.x = xs * Math.sqrt(xsq);
		this._scaleVector.y = ys * Math.sqrt(ysq);
		this._scaleVector.z = zs * Math.sqrt(zsq);
		
		if (this._parent != null) {
			this._scaleVector.x /= this._parent._negateScaleChildren.x;
			this._scaleVector.y /= this._parent._negateScaleChildren.y;
			this._scaleVector.z /= this._parent._negateScaleChildren.z;
		}
		
		Matrix.FromValuesToRef(this._scaleVector.x, 0, 0, 0, 0,  this._scaleVector.y, 0, 0, 0, 0,  this._scaleVector.z, 0, 0, 0, 0, 1, this._scaleMatrix);
	}
	
	/**
	 * Get the world direction from an axis that is in the local space of the bone.
	 * @param localAxis The local direction that is used to compute the world direction.
	 * @param mesh The mesh that this bone is attached to.
	 * @returns The world direction
	 */
	public function getDirection(localAxis:Vector3, ?mesh:AbstractMesh):Vector3 {
		var result = Vector3.Zero();
		
		this.getDirectionToRef(localAxis, mesh, result);
		
		return result;
	}

	/**
	 * Copy the world direction to a vector3 from an axis that is in the local space of the bone.
	 * @param localAxis The local direction that is used to compute the world direction.
	 * @param mesh The mesh that this bone is attached to.
	 * @param result The vector3 that the world direction will be copied to.
	 */
	public function getDirectionToRef(localAxis:Vector3, mesh:AbstractMesh, result:Vector3) {
		var wm:Matrix = null;
		
		//mesh.getWorldMatrix() needs to be called before skeleton.computeAbsoluteTransforms()
		if (mesh != null) {
			wm = mesh.getWorldMatrix();
		}
		
		this._skeleton.computeAbsoluteTransforms();
		
		var mat = Bone._tmpMats[0];
		
		mat.copyFrom(this.getAbsoluteTransform());
		
		if (mesh != null) {
			mat.multiplyToRef(wm, mat);
		}
		
		Vector3.TransformNormalToRef(localAxis, mat, result);
		
		result.normalize();
	}
	
	/**
	 * Get the euler rotation of the bone in local or world space.
	 * @param space The space that the rotation should be in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @returns The euler rotation
	 */
	public function getRotation(space:Int = Space.LOCAL, ?mesh:AbstractMesh):Vector3 {
		var result = Vector3.Zero();
		
		this.getRotationToRef(space, mesh, result);
		
		return result;
	}

	/**
	 * Copy the euler rotation of the bone to a vector3.  The rotation can be in either local or world space.
	 * @param space The space that the rotation should be in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @param result The vector3 that the rotation should be copied to.
	 */
	public function getRotationToRef(space:Int = Space.LOCAL, mesh:AbstractMesh, result:Vector3) {
		var quat = Bone._tmpQuat;
		
        this.getRotationQuaternionToRef(space, mesh, quat);
        
        quat.toEulerAnglesToRef(result);
	}
	
	/**
	 * Get the quaternion rotation of the bone in either local or world space.
	 * @param space The space that the rotation should be in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @returns The quaternion rotation
	 */
	public function getRotationQuaternion(space:Int = Space.LOCAL, ?mesh:AbstractMesh):Quaternion {
		var result = Quaternion.Identity();
		
		this.getRotationQuaternionToRef(space, mesh, result);
		
		return result;
	}

	/**
	 * Copy the quaternion rotation of the bone to a quaternion.  The rotation can be in either local or world space.
	 * @param space The space that the rotation should be in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @param result The quaternion that the rotation should be copied to.
	 */
	public function getRotationQuaternionToRef(space:Int = Space.LOCAL, mesh:AbstractMesh, result:Quaternion) {
		if (space == Space.LOCAL) {
			this.getLocalMatrix().decompose(Bone._tmpVecs[0], result, Bone._tmpVecs[1]);
		}
		else {
			var mat = Bone._tmpMats[0];
			var amat = this.getAbsoluteTransform();
			
			if (mesh != null) {
				amat.multiplyToRef(mesh.getWorldMatrix(), mat);
			} 
			else {
				mat.copyFrom(amat);
			}
			
			mat.m[0] *= this._scalingDeterminant;
			mat.m[1] *= this._scalingDeterminant;
			mat.m[2] *= this._scalingDeterminant;
			
			mat.decompose(Bone._tmpVecs[0], result, Bone._tmpVecs[1]);
		}
	}
	
	/**
	 * Get the rotation matrix of the bone in local or world space.
	 * @param space The space that the rotation should be in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @returns The rotation matrix
	 */
	public function getRotationMatrix(space:Int = Space.LOCAL, mesh:AbstractMesh):Matrix {
		var result = Matrix.Identity();
		
		this.getRotationMatrixToRef(space, mesh, result);
		
		return result;
	}

	/**
	 * Copy the rotation matrix of the bone to a matrix.  The rotation can be in either local or world space.
	 * @param space The space that the rotation should be in.
	 * @param mesh The mesh that this bone is attached to.  This is only used in world space.
	 * @param result The quaternion that the rotation should be copied to.
	 */
	public function getRotationMatrixToRef(space:Int = Space.LOCAL, mesh:AbstractMesh, result:Matrix) {
		if (space == Space.LOCAL) {
			this.getLocalMatrix().getRotationMatrixToRef(result);
		}
		else {
			var mat = Bone._tmpMats[0];
			var amat = this.getAbsoluteTransform();
			
			if (mesh != null) {
				amat.multiplyToRef(mesh.getWorldMatrix(), mat);
			} 
			else {
				mat.copyFrom(amat);
			}
			
			mat.m[0] *= this._scalingDeterminant;
			mat.m[1] *= this._scalingDeterminant;
			mat.m[2] *= this._scalingDeterminant;
			
			mat.getRotationMatrixToRef(result);
		}
	}
	
	/**
	 * Get the world position of a point that is in the local space of the bone.
	 * @param position The local position
	 * @param mesh The mesh that this bone is attached to.
	 * @returns The world position
	 */
	public function getAbsolutePositionFromLocal(position:Vector3, ?mesh:AbstractMesh):Vector3 {
		var result = Vector3.Zero();
		
		this.getAbsolutePositionFromLocalToRef(position, mesh, result);
		
		return result;
	}

	/**
	 * Get the world position of a point that is in the local space of the bone and copy it to the result param.
	 * @param position The local position
	 * @param mesh The mesh that this bone is attached to.
	 * @param result The vector3 that the world position should be copied to.
	 */
	public function getAbsolutePositionFromLocalToRef(position:Vector3, mesh:AbstractMesh, result:Vector3) {
		var wm:Matrix = null;
		
		//mesh.getWorldMatrix() needs to be called before skeleton.computeAbsoluteTransforms()
		if (mesh != null) {
			wm = mesh.getWorldMatrix();
		}
		
		this._skeleton.computeAbsoluteTransforms();
		
		var tmat = Bone._tmpMats[0];
		
		if (mesh != null) {
			tmat.copyFrom(this.getAbsoluteTransform());
			tmat.multiplyToRef(wm, tmat);
		} 
		else {
			tmat = this.getAbsoluteTransform();
		}
		
		Vector3.TransformCoordinatesToRef(position, tmat, result);
	}
	
	/**
	 * Get the local position of a point that is in world space.
	 * @param position The world position
	 * @param mesh The mesh that this bone is attached to.
	 * @returns The local position
	 */
	public function getLocalPositionFromAbsolute(position:Vector3, ?mesh:AbstractMesh):Vector3 {
		var result = Vector3.Zero();
		
		this.getLocalPositionFromAbsoluteToRef(position, mesh, result);
		
		return result;
	}

	/**
	 * Get the local position of a point that is in world space and copy it to the result param.
	 * @param position The world position
	 * @param mesh The mesh that this bone is attached to.
	 * @param result The vector3 that the local position should be copied to.
	 */
	public function getLocalPositionFromAbsoluteToRef(position:Vector3, mesh:AbstractMesh, result:Vector3) {
		var wm:Matrix = null;
		
		//mesh.getWorldMatrix() needs to be called before skeleton.computeAbsoluteTransforms()
		if (mesh != null) {
			wm = mesh.getWorldMatrix();
		}
		
		this._skeleton.computeAbsoluteTransforms();
		
		var tmat = Bone._tmpMats[0];
		
		tmat.copyFrom(this.getAbsoluteTransform());
		
		if (mesh != null) {
			tmat.multiplyToRef(wm, tmat);
		}
		
		tmat.invert();
		
		Vector3.TransformCoordinatesToRef(position, tmat, result);
	}
	
}
