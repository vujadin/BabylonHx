package com.babylonhx.debug;

import com.babylonhx.Scene;
import com.babylonhx.culling.Ray;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Tmp;
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RayHelper {

	public var ray:Ray;

	private var _renderPoints:Array<Vector3>;
	private var _renderLine:LinesMesh;
	private var _renderFunction:Scene->Null<EventState>->Void;
	private var _scene:Scene;
	
	private var _updateToMeshFunction:Scene->Null<EventState>->Void;
	private var _attachedToMesh:AbstractMesh;
	private var _meshSpaceDirection:Vector3;
	private var _meshSpaceOrigin:Vector3;

	public static function CreateAndShow(ray:Ray, scene:Scene, color:Color3):RayHelper {
		var helper = new RayHelper(ray);
		helper.show(scene, color);
		return helper;
	}

	
	public function new(ray:Ray) {
		this.ray = ray;
	}

	public function show(scene:Scene, color:Color3) {
		if (this._renderFunction == null) {
			var ray = this.ray;
			
			this._renderFunction = this._render;
			this._scene = scene;
			this._renderPoints = [ray.origin, ray.origin.add(ray.direction.scale(ray.length))];
			this._renderLine = Mesh.CreateLines("ray", this._renderPoints, scene, true);
			
			this._scene.registerBeforeRender(this._renderFunction);
		}
		
		if (color != null) {
			this._renderLine.color.copyFrom(color);
		}
	}

	public function hide() {
		if (this._renderFunction != null) {
			this._scene.unregisterBeforeRender(this._renderFunction);
			this._scene = null;
			this._renderFunction = null;
			this._renderLine.dispose();
			this._renderLine = null;
			this._renderPoints = null;
		}
	}

	private function _render(_, _) {
		var ray = this.ray;
		
		var point = this._renderPoints[1];
		var len = Math.min(ray.length, 1000000);
		
		point.copyFrom(ray.direction);
		point.scaleInPlace(len);
		point.addInPlace(ray.origin);
		
		Mesh.CreateLines("ray", this._renderPoints, this._scene, true, this._renderLine);
	}

	public function attachToMesh(mesh:AbstractMesh, ?meshSpaceDirection:Vector3, ?meshSpaceOrigin:Vector3, ?length:Float) {
		this._attachedToMesh = mesh;
		
		var ray = this.ray;
		
		if (ray.direction == null) {
			ray.direction = Vector3.Zero();
		}
		
		if (ray.origin == null) {
			ray.origin = Vector3.Zero();
		}
		
		if (length != null) {
			ray.length = length;
		}
		
		if (meshSpaceOrigin == null) {
			meshSpaceOrigin = Vector3.Zero();
		}
		
		if (meshSpaceDirection == null) {
			// -1 so that this will work with Mesh.lookAt
			meshSpaceDirection = new Vector3(0, 0, -1);
		}
		
		if (this._meshSpaceDirection == null) {
			this._meshSpaceDirection = meshSpaceDirection.clone();
			this._meshSpaceOrigin = meshSpaceOrigin.clone();
		}
		else {
			this._meshSpaceDirection.copyFrom(meshSpaceDirection);
			this._meshSpaceOrigin.copyFrom(meshSpaceOrigin);
		}
		
		if (this._updateToMeshFunction == null) {
			this._updateToMeshFunction = this._updateToMesh;
			this._attachedToMesh.getScene().registerBeforeRender(this._updateToMeshFunction);
		}
		
		this._updateToMesh(null, null);
	}

	public function detachFromMesh() {
		if (this._attachedToMesh != null) {
			this._attachedToMesh.getScene().unregisterBeforeRender(this._updateToMeshFunction);
			this._attachedToMesh = null;
			this._updateToMeshFunction = null;
		}
	}

	private function _updateToMesh(_, _) {
		var ray = this.ray;
		
		if (cast(this._attachedToMesh, Mesh)._isDisposed) {
			this.detachFromMesh();
			return;
		}
		
		this._attachedToMesh.getDirectionToRef(this._meshSpaceDirection, ray.direction);
		Vector3.TransformCoordinatesToRef(this._meshSpaceOrigin, this._attachedToMesh.getWorldMatrix(), ray.origin);
	}

	public function dispose() {
		this.hide();
		this.detachFromMesh();
		this.ray = null;
	}
	
}
