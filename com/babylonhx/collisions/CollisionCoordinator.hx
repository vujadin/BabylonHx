package com.babylonhx.collisions;

import lime.utils.Float32Array;
import lime.utils.Int32Array;

import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Geometry;

#if js
import js.html.Worker;
#else if cpp
import cpp.vm.Thread;
#end


/**
 * ...
 * @author Krtolica Vujadin
 */

typedef SerializedMesh = {
	id: String,
	name: String,
	uniqueId: Int,
	geometryId: String,
	sphereCenter: Array<Float>,
	sphereRadius: Float,
	boxMinimum: Array<Float>,
	boxMaximum: Array<Float>,
	worldMatrixFromCache: Dynamic,
	subMeshes: Array<SerializedSubMesh>,
	checkCollisions: Bool
}

typedef SerializedSubMesh = {
	position: Int,
	verticesStart: Int,
	verticesCount: Int,
	indexStart: Int,
	indexCount: Int,
	hasMaterial: Bool,
	sphereCenter: Array<Float>,
	sphereRadius: Float,
	boxMinimum: Array<Float>,
	boxMaximum: Array<Float>
}

typedef SerializedGeometry = {
	id: String,
	positions: Float32Array,
	indices: Int32Array,
	normals: Float32Array
	//uvs?: Float32Array;
}

typedef BabylonMessage = {
	taskType: WorkerTaskType,
	payload: Dynamic // InitPayload|CollidePayload|UpdatePayload /*any for TS under 1.4*/;
}

typedef SerializedColliderToWorker = {
	position: Array<Float>,
	velocity: Array<Float>,
	radius: Array<Float>
}

enum WorkerTaskType {
	INIT;
	UPDATE;
	COLLIDE;
}

typedef WorkerReply = {
	error: WorkerReplyType,
	taskType: WorkerTaskType,
	?payload: Dynamic,
}

typedef CollisionReplyPayload = {
	newPosition: Array<Float>,
	collisionId: Int,
	collidedMeshUniqueId: Int
}

typedef CollidePayload = {
	collisionId: Int,
	collider: SerializedColliderToWorker,
	maximumRetry: Int,
	?excludedMeshUniqueId: Int
}

typedef UpdatePayload = {
	updatedMeshes: Map<Int, SerializedMesh>,
	updatedGeometries: Map<String, SerializedGeometry>,
	removedMeshes: Array<Int>,
	removedGeometries: Array<String>
}

enum WorkerReplyType {
	SUCCESS;
	UNKNOWN_ERROR;
}

 
@:expose('BABYLON.CollisionCoordinator') class CollisionCoordinator implements ICollisionCoordinator {
	
	private var _scene:Scene;
	
	public var _finalPosition:Vector3 = Vector3.Zero();

	private var _scaledPosition:Vector3 = Vector3.Zero();
	private var _scaledVelocity:Vector3 = Vector3.Zero();

	private var _collisionsCallbackArray: Array<Int->Vector3->AbstractMesh->Void>;

	private var _init:Bool;
	private var _runningUpdated:Int;
	private var _runningCollisionTask:Bool;
	
	#if js
	private var _worker:Worker;
	#else if cpp
	private var _worker:Thread;
	#end
	
	//No update in legacy mode
	public function onMeshAdded(mesh:AbstractMesh) { }
	public function onMeshUpdated(mesh:AbstractMesh) { }
	public function onMeshRemoved(mesh:AbstractMesh) { }
	public function onGeometryAdded(geometry:Geometry) { }
	public function onGeometryUpdated(geometry:Geometry) { }
	public function onGeometryDeleted(geometry:Geometry) { }

	public function new(scene:Scene) {
		init(scene);
	}
	
	public function init(scene:Scene) {
		this._scene = scene;
	}

	public function getNewPosition(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, excludedMesh:AbstractMesh, onNewPosition:Int->Vector3->AbstractMesh->Void, collisionIndex:Int) {
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
	
	public function destroy() {
		//Legacy need no destruction method.
	}
	
	private function _collideWithWorld(position:Vector3, velocity:Vector3, collider:Collider, maximumRetry:Int, finalPosition:Vector3, excludedMesh:AbstractMesh = null) {
		var closeDistance = Engine.CollisionsEpsilon * 10.0;
		
		if (collider.retry >= maximumRetry) {
			finalPosition.copyFrom(position);
			return;
		}
		
		collider._initialize(position, velocity, closeDistance);
		
		// Check all meshes
		for (index in 0...this._scene.meshes.length) {
			var mesh = this._scene.meshes[index];
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
