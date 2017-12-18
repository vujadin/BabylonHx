package com.babylonhx.collisions;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Geometry;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.CollisionCoordinatorLegacy') class CollisionCoordinatorLegacy implements ICollisionCoordinator {

	private var _scene:Scene;

	private var _scaledPosition:Vector3 = Vector3.Zero();
	private var _scaledVelocity:Vector3 = Vector3.Zero();

	private var _finalPosition:Vector3 = Vector3.Zero();
	
	public function new() {
		//
	}

	public function init(scene:Scene) {
		this._scene = scene;
	}

	public function destroy() {
		//Legacy need no destruction method.
	}
	
	inline public function getNewPosition(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, excludedMesh:AbstractMesh, onNewPosition:Int->Vector3->AbstractMesh->Void, collisionIndex:Int) {
		position.divideToRef(collider.radius, this._scaledPosition);
		velocity.divideToRef(collider.radius, this._scaledVelocity);
		collider.collidedMesh = null;
		collider.retry = 0;
		collider.initialVelocity = this._scaledVelocity;
		collider.initialPosition = this._scaledPosition;
		this._collideWithWorld(this._scaledPosition, this._scaledVelocity, collider, maximumRetry, this._finalPosition, excludedMesh);
		
		this._finalPosition.multiplyInPlace(collider.radius);
		//run the callback
		onNewPosition(collisionIndex, this._finalPosition, collider.collidedMesh);
	}

	//No update in legacy mode
	public function onMeshAdded(mesh:AbstractMesh) { }
	public function onMeshUpdated(mesh:AbstractMesh) { }
	public function onMeshRemoved(mesh:AbstractMesh) { }
	public function onGeometryAdded(geometry:Geometry) { }
	public function onGeometryUpdated(geometry:Geometry) { }
	public function onGeometryDeleted(geometry:Geometry) { }

	private function _collideWithWorld(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, finalPosition:Vector3, excludedMesh:AbstractMesh = null) {
		var closeDistance = Engine.CollisionsEpsilon * 10.0;
		
		if (collider.retry >= maximumRetry) {
			finalPosition.copyFrom(position);
			return;
		}
		
		collider._initialize(position, velocity, closeDistance);
		
		// Check all meshes
		for (mesh in this._scene.meshes) {
			if (mesh.isEnabled() && mesh.checkCollisions && mesh.subMeshes != null && mesh != excludedMesh) {
				mesh._checkCollision(collider);
			}
		}
		
		if (!collider.collisionFound) {
			position.addToRef(velocity, finalPosition);
			return;
		}
		
		if (velocity.x != 0 || velocity.y != 0 || velocity.z != 0) {
			collider._getResponse(position, velocity);
		}
		
		if (velocity.length() <= closeDistance) {
			finalPosition.copyFrom(position);
			return;
		}
		
		collider.retry++;
		this._collideWithWorld(position, velocity, collider, maximumRetry, finalPosition, excludedMesh);
	}
	
}
