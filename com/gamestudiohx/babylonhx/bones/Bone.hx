package com.gamestudiohx.babylonhx.bones;

import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.animations.Animation;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Bone {

	public var name:String;
	public var _skeleton:Skeleton;
	public var _matrix:Matrix;
	public var _baseMatrix:Matrix;
	public var _worldTransform:Matrix;
	public var _absoluteTransform:Matrix;
	public var _invertedAbsoluteTransform:Matrix;
	public var children:Array<Bone>;
	public var animations:Array<Animation>;
	
	private var _parent:Bone;
	

	public function new(name:String, skeleton:Skeleton, parentBone:Bone, matrix:Matrix) {
		this.name = name;
        this._skeleton = skeleton;
        this._matrix = matrix;
        this._baseMatrix = matrix;
        this._worldTransform = new Matrix();
        this._absoluteTransform = new Matrix();
        this._invertedAbsoluteTransform = new Matrix();
        this.children = [];
        this.animations = [];

        skeleton.bones.push(this);
        
        if (parentBone != null) {
            this._parent = parentBone;
            parentBone.children.push(this);
        } else {
            this._parent = null;
        }
        
        this._updateDifferenceMatrix();
	}

	public function getParent():Bone {
		return this._parent;
	}
	
	public function getLocalMatrix():Matrix {
		return this._matrix;
	}
	
	public function getAbsoluteMatrix():Matrix {
		var matrix:Matrix = this._matrix.clone();
        var parent:Bone = this._parent;

        while (parent != null) {
            matrix = matrix.multiply(parent.getLocalMatrix());
            parent = parent.getParent();
        }

        return matrix;
	}
	
	public function _updateDifferenceMatrix() {
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
	
	public function updateMatrix(matrix:Matrix) {
		this._matrix = matrix;
        this._skeleton._markAsDirty();

        this._updateDifferenceMatrix();
	}
	
	public function markAsDirty() {
		this._skeleton._markAsDirty();
	}
	
}
