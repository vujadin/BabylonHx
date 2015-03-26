package com.babylonhx.physics.plugins;

import com.babylonhx.culling.BoundingBox;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.physics.IPhysicsEnginePlugin;
import com.babylonhx.physics.PhysicsEngine;
import com.babylonhx.physics.PhysicsBodyCreationOptions;
import oimohx.math.Quat;
import oimohx.physics.collision.shape.Shape;
import oimohx.physics.dynamics.RigidBody;
import oimohx.physics.dynamics.World;
import oimohx.math.Vec3;
import com.babylonhx.physics.plugins.Body;
import com.babylonhx.physics.plugins.Link;

/**
 * ...
 * @author Krtolica Vujadin
 */
class OimoPlugin implements IPhysicsEnginePlugin {
	
	public static inline var TO_RAD:Float = 0.017453292;// Math.PI / 180;
	public static inline var WORLD_SCALE:Float = 100;
	public static inline var INV_SCALE:Float = 0.01;
	
	private var _world:World;
	private var _registeredMeshes:Array<Dynamic> = [];
	
	
	public function new() {
		//
	}

	private function _checkWithEpsilon(value:Float):Float {
		return value < PhysicsEngine.Epsilon ? PhysicsEngine.Epsilon : value;
	}

	public function initialize(?iterations:Float) {
		this._world = new World();
		this._world.clear();
	}

	public function setGravity(gravity:Vector3) {
		this._world.gravity = new Vec3(gravity.x, gravity.y, gravity.z);
	}

	public function registerMesh(mesh:AbstractMesh, impostor:Int, options:PhysicsBodyCreationOptions) {
		var body:Body = null;
		this.unregisterMesh(mesh);
		mesh.computeWorldMatrix(true);
		
		var initialRotation:Quaternion = null;
		if (mesh.rotationQuaternion != null) {
			initialRotation = mesh.rotationQuaternion.clone();
			mesh.rotationQuaternion = new Quaternion(0, 0, 0, 1);
			mesh.computeWorldMatrix(true);
		}
		
		var bbox:BoundingBox = mesh.getBoundingInfo().boundingBox;
		
		// The delta between the mesh position and the mesh bounding box center
		var deltaPosition:Vector3 = mesh.position.subtract(bbox.center);
		
		// Transform delta position with the rotation
		if (initialRotation != null) {
			var m = new Matrix();
			initialRotation.toRotationMatrix(m);
			deltaPosition = Vector3.TransformCoordinates(deltaPosition, m);
		}
		
		// register mesh
		switch (impostor) {
			case PhysicsEngine.SphereImpostor:
				var radiusX = bbox.maximumWorld.x - bbox.minimumWorld.x;
				var radiusY = bbox.maximumWorld.y - bbox.minimumWorld.y;
				var radiusZ = bbox.maximumWorld.z - bbox.minimumWorld.z;
				
				var size = Math.max(this._checkWithEpsilon(radiusX), this._checkWithEpsilon(radiusY));
				size = Math.max(size, this._checkWithEpsilon(radiusZ)) / 2;
				
				body = new Body({
					type: 'sphere',
					size: [size],
					pos: [bbox.center.x, bbox.center.y, bbox.center.z],
					rot: [mesh.rotation.x / TO_RAD, mesh.rotation.y / TO_RAD, mesh.rotation.z / TO_RAD],
					move: options.mass != 0,
					config: [options.mass, options.friction, options.restitution],
					world: this._world
				});
				
			case PhysicsEngine.PlaneImpostor, PhysicsEngine.CylinderImpostor, PhysicsEngine.BoxImpostor:				
				var min = bbox.minimumWorld;
				var max = bbox.maximumWorld;
				var box = max.subtract(min);
				var sizeX = this._checkWithEpsilon(box.x);
				var sizeY = this._checkWithEpsilon(box.y);
				var sizeZ = this._checkWithEpsilon(box.z);
				
				body = new Body({
					type: 'box',
					size: [sizeX, sizeY, sizeZ],
					pos: [bbox.center.x, bbox.center.y, bbox.center.z],
					rot: [mesh.rotation.x / TO_RAD, mesh.rotation.y / TO_RAD, mesh.rotation.z / TO_RAD],
					move: options.mass != 0,
					config: [options.mass, options.friction, options.restitution],
					world: this._world
				});
		}
		
		//If quaternion was set as the rotation of the object
		if (initialRotation != null) {
			//We have to access the rigid body's properties to set the quaternion. 
			//The setQuaternion function of Oimo only sets the newOrientation that is only set after an impulse is given or a collision.
			body.body.orientation = new Quat(initialRotation.w, initialRotation.x, initialRotation.y, initialRotation.z);
			//update the internal rotation matrix
			body.body.syncShapes();
		}
		
		this._registeredMeshes.push({
			mesh: mesh,
			body: body,
			delta: deltaPosition
		});
		
		return body;
	}

