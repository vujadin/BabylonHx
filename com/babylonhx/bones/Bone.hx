package com.babylonhx.bones;

import com.babylonhx.animations.IAnimatable;
import com.babylonhx.math.Matrix;
import com.babylonhx.animations.Animation;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Bone') class Bone implements IAnimatable {
	
	public var name:String;
	public var children:Array<Bone> = [];
	public var animations:Array<Animation> = [];

	private var _skeleton:Skeleton;
	private var _matrix:Matrix;
	private var _baseMatrix:Matrix;
	private var _worldTransform:Matrix = new Matrix();
	private var _absoluteTransform:Matrix = new Matrix();
	private var _invertedAbsoluteTransform:Matrix = new Matrix();
	private var _parent:Bone;

	
	public function new(name:String, skeleton:Skeleton, parentBone:Bone = null, matrix:Matrix) {
		this.name = name;
		this._skeleton = skeleton;
		this._matrix = matrix;
		this._baseMatrix = matrix;
		
		skeleton.bones.push(this);
		
		if (parentBone != null) {
			this._parent = parentBone;
			parentBone.children.push(this);
		} else {
			this._parent = null;
		}
		
		this._updateDifferenceMatrix();
	}

	// Members
	public function getParent():Bone {
		return this._parent;
	}

	public function getLocalMatrix():Matrix {
		return this._matrix;
	}

	public function getBaseMatrix():Matrix {
		return this._baseMatrix;
	}

	public function getWorldMatrix():Matrix {
		return this._worldTransform;
	}

	public function getInvertedAbsoluteTransform():Matrix {
		return this._invertedAbsoluteTransform;
	}

	public function getAbsoluteMatrix():Matrix {
		var matrix = this._matrix.clone();
		var parent = this._parent;
		
		while(parent != null) {
			matrix = matrix.multiply(parent.getLocalMatrix());
			parent = parent.getParent();
		}
		
		return matrix;
	}

	// Methods
	public function updateMatrix(matrix:Matrix):Void {
		this._matrix = matrix;
		this._skeleton._markAsDirty();
		
		this._updateDifferenceMatrix();
	}

	private function _updateDifferenceMatrix():Void {
		if (this._parent != null) {
			this._matrix.multiplyToRef(this._parent._absoluteTransform, this._absoluteTransform);
		} else {
			this._absoluteTransform.copyFrom(this._matrix);
		}
		
		this._absoluteTransform.invertToRef(this._invertedAbsoluteTransform);
		
		for (index in 0...this.children.length) {
			this.children[index]._updateDifferenceMatrix();
		}
	}

	public function markAsDirty():Void {
		this._skeleton._markAsDirty();
	}
	
}
