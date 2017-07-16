package com.babylonhx.debug;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Tmp;
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.bones.Bone;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SkeletonViewer {
	
	public var color:Color3 = Color3.White();
	public var skeleton:Skeleton;
	public var mesh:AbstractMesh;
	public var autoUpdateBonesMatrices:Bool;
	public var renderingGroupId:Int;
	
	public var isEnabled(get, set):Bool;

	private var _scene:Scene;
	public var _debugLines:Array<Array<Vector3>> = []; 
	private var _debugMesh:LinesMesh;
	private var _isEnabled:Bool = false;
	private var _renderFunction:Dynamic;
	

	public function new(skeleton:Skeleton, mesh:AbstractMesh, scene:Scene, autoUpdateBonesMatrices:Bool = true, renderingGroupId:Int = 1) {
		this._scene = scene;
		this.skeleton = skeleton;
		this.mesh = mesh;
		this.autoUpdateBonesMatrices = autoUpdateBonesMatrices;
		
		this.update();
		
		this._renderFunction = this.update;
	}
	
	private function set_isEnabled(value:Bool):Bool {
		if (this._isEnabled == value) {
			return value;
		}
		
		this._isEnabled = value;
		
		if (value) {
			this._scene.registerBeforeRender(this._renderFunction);
		} 
		else {
			this._scene.unregisterBeforeRender(this._renderFunction);
		}
		
		return value;
	}
	private function get_isEnabled():Bool {
		return this._isEnabled;
	}

	private function _getBonePosition(position:Vector3, bone:Bone, meshMat:Matrix, x:Float = 0, y:Float = 0, z:Float = 0) {
		var tmat = Tmp.matrix[0];
		var parentBone = bone.getParent();
		tmat.copyFrom(bone.getLocalMatrix());
		
		if (x != 0 || y != 0 || z != 0) {
			var tmat2 = Tmp.matrix[1];
			Matrix.IdentityToRef(tmat2);
			tmat2.m[12] = x;
			tmat2.m[13] = y;
			tmat2.m[14] = z;
			tmat2.multiplyToRef(tmat, tmat);
		}
		
		if (parentBone != null) {
			tmat.multiplyToRef(parentBone.getAbsoluteTransform(), tmat);
		}
		
		tmat.multiplyToRef(meshMat, tmat);
		
		position.x = tmat.m[12];
		position.y = tmat.m[13];
		position.z = tmat.m[14];
	}

	private function _getLinesForBonesWithLength(bones:Array<Bone>, meshMat:Matrix) {
		var len = bones.length;
		for (i in 0...len) {
			var bone = bones[i];
			var points = this._debugLines[i];
			if (points == null) {
				points = [Vector3.Zero(), Vector3.Zero()];
				this._debugLines[i] = points;
			}
			this._getBonePosition(points[0], bone, meshMat);
			this._getBonePosition(points[1], bone, meshMat, 0, bone.length, 0);
		}
	}

	private function _getLinesForBonesNoLength(bones:Array<Bone>, meshMat:Matrix) {
		var len:Int = bones.length;
		var boneNum:Int = 0;
		var i:Int = len - 1;
		while (i >= 0) {
			var childBone:Bone = bones[i];
			var parentBone = childBone.getParent();
			if (parentBone == null) {
				continue;
			}
			
			var points = this._debugLines[boneNum];
			if (points == null) {
				points = [Vector3.Zero(), Vector3.Zero()];
				this._debugLines[boneNum] = points;
			}
			
			this._getBonePosition(points[0], childBone, meshMat);
			this._getBonePosition(points[1], parentBone, meshMat);
			
			boneNum++;
			
			--i;
		}
	}

	public function update() {
		if (this.autoUpdateBonesMatrices) {
			this._updateBoneMatrix(this.skeleton.bones[0]);
		}
		
		if (this.skeleton.bones[0].length == -1) {
			this._getLinesForBonesNoLength(this.skeleton.bones, this.mesh.getWorldMatrix());
		} 
		else {
			this._getLinesForBonesWithLength(this.skeleton.bones, this.mesh.getWorldMatrix());
		}
		
		if (this._debugMesh == null) {
			this._debugMesh = MeshBuilder.CreateLineSystem(null, { lines: this._debugLines, updatable: true }, this._scene);
			this._debugMesh.renderingGroupId = this.renderingGroupId;
			this._debugMesh.color = this.color;
		} 
		else {
			MeshBuilder.CreateLineSystem(null, { lines: this._debugLines, updatable: true, instance: this._debugMesh }, this._scene);
		}
	}

	private function _updateBoneMatrix(bone:Bone) {
		if (bone.getParent() != null) {
			bone.getLocalMatrix().multiplyToRef(bone.getParent().getAbsoluteTransform(), bone.getAbsoluteTransform());
		}
		
		var children = bone.children;
		var len = children.length;
		
		for (i in 0...len) {
			this._updateBoneMatrix(children[i]);
		}
	}

	public function dispose() {
		if (this._debugMesh != null) {
			this.isEnabled = false;
			this._debugMesh.dispose();
			this._debugMesh = null;
		}
	}
	
}