	public function registerMeshesAsCompound(parts:Array<PhysicsCompoundBodyPart>, options:PhysicsBodyCreationOptions):Dynamic {
		var types:Array<String> = [];
		var	sizes:Array<Float> = [];
		var	positions:Array<Float> = [];
		var	rotations:Array<Float> = [];
		
		var initialMesh = parts[0].mesh;
		
		for (index in 0...parts.length) {
			var part = parts[index];
			var bodyParameters = this._createBodyAsCompound(part, options, initialMesh);
			types.push(bodyParameters.type);
			sizes.push(bodyParameters.size);
			positions.push(bodyParameters.pos);
			rotations.push(bodyParameters.rot);
		}

		var body = new Body({
			type: types,
			size: sizes,
			pos: positions,
			rot: rotations,
			move: options.mass != 0,
			config: [options.mass, options.friction, options.restitution],
			world: this._world
		});

		this._registeredMeshes.push({
			mesh: initialMesh,
			body: body
		});

		return body;
	}

	private function _createBodyAsCompound(part:PhysicsCompoundBodyPart, options:PhysicsBodyCreationOptions, initialMesh:AbstractMesh):Dynamic {
		var bodyParameters:Dynamic = { 
			type: "",
			size: [],
			pos: [],
			rot: []
		};
		var mesh = part.mesh;
		// We need the bounding box/sphere info to compute the physics body
		mesh.computeWorldMatrix();

		switch (part.impostor) {
			case PhysicsEngine.SphereImpostor:
				var bbox = mesh.getBoundingInfo().boundingBox;
				var radiusX = bbox.maximumWorld.x - bbox.minimumWorld.x;
				var radiusY = bbox.maximumWorld.y - bbox.minimumWorld.y;
				var radiusZ = bbox.maximumWorld.z - bbox.minimumWorld.z;

				var size = Math.max(this._checkWithEpsilon(radiusX), this._checkWithEpsilon(radiusY));
				size = Math.max(size, this._checkWithEpsilon(radiusZ)) / 2;
				bodyParameters = {
					type: 'sphere',
					/* bug with oimo : sphere needs 3 sizes in this case */
					size: [size, -1, -1],
					pos: [mesh.position.x, mesh.position.y, mesh.position.z],
					rot: [mesh.rotation.x / TO_RAD, mesh.rotation.y / TO_RAD, mesh.rotation.z / TO_RAD]
				};

			case PhysicsEngine.PlaneImpostor, PhysicsEngine.BoxImpostor:
				var bbox = mesh.getBoundingInfo().boundingBox;
				var min = bbox.minimumWorld;
				var max = bbox.maximumWorld;
				var box = max.subtract(min);
				var sizeX = this._checkWithEpsilon(box.x);
				var sizeY = this._checkWithEpsilon(box.y);
				var sizeZ = this._checkWithEpsilon(box.z);
				var relativePosition = mesh.position;
				bodyParameters = {
					type: 'box',
					size: [sizeX, sizeY, sizeZ],
					pos: [relativePosition.x, relativePosition.y, relativePosition.z],
					rot: [mesh.rotation.x / TO_RAD, mesh.rotation.y / TO_RAD, mesh.rotation.z / TO_RAD]
				};
				
		}

		return bodyParameters;
	}

