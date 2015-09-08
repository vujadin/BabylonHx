package com.babylonhx.physics.plugins;

import com.babylonhx.culling.BoundingBox;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Space;
import com.babylonhx.math.Axis;
import jiglib.geometry.JCapsule;

import jiglib.geometry.JPlane;
import jiglib.geometry.JSphere;
import jiglib.physics.RigidBody;
import jiglib.physics.PhysicsSystem;
import jiglib.physics.MaterialProperties;
import jiglib.physics.constraint.JConstraintPoint;
import jiglib.geometry.JBox;
import jiglib.math.Vector3D;
import jiglib.math.Matrix3D;


/**
 * ...
 * @author Krtolica Vujadin
 */

typedef PhysMesh = {
	mesh:Mesh,
	body:RigidBody,
	material: MaterialProperties,
	delta: Vector3,
	isChild: Null<Bool>
}
 
class JigLibPlugin implements IPhysicsEnginePlugin {
	
	private var _world:PhysicsSystem;
	private var _registeredMeshes:Array<PhysMesh> = [];
	

	public function new() {
		//
	}
	
	public function initialize(?iterations:Int = 0) {
		this._world = new PhysicsSystem();
		this._world.setCollisionSystem();
	}
	
	private function _checkWithEpsilon(value:Float):Float {
		return value < PhysicsEngine.Epsilon ? PhysicsEngine.Epsilon : value;
	}
	
