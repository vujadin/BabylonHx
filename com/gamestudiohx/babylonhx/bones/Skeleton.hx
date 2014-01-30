package com.gamestudiohx.babylonhx.bones;

import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import openfl.utils.Float32Array;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Skeleton {

	public var id:String;
	public var name:String;
	public var bones:Array<Bone>;
	public var _scene:Scene;
	public var _isDirty:Bool;
	
	private var _transformMatrices:Array<Float>;// Float32Array
	
	private var _animatables:Array<Dynamic>; // Array<Bone>;
	

	public function new(name:String, id:String, scene:Scene) {
		this.id = id;
        this.name = name;
        this.bones = [];

        this._scene = scene;

        scene.skeletons.push(this);

        this._isDirty = true;
	}
	
	public function _markAsDirty() {
        this._isDirty = true;
    }

	public function getTransformMatrices():Array<Float> /*Float32Array*/ {
		return this._transformMatrices;
	}
	
	public function prepare() {		
		if (!this._isDirty) {
            return;
        }

        if (this._transformMatrices == null/* || this._transformMatrices.length != 16 * this.bones.length*/) {
            this._transformMatrices = [];    // new Float32Array(16 * this.bones.length);
        }

        for (index in 0...this.bones.length) {
            var bone:Bone = this.bones[index];
            var parentBone:Bone = bone.getParent();

            if (parentBone != null) {
                bone._matrix.multiplyToRef(parentBone._worldTransform, bone._worldTransform);
            } else {
                bone._worldTransform.copyFrom(bone._matrix);
            }

            bone._invertedAbsoluteTransform.multiplyToArray(bone._worldTransform, this._transformMatrices, index * 16);
        }

        this._isDirty = false;
	}
	
	public function getAnimatables():Array<Dynamic> { // Array<Animation> {
		if (this._animatables == null || this._animatables.length != this.bones.length) {
            this._animatables = [];
            
            for (index in 0...this.bones.length) {
                this._animatables.push(this.bones[index]);
            }
        }

        return this._animatables;
	}
	
	public function clone(name:String, id:String):Skeleton {
		var result:Skeleton = new Skeleton(name, id, this._scene);

        for (index in 0...this.bones.length) {
            var source:Bone = this.bones[index];
            var parentBone:Bone = null;
            
            if (source.getParent() != null) {
                var parentIndex = Lambda.indexOf(this.bones, source.getParent());
                parentBone = result.bones[parentIndex];
            }

            var bone = new Bone(source.name, result, parentBone, source._baseMatrix);
            //BABYLON.Tools.DeepCopy(source.animations, bone.animations);
			// TODO - should this work ?? test it
			bone.animations = source.animations.copy();
        }

        return result;
	}
	
}