	public function unregisterMesh(mesh:AbstractMesh) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			if (registeredMesh.mesh == mesh || registeredMesh.mesh == mesh.parent) {
				if (registeredMesh.body != null) {
					this._world.removeRigidBody(registeredMesh.body.body);
					this._unbindBody(registeredMesh.body);
				}
				this._registeredMeshes.splice(index, 1);
				return;
			}
		}
	}

	private function _unbindBody(body:Dynamic) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			if (registeredMesh.body == body) {
				registeredMesh.body = null;
			}
		}
	}

	/**
	 * Update the body position according to the mesh position
	 * @param mesh
	 */
	public function updateBodyPosition(mesh:AbstractMesh) {

		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			if (registeredMesh.mesh == mesh || registeredMesh.mesh == mesh.parent) {
				var body = registeredMesh.body.body;
				mesh.computeWorldMatrix(true);

				var center = mesh.getBoundingInfo().boundingBox.center;
				body.setPosition(center.x, center.y, center.z);
				body.setRotation(mesh.rotation.x, mesh.rotation.y, mesh.rotation.z);
				return;
			}
			// Case where the parent has been updated
			if (registeredMesh.mesh.parent == mesh) {
				mesh.computeWorldMatrix(true);
				registeredMesh.mesh.computeWorldMatrix(true);

				var absolutePosition = registeredMesh.mesh.getAbsolutePosition();
				var absoluteRotation = mesh.rotation;

				var body = registeredMesh.body.body;
				body.setPosition(absolutePosition.x, absolutePosition.y, absolutePosition.z);
				body.setRotation(absoluteRotation.x, absoluteRotation.y, absoluteRotation.z);
				return;
			}
		}
	}

	public function applyImpulse(mesh:AbstractMesh, force:Vector3, contactPoint:Vector3) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			if (registeredMesh.mesh == mesh || registeredMesh.mesh == mesh.parent) {
				// Get object mass to have a behaviour similar to cannon.js
				var mass = registeredMesh.body.body.massInfo.mass;
				// The force is scaled with the mass of object
				registeredMesh.body.body.applyImpulse(contactPoint.scale(INV_SCALE), force.scale(INV_SCALE * mass));
				return;
			}
		}
	}

	public function createLink(mesh1:AbstractMesh, mesh2:AbstractMesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic):Bool {
		var body1 = null;
		var	body2 = null;
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			if (registeredMesh.mesh == mesh1) {
				body1 = registeredMesh.body.body;
			} else if (registeredMesh.mesh == mesh2) {
				body2 = registeredMesh.body.body;
			}
		}
		if (body1 == null || body2 == null) {
			return false;
		}
		if (options == null) {
			options = {};
		}

		new Link({
			type: options.type,
			body1: body1,
			body2: body2,
			min: options.min,
			max: options.max,
			axe1: options.axe1,
			axe2: options.axe2,
			pos1: [pivot1.x, pivot1.y, pivot1.z],
			pos2: [pivot2.x, pivot2.y, pivot2.z],
			collision: options.collision,
			spring: options.spring,
			world: this._world
		});

		return true;

	}

	public function dispose() {
		this._world.clear();
		while (this._registeredMeshes.length > 0) {
			this.unregisterMesh(this._registeredMeshes[0].mesh);
		}
	}

	public function isSupported():Bool {
		return true;
	}

	private function _getLastShape(body:RigidBody):Dynamic {
		var lastShape = body.shapes;
		while (lastShape.next != null) {
			lastShape = lastShape.next;
		}
		return lastShape;
	}

	public function runOneStep(time:Float) {
		this._world.step(time);
		
		// Update the position of all registered meshes
		var i = this._registeredMeshes.length;
		var m:Array<Float> = [];
		while (i-- > 0) {
			
			var body:RigidBody = this._registeredMeshes[i].body.body;
			var mesh:Mesh = this._registeredMeshes[i].mesh;
			var delta = this._registeredMeshes[i].delta;
			
			if (!body.sleeping) {
				
				if (body.shapes.next != null) {
					var parentShape = this._getLastShape(body);
					mesh.position.x = parentShape.position.x * WORLD_SCALE;
					mesh.position.y = parentShape.position.y * WORLD_SCALE;
					mesh.position.z = parentShape.position.z * WORLD_SCALE;
					var brm = body.rotation;
					m = [
						brm.e00, brm.e01, brm.e02, 0,
						brm.e10, brm.e11, brm.e12, 0,
						brm.e20, brm.e21, brm.e22, 0,
						      0,       0,       0, 1
					];
					
					var mtx = Matrix.FromArray(m);
					
					if (mesh.rotationQuaternion == null) {
						mesh.rotationQuaternion = new Quaternion(0, 0, 0, 1);
					}
					mesh.rotationQuaternion.fromRotationMatrix(mtx);
					mesh.computeWorldMatrix();
					
				} else {
					var brm = body.rotation;
					m = [
						brm.e00, brm.e01, brm.e02, 0,
						brm.e10, brm.e11, brm.e12, 0,
						brm.e20, brm.e21, brm.e22, 0,
						      0,       0,       0, 1
					];
					var mtx = Matrix.FromArray(m);
					
					// Body position
					var bodyX = mtx.m[12];
					var	bodyY = mtx.m[13];
					var	bodyZ = mtx.m[14];
						
					if (delta == null) {
						mesh.position.x = bodyX;
						mesh.position.y = bodyY;
						mesh.position.z = bodyZ;
					} else {
						mesh.position.x = bodyX + delta.x;
						mesh.position.y = bodyY + delta.y;
						mesh.position.z = bodyZ + delta.z;
					}
					
					if (mesh.rotationQuaternion == null) {
						mesh.rotationQuaternion = new Quaternion(0, 0, 0, 1);
					}
					Quaternion.FromRotationMatrixToRef(mtx, mesh.rotationQuaternion);
					mesh.computeWorldMatrix();
				}
			}
		}
	}
	
}
