package com.babylonhx.bones;

import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.math.Matrix;
import com.babylonhx.tools.Tools;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.animations.AnimationRange;
import com.babylonhx.utils.typedarray.Float32Array;

import haxe.ds.Vector;


/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Skeleton') class Skeleton implements ISmartArrayCompatible {
	
	public var id:String;
	public var name:String;
	public var bones:Array<Bone>;
	
	public var needInitialSkinMatrix:Bool = false;

	private var _scene:Scene;
	private var _isDirty:Bool = true;
	private var _transformMatrices: #if (js || purejs || web || html5) Float32Array #else Array<Float> #end ;
	private var _meshesWithPoseMatrix:Array<AbstractMesh> = [];
	private var _animatables:Array<IAnimatable>;
	private var _identity:Matrix = Matrix.Identity();
	
	private var _ranges:Map<String, AnimationRange> = new Map();
	
	public var __smartArrayFlags:Array<Int> = [];
	

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
	public function createAnimationRange(name:String, from:Float, to:Float) {
		// check name not already in use
		if (this._ranges[name] == null) {
			this._ranges[name] = new AnimationRange(name, from, to);
			for (i in 0...this.bones.length) {
				if (this.bones[i].animations[0] != null) {
					this.bones[i].animations[0].createRange(name, from, to);
				}
			}
		}
	}
	
	public function deleteAnimationRange(name:String, deleteFrames:Bool = true) {
		for (i in 0...this.bones.length) {
			if (this.bones[i].animations[0] != null) {
				this.bones[i].animations[0].deleteRange(name, deleteFrames);
			}
		}
		
		this._ranges.remove(name);
	}
	
	public function getAnimationRange(name:String):AnimationRange {
		return this._ranges[name];
	}
	
	/**
	 *  Returns as an Array, all AnimationRanges defined on this skeleton
	 */
	public function getAnimationRanges():Array<AnimationRange> {
		var animationRanges:Array<AnimationRange> = [];
		var name:String;
		var i:Int = 0;
		for (name in this._ranges.keys()){
			animationRanges[i] = this._ranges[name];
			i++;
		}
		
		return animationRanges;
	}
	
	/** 
	 *  note: This is not for a complete retargeting, only between very similar skeleton's with only possible bone length differences
	 */
	public function copyAnimationRange(source:Skeleton, name:String, rescaleAsRequired:Bool = false):Bool {
		if (this._ranges[name] != null || source.getAnimationRange(name) == null){
		   return false; 
		}
		var ret:Bool = true;
		var frameOffset:Float = this._getHighestAnimationFrame() + 1;
		
		// make a dictionary of source skeleton's bones, so exact same order or doublely nested loop is not required
		var boneDict:Map<String, Bone> = new Map();
		var sourceBones = source.bones;
		for (i in 0...sourceBones.length) {
			boneDict[sourceBones[i].name] = sourceBones[i];
		}
		
		for (i in 0...this.bones.length) {
			var boneName = this.bones[i].name;
			var sourceBone = boneDict[boneName];
			if (sourceBone != null) {
				ret = ret && this.bones[i].copyAnimationRange(sourceBone, name, cast frameOffset, rescaleAsRequired);
			}
			else {
				trace("copyAnimationRange: not same rig, missing source bone " + boneName);
				ret = false;
			}
		}
		// do not call createAnimationRange(), since it also is done to bones, which was already done
		var range = source.getAnimationRange(name);
		this._ranges[name] = new AnimationRange(name, range.from + frameOffset, range.to + frameOffset);
		
		return ret;
	}
	
	public function returnToRest() {
		for (index in 0...this.bones.length) {
			this.bones[index].returnToRest();
		}
	}
	
	private function _getHighestAnimationFrame():Float {
		var ret:Float = 0; 
		for (i in 0...this.bones.length) {
			if (this.bones[i].animations[0] != null) {
				var highest = this.bones[i].animations[0].getHighestFrame();
				if (ret < highest) {
					ret = highest; 
				}
			}
		}
		
		return ret;
	}
	
	inline public function getTransformMatrices(mesh:AbstractMesh): #if (js || purejs || web || html5) Float32Array #else Array<Float> #end {
		if (this.needInitialSkinMatrix && mesh._bonesTransformMatrices != null) {
			return mesh._bonesTransformMatrices;
		}
		
		return this._transformMatrices;
	}
	
	public function getScene():Scene {
		return this._scene;
	}

	// Methods
	inline public function _markAsDirty():Void {
		this._isDirty = true;
	}
	
	public function _registerMeshWithPoseMatrix(mesh:AbstractMesh) {
		this._meshesWithPoseMatrix.push(mesh);
	}

	public function _unregisterMeshWithPoseMatrix(mesh:AbstractMesh) {
		var index = this._meshesWithPoseMatrix.indexOf(mesh);
		
		if (index > -1) {
			this._meshesWithPoseMatrix.splice(index, 1);
		}
	}

	public function prepare() {
		if (!this._isDirty) {
			return;
		}
		
		if (this._transformMatrices == null || this._transformMatrices.length != 16 * (this.bones.length + 1)) {
			this._transformMatrices = #if (js || html5 || purejs) new Float32Array(16 * (this.bones.length + 1)) #else [] #end ;
		}
		
		for (index in 0...this.bones.length) {
			var bone = this.bones[index];
			var parentBone = bone.getParent();
			
			if (parentBone != null) {
				bone.getLocalMatrix().multiplyToRef(parentBone.getWorldMatrix(), bone.getWorldMatrix());
			} 
			else {
				bone.getWorldMatrix().copyFrom(bone.getLocalMatrix());
			}
			
			bone.getInvertedAbsoluteTransform().multiplyToArray(bone.getWorldMatrix(), this._transformMatrices, index * 16);
		}
		
		this._identity.copyToArray(this._transformMatrices, this.bones.length * 16);
		this._isDirty = false;
		
		this._scene._activeBones += this.bones.length;
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
		
		result.needInitialSkinMatrix = this.needInitialSkinMatrix;
		
		for (index in 0...this.bones.length) {
			var source = this.bones[index];
			var parentBone = null;
			
			if (source.getParent() != null) {
				var parentIndex = this.bones.indexOf(source.getParent());
				parentBone = result.bones[parentIndex];
			}
			
			var bone = new Bone(source.name, result, parentBone, source.getBaseMatrix().clone());
			for (anim in source.animations) {
				bone.animations.push(anim.clone());
			}
		}
		
		if (this._ranges != null) {
			result._ranges = new Map();
			for (name in this._ranges.keys()) {
				result._ranges[name] = this._ranges[name].clone();
			}
		}
		
		this._isDirty = true;
		
		return result;
	}
	
	public function dispose() {
        // Animations
        this.getScene().stopAnimation(this);
		
        // Remove from scene
        this.getScene().removeSkeleton(this);
    }
	
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.name = this.name;
		serializationObject.id = this.id;
		
		serializationObject.bones = [];
		
		for (index in 0...this.bones.length) {
			var bone = this.bones[index];
			
			var serializedBone:Dynamic = {
				parentBoneIndex: bone.getParent() != null ? this.bones.indexOf(bone.getParent()) : -1,
				name: bone.name,
				matrix: bone.getLocalMatrix().toArray(),
				rest: bone.getRestPose().toArray()
			};
			
			serializationObject.bones.push(serializedBone);
			
			if (bone.length > 0) {
				serializedBone.length = bone.length;
			}
			
			if (bone.animations != null && bone.animations.length > 0) {
				serializedBone.animation = bone.animations[0].serialize();
			}
			
			serializationObject.ranges = [];
			for (name in this._ranges.keys()) {
				var range:Dynamic = { };
				range.name = name;
				range.from = this._ranges[name].from;
				range.to   = this._ranges[name].to;
				serializationObject.ranges.push(range);
			}
		}
		
		return serializationObject;
	}
	
	public static function Parse(parsedSkeleton:Dynamic, scene:Scene):Skeleton {
        var skeleton = new Skeleton(parsedSkeleton.name, parsedSkeleton.id, scene);
		try {
			for (index in 0...parsedSkeleton.bones.length) {
				var parsedBone = parsedSkeleton.bones[index];
				
				var parentBone = null;
				if (parsedBone.parentBoneIndex > -1) {
					parentBone = skeleton.bones[parsedBone.parentBoneIndex];
				}
				
				var rest:Matrix = parsedBone.rest != null ? Matrix.FromArray(parsedBone.rest) : null;
				var bone = new Bone(parsedBone.name, skeleton, parentBone, Matrix.FromArray(parsedBone.matrix), rest);
				
				if (parsedBone.length != 0) {
					bone.length = parsedBone.length;
				}
				
				if (parsedBone.animation != null) {
					bone.animations.push(Animation.Parse(parsedBone.animation));
				}
			}
		} catch (err:Dynamic) {
			trace(err);
		}
		
		// placed after bones, so createAnimationRange can cascade down
		if (parsedSkeleton.ranges != null) {
		    for (index in 0...parsedSkeleton.ranges.length) {
			    var data = parsedSkeleton.ranges[index];
			    skeleton.createAnimationRange(data.name, data.from, data.to);
		    }
		}
		
        return skeleton;
    }
	
}
