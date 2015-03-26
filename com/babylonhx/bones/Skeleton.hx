package com.babylonhx.bones;

import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.math.Matrix;
import com.babylonhx.tools.Tools;
import com.babylonhx.animations.IAnimatable;

import com.babylonhx.utils.typedarray.Float32Array;


/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Skeleton') class Skeleton implements ISmartArrayCompatible {
	
	public var id:String;
	public var name:String;
	public var bones:Array<Bone>;

	private var _scene:Scene;
	private var _isDirty:Bool = true;
	private var _transformMatrices: #if html5 Float32Array #else Array<Float> #end ;
	private var _animatables:Array<IAnimatable>;
	private var _identity:Matrix = Matrix.Identity();
	
	public var __smartArrayFlags:Array<Int>;
	

	public function new(name:String, id:String, scene:Scene) {
		this.name = name;
		this.id = id;
		
		this.bones = [];
		
		this._scene = scene;
		
		scene.skeletons.push(this);
		
		this.prepare();
        //make sure it will recalculate the matrix next time prepare is called.
        this._isDirty = true;
	}

	// Members
	public function getTransformMatrices(): #if html5 Float32Array #else Array<Float> #end {
		return this._transformMatrices;
	}

	// Methods
	public function _markAsDirty():Void {
		this._isDirty = true;
	}

	public function prepare():Void {
		if (!this._isDirty) {
			return;
		}
		
		if (this._transformMatrices == null || this._transformMatrices.length != 16 * (this.bones.length + 1)) {
			this._transformMatrices = #if html5 new Float32Array(16 * (this.bones.length + 1)) #else [] #end ;
		}
		
		for (index in 0...this.bones.length) {
			var bone = this.bones[index];
			var parentBone = bone.getParent();
			
			if (parentBone != null) {
				bone.getLocalMatrix().multiplyToRef(parentBone.getWorldMatrix(), bone.getWorldMatrix());
			} else {
				bone.getWorldMatrix().copyFrom(bone.getLocalMatrix());
			}
			
			bone.getInvertedAbsoluteTransform().multiplyToArray(bone.getWorldMatrix(), this._transformMatrices, index * 16);
		}
		
		this._identity.copyToArray(this._transformMatrices, this.bones.length * 16);
		this._isDirty = false;
	}

	public function getAnimatables():Array<IAnimatable> {
		if (this._animatables == null || this._animatables.length != this.bones.length) {
			this._animatables = [];
			
			for (index in 0...this.bones.length) {
				this._animatables.push(this.bones[index]);
			}
		}
		
		return this._animatables;
	}

	public function clone(name:String, ?id:String):Skeleton {
		var result = new Skeleton(name, id != null ? id : name, this._scene);
		
		for (index in 0...this.bones.length) {
			var source = this.bones[index];
			var parentBone = null;
			
			if (source.getParent() != null) {
				var parentIndex = this.bones.indexOf(source.getParent());
				parentBone = result.bones[parentIndex];
			}
			
			var bone = new Bone(source.name, result, parentBone, source.getBaseMatrix());
			for (anim in source.animations) {
				bone.animations.push(anim.clone());
			}
		}
		
		return result;
	}
	
}