	var mtx:Matrix = null;
	public function runOneStep(delta:Float) {
		this._world.integrate(delta);		
		
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
						
			if (registeredMesh.isChild == null) {			
											
				var deltaPos = registeredMesh.delta;
				registeredMesh.mesh.position.x = registeredMesh.body.x + deltaPos.x;
				registeredMesh.mesh.position.y = registeredMesh.body.y + deltaPos.y;
				registeredMesh.mesh.position.z = registeredMesh.body.z + deltaPos.z;
						
				#if (js || purejs || html5 || web)
				mtx = Matrix.FromArray(cast registeredMesh.body.currentState.orientation.rawData);
				#else
				mtx = Matrix.FromArray(registeredMesh.body.currentState.orientation.rawData.toArray());
				#end
				registeredMesh.mesh.rotationQuaternion.fromRotationMatrix(mtx);
			}			
		}
	}

	public function setGravity(gravity:Vector3) {
		this._world.setGravity(new Vector3D(gravity.x, gravity.y, gravity.z));
	}

	public function registerMesh(mesh:AbstractMesh, impostor:Int, options:PhysicsBodyCreationOptions):Dynamic {	
		var _tempRot = mesh.rotation.clone();
		
		var body:RigidBody = null;
		this.unregisterMesh(mesh);
		
		var initialRotation:Quaternion = null;
		if (mesh.rotationQuaternion != null) {
			initialRotation = mesh.rotationQuaternion.clone();			
		} 
		else {
			initialRotation = mesh.rotation.toQuaternion();
		}		
		mesh.rotationQuaternion = new Quaternion(0, 0, 0, 1);		
		mesh.computeWorldMatrix(true);
		
		var bbox:BoundingBox = mesh.getBoundingInfo().boundingBox;
						
		// The delta between the mesh position and the mesh bounding box center
		var deltaPosition:Vector3 = mesh.position.subtract(bbox.center);
		
		// Transform delta position with the rotation
		if (initialRotation != null) {
			var m = new Matrix();
			initialRotation.toRotationMatrix(m);
			deltaPosition = Vector3.TransformCoordinates(deltaPosition, m);
		}
				
		switch (impostor) {
			case PhysicsEngine.SphereImpostor:
				
				var radiusX = bbox.maximumWorld.x - bbox.minimumWorld.x;
				var radiusY = bbox.maximumWorld.y - bbox.minimumWorld.y;
				var radiusZ = bbox.maximumWorld.z - bbox.minimumWorld.z;
				
				var mmax = Math.max(this._checkWithEpsilon(radiusX), this._checkWithEpsilon(radiusY));
				
				var shape = new JSphere(null, Math.max(mmax, this._checkWithEpsilon(radiusZ)) / 2);					
				body = this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);				
				
			case PhysicsEngine.BoxImpostor:
				
				var min = bbox.minimumWorld;
				var max = bbox.maximumWorld;
				var box = max.subtract(min);
				var sizeX = this._checkWithEpsilon(box.x);
				var sizeY = this._checkWithEpsilon(box.z);
				var sizeZ = this._checkWithEpsilon(box.y);
				
				var shape = new JBox(sizeX, sizeY, sizeZ);				
				body = this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
				
			case PhysicsEngine.CapsuleImpostor:
				
				var shape = new JCapsule(null, cast(mesh, Mesh).physicsDim.diameter / 2, cast(mesh, Mesh).physicsDim.height);
				body = this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);
				
			case PhysicsEngine.PlaneImpostor:
				//return this._createPlane(mesh, options);
				
			case PhysicsEngine.MeshImpostor:
				/*var rawVerts = mesh.getVerticesData(VertexBuffer.PositionKind);
				var rawFaces = mesh.getIndices();
				
				return this._createConvexPolyhedron(rawVerts, rawFaces, mesh, options);*/
		}
				
		var material = new MaterialProperties(options.restitution, options.friction);
		body.restitution = material.restitution;
		body.friction = material.friction;
		
		body.x = bbox.center.x;
		body.y = bbox.center.y;
		body.z = bbox.center.z;
		
		body.rotationX = _tempRot.x * 180 / Math.PI;
		body.rotationY = _tempRot.y * 180 / Math.PI;
		body.rotationZ = _tempRot.z * 180 / Math.PI;
				
		this._registeredMeshes.push({
			mesh: cast mesh,
			body: body,
			material: material,
			isChild: null,
			delta: deltaPosition
		});
				
		cast(mesh, Mesh).rigidBody = body;
				
		return body;
	}

	private function _createConvexPolyhedron(rawVerts:Array<Float>, rawFaces:Array<Int>, mesh:AbstractMesh, ?options:PhysicsBodyCreationOptions):Dynamic {
		/*var verts:Array<Vec3> = [];
		var faces:Array<Float> = [];
		
		mesh.computeWorldMatrix(true);
		
		// Get vertices
		var i:Int = 0;
		while (i < rawVerts.length) {
			var transformed = Vector3.Zero();
			Vector3.TransformNormalFromFloatsToRef(rawVerts[i], rawVerts[i + 1], rawVerts[i + 2], mesh.getWorldMatrix(), transformed);
			verts.push(new Vec3(transformed.x, transformed.z, transformed.y));
			i += 3;
		}
		
		// Get faces
		var j:Int = 0;
		while(j < rawFaces.length) {
			faces.push(rawFaces[j]);
			faces.push(rawFaces[j + 2]);
			faces.push(rawFaces[j + 1]);
			j += 3;
		}
		
		var shape = new ConvexPolyhedron(verts, faces);
		
		if (options == null) {
			return shape;
		}
		
		return this._createRigidBodyFromShape(shape, mesh, options.mass, options.friction, options.restitution);*/
		return null;
	}

	private function _createRigidBodyFromShape(shape:Dynamic, mesh:AbstractMesh, mass:Float, friction:Float, restitution:Float):RigidBody {			
		var material = new MaterialProperties(restitution, friction);
		var body:RigidBody = cast shape;
		body.restitution = material.restitution;
		body.friction = material.friction;
		//body.mass = mass;
		body.movable = mass > 0;							
		this._world.addBody(body);				
		return body;
	}
	
	public function registerMeshesAsCompound(parts:Array<PhysicsCompoundBodyPart>, options:PhysicsBodyCreationOptions):Dynamic {
		/*var compoundShape = new Compound();

		for (var index = 0; index < parts.length; index++) {
			var mesh = parts[index].mesh;

			var shape = this.registerMesh(mesh, parts[index].impostor);

			if (index == 0) { // Parent
				compoundShape.addChild(shape, new CANNON.Vec3(0, 0, 0));
			} else {
				compoundShape.addChild(shape, new CANNON.Vec3(mesh.position.x, mesh.position.z, mesh.position.y));
			}
		}

		var initialMesh = parts[0].mesh;
		var body = this._createRigidBodyFromShape(compoundShape, initialMesh, options.mass, options.friction, options.restitution);

		body.parts = parts;

		return body;*/
		
		return null;
	}

	private function _unbindBody(body:RigidBody) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.body == body) {
				registeredMesh.body = null;
				registeredMesh.delta = null;
			}
		}
	}

	public function unregisterMesh(mesh:AbstractMesh) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.mesh == mesh) {
				// Remove body
				if (registeredMesh.body != null) {
					this._world.removeBody(registeredMesh.body);
					this._unbindBody(registeredMesh.body);
				}
				
				this._registeredMeshes.splice(index, 1);
				return;
			}
		}
	}

	public function applyImpulse(mesh:AbstractMesh, force:Vector3, contactPoint:Vector3) {
		var worldPoint = new Vector3D(contactPoint.x, contactPoint.z, contactPoint.y);
		var impulse = new Vector3D(force.x, force.z, force.y);
		
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.mesh == mesh) {
				registeredMesh.body.applyWorldImpulse(impulse, worldPoint);
				return;
			}
		}
	}

	public function updateBodyPosition(mesh:AbstractMesh) {
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			if (registeredMesh.mesh == mesh || registeredMesh.mesh == mesh.parent) {
				var body = registeredMesh.body;
				
				var center = mesh.getBoundingInfo().boundingBox.center;
				body.x = center.x;
				body.y = center.z;
				body.z = center.y;
				
				body.rotationX = mesh.rotation.x;
				body.rotationZ = mesh.rotation.y;
				body.rotationY = mesh.rotation.z;
				return;
			}
		}
	}

	public function createLink(mesh1:AbstractMesh, mesh2:AbstractMesh, pivot1:Vector3, pivot2:Vector3, ?options:Dynamic):Bool {
		var body1 = null;
		var body2 = null;
		for (index in 0...this._registeredMeshes.length) {
			var registeredMesh = this._registeredMeshes[index];
			
			if (registeredMesh.mesh == mesh1) {
				body1 = registeredMesh.body;
			} 
			else if (registeredMesh.mesh == mesh2) {
				body2 = registeredMesh.body;
			}
		}
		
		if (body1 == null || body2 == null) {
			return false;
		}
		
		var constraint = new JConstraintPoint(body1, new Vector3D(pivot1.x, pivot1.z, pivot1.y), body2, new Vector3D(pivot2.x, pivot2.z, pivot2.y));
		this._world.addConstraint(constraint);
		
		return true;
	}

	public function dispose() {
		while (this._registeredMeshes.length > 0) {
			this.unregisterMesh(this._registeredMeshes[0].mesh);
		}
	}

	public function isSupported():Bool {
		return true;
	}
	
}
