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
	
	public var children:Array<Bone> = [];
	public var length:Int = -1;

	private var _skeleton:Skeleton;
	private var _matrix:Matrix;
	private var _restPose:Matrix;
	private var _baseMatrix:Matrix;
	private var _worldTransform:Matrix = new Matrix();
	private var _absoluteTransform:Matrix = new Matrix();
	private var _invertedAbsoluteTransform:Matrix = new Matrix();
	private var _parent:Bone;
	
	private var _scaleMatrix:Matrix = Matrix.Identity();
	private var _scaleVector:Vector3 = new Vector3(1, 1, 1);
	private var _negateScaleChildren = new Vector3(1, 1, 1);
	private var _scalingDeterminant:Float = 1;

	
	public function new(name:String, skeleton:Skeleton, parentBone:Bone = null, matrix:Matrix, ?restPose:Matrix) {
		super(name, skeleton.getScene());
		
		this._skeleton = skeleton;
		this._matrix = matrix;
		this._baseMatrix = matrix;
		this._restPose = restPose != null ? restPose : matrix.clone();
		
		skeleton.bones.push(this);
		
		if (parentBone != null) {
			this._parent = parentBone;
			parentBone.children.push(this);
		} 
		else {
			this._parent = null;
		}
		
		this._updateDifferenceMatrix();
		
		if (this.getAbsoluteTransform().determinant() < 0) {
            this._scalingDeterminant *= -1;
        }
	}

	// Members
	inline public function getParent():Bone {
		return this._parent;
	}

	inline public function getLocalMatrix():Matrix {
		return this._matrix;
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

	// Methods
	inline public function updateMatrix(matrix:Matrix, updateDifferenceMatrix:Bool = true) {
		this._baseMatrix = matrix.clone();
		this._matrix = matrix.clone();
		
		this._skeleton._markAsDirty();
		
		if (updateDifferenceMatrix) {
			this._updateDifferenceMatrix();
		}
	}

	@:allow(com.babylonhx.bones.Skeleton)
	inline private function _updateDifferenceMatrix(?rootMatrix:Matrix) {
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
	
	public function translate(vec:Vector3) {
		var lm = this.getLocalMatrix();
		
		lm.m[12] += vec.x;
		lm.m[13] += vec.y;
		lm.m[14] += vec.z;
		
		this.markAsDirty();		
	}

	public function setPosition(position:Vector3) {
		var lm = this.getLocalMatrix();
		
		lm.m[12] = position.x;
		lm.m[13] = position.y;
		lm.m[14] = position.z;
		
		this.markAsDirty();
	}

	public function setAbsolutePosition(position:Vector3, mesh:AbstractMesh = null) {
		this._skeleton.computeAbsoluteTransforms();
		
		var tmat = Tmp.matrix[0];
		var vec = Tmp.vector3[0];
		
		if (mesh != null) {
			tmat.copyFrom(this._parent.getAbsoluteTransform());
			tmat.multiplyToRef(mesh.getWorldMatrix(), tmat);
		}
		else {
			tmat.copyFrom(this._parent.getAbsoluteTransform());
		}
		
		tmat.invert();
		Vector3.TransformCoordinatesToRef(position, tmat, vec);
		
		var lm = this.getLocalMatrix();
		lm.m[12] = vec.x;
		lm.m[13] = vec.y;
		lm.m[14] = vec.z;
		
		this.markAsDirty();		
	}
	
	public function setScale(x:Float, y:Float, z:Float, scaleChildren:Bool = false) {
		if (this.animations[0] != null && !this.animations[0].isStopped()) {
            if (!scaleChildren) {
                this._negateScaleChildren.x = 1 / x;
                this._negateScaleChildren.y = 1 / y;
                this._negateScaleChildren.z = 1 / z;
            }
			
            this._syncScaleVector();
        }
		
		this.scale(x / this._scaleVector.x, y / this._scaleVector.y, z / this._scaleVector.z, scaleChildren);
	}

	public function scale(x:Float, y:Float, z:Float, scaleChildren:Bool = false) {
		var locMat = this.getLocalMatrix();
		var origLocMat = Tmp.matrix[0];
		origLocMat.copyFrom(locMat);
		
		var origLocMatInv = Tmp.matrix[1];
		origLocMatInv.copyFrom(origLocMat);
		origLocMatInv.invert();
		
		var scaleMat = Tmp.matrix[2];
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

	public function setYawPitchRoll(yaw:Float, pitch:Float, roll:Float, space:Int = Space.LOCAL, mesh:AbstractMesh = null) {
		var rotMat = Tmp.matrix[0];
		Matrix.RotationYawPitchRollToRef(yaw, pitch, roll, rotMat);
		
		var rotMatInv = Tmp.matrix[1];
		
		this._getNegativeRotationToRef(rotMatInv, space, mesh);
		
		rotMatInv.multiplyToRef(rotMat, rotMat);
		
		this._rotateWithMatrix(rotMat, space, mesh);		
	}

	public function rotate(axis:Vector3, amount:Float, space:Int = Space.LOCAL, mesh:AbstractMesh = null) {		
		var rmat = Tmp.matrix[0];
		rmat.m[12] = 0;
		rmat.m[13] = 0;
		rmat.m[14] = 0;
		
		Matrix.RotationAxisToRef(axis, amount, rmat);
		
		this._rotateWithMatrix(rmat, space, mesh);		
	}

	public function setAxisAngle(axis:Vector3, angle:Float, space:Int, mesh:AbstractMesh) {
		var rotMat = Tmp.matrix[0];
		Matrix.RotationAxisToRef(axis, angle, rotMat);
		var rotMatInv = Tmp.matrix[1];
		
		this._getNegativeRotationToRef(rotMatInv, space, mesh);
		
		rotMatInv.multiplyToRef(rotMat, rotMat);
		this._rotateWithMatrix(rotMat, space, mesh);
	}
	
	public function setRotationMatrix(rotMat:Matrix, space:Int = Space.LOCAL, mesh:AbstractMesh = null) {
		var rotMatInv = Tmp.matrix[0];
		
		this._getNegativeRotationToRef(rotMatInv, space, mesh);
		
		var rotMat2 = Tmp.matrix[1];
		rotMat2.copyFrom(rotMat);
		
		rotMatInv.multiplyToRef(rotMat, rotMat2);
		
		this._rotateWithMatrix(rotMat2, space, mesh);
	}

	private function _rotateWithMatrix(rmat:Matrix, space:Int = Space.LOCAL, mesh:AbstractMesh = null) {
		var lmat = this.getLocalMatrix();
		var lx = lmat.m[12];
		var ly = lmat.m[13];
		var lz = lmat.m[14];
		var parent = this.getParent();
		var parentScale = Tmp.matrix[3];
		var parentScaleInv = Tmp.matrix[4];
		
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

	private function _getNegativeRotationToRef(rotMatInv:Matrix, space:Int = Space.LOCAL, mesh:AbstractMesh = null) {
		if (space == Space.WORLD) {
			var scaleMatrix = Tmp.matrix[2];
			scaleMatrix.copyFrom(this._scaleMatrix);
			rotMatInv.copyFrom(this.getAbsoluteTransform());
			if (mesh != null) {
				rotMatInv.multiplyToRef(mesh.getWorldMatrix(), rotMatInv);
				var meshScale = Tmp.matrix[3];
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
			var scaleMatrix = Tmp.matrix[2];
			scaleMatrix.copyFrom(this._scaleMatrix);
			if (this._parent != null) {
				var pscaleMatrix = Tmp.matrix[3];
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

	inline public function getScale():Vector3 {		
		return this._scaleVector.clone();		
	}

	inline public function getScaleToRef(result:Vector3) {
		result.copyFrom(this._scaleVector);		
	}

	public function getAbsolutePosition(mesh:AbstractMesh = null):Vector3 {
		var pos = Vector3.Zero();
		this.getAbsolutePositionToRef(mesh, pos);
		
		return pos;
	}

	public function getAbsolutePositionToRef(mesh:AbstractMesh = null, result:Vector3) {
		this._skeleton.computeAbsoluteTransforms();
		
		var tmat = Tmp.matrix[0];
		
		if (mesh != null) {
			tmat.copyFrom(this.getAbsoluteTransform());
			tmat.multiplyToRef(mesh.getWorldMatrix(), tmat);
		}
		else {
			tmat = this.getAbsoluteTransform();
		}
		
		result.x = tmat.m[12];
		result.y = tmat.m[13];
		result.z = tmat.m[14];
	}

	public function computeAbsoluteTransforms() {
		if (this._parent != null) {
			this._matrix.multiplyToRef(this._parent._absoluteTransform, this._absoluteTransform);
		} 
		else {
			this._absoluteTransform.copyFrom(this._matrix);
			
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
	
	override public function getDirection(localAxis:Vector3, ?mesh:AbstractMesh):Vector3 {
		var result = Vector3.Zero();
		this.getDirectionToRef(localAxis, result, mesh);
		
		return result;
	}

	override public function getDirectionToRef(localAxis:Vector3, result:Vector3, ?mesh:AbstractMesh) {
		this._skeleton.computeAbsoluteTransforms();
        
		var mat = Tmp.matrix[0];
		
		mat.copyFrom(this.getAbsoluteTransform());
		
		if (mesh != null) {
			mat.multiplyToRef(mesh.getWorldMatrix(), mat);
		}
		
		Vector3.TransformNormalToRef(localAxis, mat, result);
		
		if (mesh != null) {
			result.x /= mesh.scaling.x;
			result.y /= mesh.scaling.y;
			result.z /= mesh.scaling.z;
		}
		
		result.x /= this._scaleVector.x;
		result.y /= this._scaleVector.y;
		result.z /= this._scaleVector.z;
	}
	
	public function getRotation(mesh:AbstractMesh):Quaternion {
		var result = Quaternion.Identity();
		
		this.getRotationToRef(mesh, result);
		
		return result;
	}

	public function getRotationToRef(mesh:AbstractMesh, result:Quaternion) {
		var mat = Tmp.matrix[0];
		var amat = this.getAbsoluteTransform();
		var wmat = mesh.getWorldMatrix();
		
		amat.multiplyToRef(wmat, mat);
		
		mat.decompose(Tmp.vector3[0], result, Tmp.vector3[1]);
	}
	
}
